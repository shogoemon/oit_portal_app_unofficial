import 'package:flutter/material.dart';
//import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
//import 'package:url_launcher/url_launcher.dart';

class NewsViewer extends StatefulWidget{
  NewsViewer(this.mainURL);
  final mainURL;
  @override
  _NewsViewerState createState()=>new _NewsViewerState(mainURL);
}

class _NewsViewerState extends State<NewsViewer>{
  _NewsViewerState(this.mainURL);
  String mainURL;
  String newsTitle='';
  String newsDate='';
  String newsContent='';

  @override
  void initState() {
    super.initState();
    getContent();
  }

  Future getContent()async{
    var contentRes=await http.get(mainURL);
    var contentDoc=parse(contentRes.body.toString());
    var contentElem=contentDoc.getElementsByClassName('box20')[0];
    if(contentElem.getElementsByTagName('dl').length==0){
      setState(() {
        contentElem.children.forEach((pElem){
          newsContent+=pElem.text.replaceAll('　　　　　','');
        });
      });
    }else{
      setState(() {
        newsContent=contentDoc.getElementsByTagName('dd')[0].text.replaceAll('　　　　　','');
      });
    }

    setState((){
      newsTitle=contentDoc.getElementsByClassName('news_h2')[0].text;
      newsDate=contentDoc.getElementsByClassName('cap_news')[0].text;
    });
    print(newsTitle+'\n'+newsDate+'\n'+newsContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News'),),
      body: ListView(
        children: <Widget>[
          ListTile(title: Text(newsTitle),),
          ListTile(title: Text(newsDate),),
          ListTile(title: Text(newsContent),)
        ],
      ),
    );
  }
}
//news_h2
