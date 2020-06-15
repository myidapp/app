import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;

class MnemonicWidget extends StatefulWidget {
  MnemonicWidget();

  @override
  _MnemonicWidgetState createState() => _MnemonicWidgetState();
}


class _MnemonicWidgetState extends State<MnemonicWidget> {
  String _mnemonic= "New";
  bool _isReady=false;
  _init() async {
    _mnemonic =  bip39.generateMnemonic();

    setState((){
    });
  }

  _MnemonicWidgetState() {
    _init();
    _isReady = false;
  }
  
  _onWordSelected() {
  }

  _onNextButtonPressed() {
    setState((){
      _isReady = true;
    });
  }

  Widget _renderWords(){
    List<Widget> result=[];
    List<String> words = _mnemonic.split(" ");
    for(int i=0; i < words.length; i += 1 ){
      result.add( 
        FlatButton(child : Text('${i+1} : ${words[i]}'), onPressed: _onWordSelected ), 
        
      );
    }
    return Wrap( children: result);
  }

  @override
  Widget build(BuildContext context) {
        return (!_isReady ? _mnemonic.length > 0 ?
           Column( children : <Widget>[
             _renderWords(),
             FlatButton(child: Text("Ready"), onPressed: _onNextButtonPressed)
           ]) : null :
           Column( children : <Widget>[
              _renderWords(),
             FlatButton(child: Text("Done"), onPressed: _onNextButtonPressed)
           ])
        );
  }

}