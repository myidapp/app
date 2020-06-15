import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import 'package:local_auth/local_auth.dart';

class Crypto {
  bool isBiometry=false;
  LocalAuthentication localAuth;
  FlutterSecureStorage storage;

  Future<void> _init() async{
      String seed = await storage.read(key: "seed") ?? "";


      if( seed.isEmpty ){
            final mnemonic = bip39.generateMnemonic();
            seed = bip39.mnemonicToSeedHex(mnemonic);
            await storage.write(key: "seed", value: json.encode({"bio": false, "seed" : seed}));
      }else{
        try{
          dynamic seedObj = json.decode(seed); 
        } catch(e) {
            final mnemonic = bip39.generateMnemonic();
            seed = bip39.mnemonicToSeedHex(mnemonic);
            await storage.write(key: "seed", value: json.encode({"bio": false, "seed" : seed}));
        }

      }


      return;
  }

  Future<bool> setBiometry(bool enabled) async {
      final seed  = await storage.read(key: "seed");

      bool canCheckBiometrics = await localAuth.canCheckBiometrics;
      if( !canCheckBiometrics ) {
        return Future<bool>.value(false);
      }

      dynamic seedObj = json.decode(seed); 
      seedObj["bio"] = enabled;
      await storage.write(key: "seed", value: json.encode(seedObj));
      return Future<bool>.value(enabled);

  }  


  Future<List<String>> sign(String data) async {
      final seed  = await storage.read(key: "seed");
      dynamic seedObj = json.decode(seed); 
      if( seed.isEmpty ){
        return Future<List<String>>.value([]);
      }

      if(seedObj["bio"]){
        bool didAuthenticate = await localAuth.authenticateWithBiometrics(localizedReason : "Please confirm with fingerprint");
        if( !didAuthenticate ){
          return Future<List<String>>.value([]);
        }
      }

      print("Sign seed :" + seedObj["seed"]);
      final hashAlgorithm = sha256;
      final algorithm = ed25519;
      final hexSeed = hex.decode(seedObj["seed"]);
      final seedHash = await hashAlgorithm.hash(hexSeed);
      final privateKeySeed = PrivateKey(seedHash.bytes);
      final keyPair = await algorithm.newKeyPairFromSeed(privateKeySeed);
      final signature = await algorithm.sign(utf8.encode(data), keyPair);
      final List<String> result = [];
      result.add(hex.encode(signature.bytes));    
      result.add(hex.encode(signature.publicKey.bytes)); 
      return Future<List<String>>.value(result);   
  }

  Crypto() {
    localAuth = LocalAuthentication();
    storage = FlutterSecureStorage();
    _init();
  }

}