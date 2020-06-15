import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

class SignerWidget extends StatefulWidget {
  final String data;
  
  SignerWidget({Key key, this.data}): super(key: key);

  @override
  _SignerWidgetState createState() => _SignerWidgetState(this.data);
}

class _SignerWidgetState extends State<SignerWidget> {

  Map<String, dynamic> _data;
  Map<String, dynamic> _request;
  Map<String, dynamic> _schema;
  Map<String, dynamic> _fields;
  

  final _headerStyle = TextStyle(color :Colors.black, fontWeight: FontWeight.w900);
  final _tableHeaderStyle = TextStyle(color :Colors.black, fontWeight: FontWeight.w900);

  _fetchSchema(String schemaId) async {
    try {
      http.Response response = await http.get("http://192.168.0.108:8000/api/schema/"+ schemaId);
      Map<String, dynamic> schemaResponse = jsonDecode(response.body);
      setState(() {
        _schema = schemaResponse["result"];
        if( _schema.containsKey("fields")){
          _fields = jsonDecode(_schema["fields"]);
        }
      });
    }catch (e){
      print(e.toString());
    }
  }

  _SignerWidgetState(String request){
    _schema = new Map<String,dynamic>();
    _fields = new Map<String,dynamic>();
    _request = jsonDecode(request) as Map;
    if( _request.containsKey("schema")){
      _fetchSchema(_request["schema"]);
    }

    _data = _request["data"];
    
    for( String v in _data.keys) {
      print(v +":" + _data[v].toString() + " - " + _data[v].runtimeType.toString());
      if(_data[v] is List<dynamic>){
        List<dynamic> x = _data[v];
        for( var l in x){
          print(l.toString() + " - " +l.runtimeType.toString() + " - " + (l is Map).toString());
      } 


      }  
    }
  }

  Widget renderValue(String key, dynamic value){
    return Row(mainAxisAlignment: MainAxisAlignment.start, children:[
      Container( color: Colors.indigo[50],  margin: const EdgeInsets.only(left: 20), width: 100, child : Text(_fields.containsKey(key) ? _fields[key]["name"]  : key + " : ",style: _headerStyle)) ,  Text(value.toString() )] );
  }

  Widget renderListValues(String key, dynamic value){
    return Row(mainAxisAlignment: MainAxisAlignment.start, children:[
      Container( margin: const EdgeInsets.only(left: 20), width: 100, child : Text(key + " : ", style: _headerStyle)) , Text(value.toString())] );
  
  }

  Widget renderListObjects(String key, dynamic value){
    List<TableRow> rows = [];
    List<String> headers = [];

    TableRow headersRow = TableRow(children: []);


    for (dynamic v in value){
      for (String key in v.keys){
        if( !headers.contains(key) ){
          headers.add(key);
          headersRow.children.add(Text(key, style: _tableHeaderStyle));
        }
      }
    }

    rows.add(headersRow);

    for (dynamic v in value){
      TableRow row = TableRow(children: []);
      for (String key in headers){
        row.children.add(Text(v[key].toString()));
      }
      rows.add(row);
    }
    
    return 
      Column(mainAxisAlignment : MainAxisAlignment.start, children : [
        Row( children : [Container(  width:100, alignment: Alignment.centerLeft, margin: const EdgeInsets.only(left: 20), 
          child: Text(key + " : " , style: _tableHeaderStyle))]), 
        Container( margin: const EdgeInsets.symmetric(horizontal: 20), 
          child : Table( children: rows))]);
  }


  Widget renderList(String key, dynamic value){
    bool isValues = false;
    bool isObjects = false;

    for (dynamic v in value){
        if(v is int || v is double || v is String){
          isValues = true;
        }
        if(v is Map){
          isObjects = true;
        }
    }
    if (isValues && !isObjects){
      return renderListValues(key, value);
    }
    if (!isValues && isObjects){
      return renderListObjects(key, value);
    }

    return( Row(mainAxisAlignment: MainAxisAlignment.start, 
    children:[
      Container( alignment: Alignment.centerLeft, margin: const EdgeInsets.symmetric(horizontal: 20), width: 100, child : Text(key)) , 
      Container( width : 10, child: Text(":")), 
      Text("Cannot render")] ));
  

  }


  @override
  Widget build(BuildContext context){
    List<Widget> widgets = [];
    for( String v in _data.keys) {
        if( this._data[v] is int || this._data[v] is double || this._data[v] is String){
          widgets.add(renderValue(v, this._data[v]));
        }
        if( this._data[v] is List){
          widgets.add(renderList(v, this._data[v]));
        }
    }

    return(
      Column(children: widgets, mainAxisAlignment: MainAxisAlignment.start)
    );

  }

}