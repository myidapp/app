import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cryptography/cryptography.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsWidget extends StatefulWidget {
  SettingsWidget();
   @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  FlutterSecureStorage storage;
  LocalAuthentication localAuth;
  bool _bioEnabled = false;
  bool _bioPossible = false;

  _SettingsWidgetState(){
      storage = FlutterSecureStorage();
      localAuth = LocalAuthentication();

      _init();
  }
  
  _init() async {
      String seed = await storage.read(key: "seed") ?? "";
      dynamic seedObj = json.decode(seed); 
      _bioPossible = await localAuth.canCheckBiometrics;

      setState( (){
        _bioEnabled = seedObj["bio"];
      });
  }
  
  _switchBio(bool value) async {
    if(_bioEnabled && !value) {
        bool didAuthenticate = await localAuth.authenticateWithBiometrics(localizedReason : "Please confirm with fingerprint");
        if( !didAuthenticate ){
          return;
        }
    }
    String seed = await storage.read(key: "seed") ?? "";
    dynamic seedObj = json.decode(seed); 
    seedObj["bio"] = value;
    await storage.write(key: "seed", value: json.encode(seedObj));
    setState( (){
      _bioEnabled = value;
      });
  }


  @override
  Widget build(BuildContext context) {
    return( ListView(children: <Widget>[
          ListTile(
            title: Text('Biometric protection'),
            trailing: Switch(
              value: _bioPossible & _bioEnabled,
              onChanged: (val) {
                  _switchBio(_bioPossible & val);
              },
            ),
          )
        ])
      );
  }

} 