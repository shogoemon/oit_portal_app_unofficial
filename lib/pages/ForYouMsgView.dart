import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import './loginPage.dart';
//import 'package:url_launcher/url_launcher.dart';

class ForYouMsgViewer extends StatefulWidget {
  ForYouMsgViewer(this.aElem, this.timeStamp);
  final aElem;
  final timeStamp;
  @override
  _ForYouMsgViewerState createState() =>
      new _ForYouMsgViewerState(aElem, timeStamp);
}

class _ForYouMsgViewerState extends State<ForYouMsgViewer> {
  _ForYouMsgViewerState(this.aElem, this.timeStamp);
  dom.Element aElem;
  String msgTitle = '';
  String msgDate = '';
  String msgContent = '';
  String timeStamp;
  List<Widget> msgList = [];
  List<Widget> msgListView = [];

  @override
  void initState() {
    super.initState();
    getContent(aElem)
        .then((contentDoc) {
      setContentTile(contentDoc);
    });
  }

  Future getContent(dom.Element aElem) async {
    String incIdSt = aElem.attributes['onclick'];
    String funcName=incIdSt.substring(0,incIdSt.indexOf('('));
    String buttonName;
    String msgId=incIdSt.substring(incIdSt.indexOf(',')+1,incIdSt.length-15);
    String valueName;
    String url;

    switch(funcName){
      case 'openOpprFloat':{
        buttonName='showOpprFloat';
        url='https://www.portal.oit.ac.jp/CAMJWEB/wbasoppr.do';
        valueName='value(opprMessgId)';
        break;
      }
      case 'openOaprFloat':{
        buttonName='showOaprFloat';
        url='https://www.portal.oit.ac.jp/CAMJWEB/wbasoapr.do';
        valueName='value(oaprMessgId)';
        break;
      }
    }

    var body;
    body = {
      valueName: msgId,
      'timestamp': timeStamp,
      'buttonName': buttonName
    };
    var contentRes =
        await http.post(url,
            headers: {
              'Accept': 'text/html, */*',
              'Accept-Encoding': 'gzip, deflate, br',
              'Accept-Language': 'ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7',
              'Connection': 'keep-alive',
              'Content-Type': 'application/x-www-form-urlencoded',
              'Cookie': LoginCtrl.sessionCookie,
              'DNT': '1',
              'Host': 'www.portal.oit.ac.jp',
              'Origin': 'https://www.portal.oit.ac.jp',
              'Referer': 'https://www.portal.oit.ac.jp/CAMJWEB/top.do',
              'Sec-Fetch-Mode': 'cors',
              'user-agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
              'X-Requested-With': 'XMLHttpRequest'
            },
            body: body);
    return parse(contentRes.body.toString());
  }

  void setContentTile(var contentDoc) {
    List<dom.Element> contentElems =
        contentDoc.getElementsByClassName('caption');
    List<dom.Element> trElems0 = contentDoc
        .getElementsByClassName('contents_1')[0]
        .getElementsByTagName('tr');
    List<String> labelList = [];
    List<String> contentList = [];
    for (var i = 0; i < trElems0.length; i++) {
      if (i.isEven) {
        var k = 0;
        var tdElems = trElems0[i].getElementsByTagName('td');
        for (var j = 0; j < tdElems.length; j++) {
          if (j.isEven) {
            if (k.isEven) {
              labelList.add(
                  tdElems[j].text.replaceAll('\n', '').replaceAll('  ', ''));
              k++;
            } else {
//              var linkElems=tdElems[j].getElementsByTagName('a');
//              if(linkElems.length!=-1){
//                List<String> contentList=[
//                tdElems[j].text.replaceAll('\n', '').replaceAll('  ', '');
//                ];
//                linkElems.forEach((aElem){
//                  List<String>splitList=contentList[contentList.length-1].split(aElem.attributes['href']);
//    //contentList=new List.from(contentList.removeLast())..addAll(list2);
//                });
//              }
//              List<String> links=RegExp('(https?|ftp)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)').allMatches(contentData).map(
//                      (match) => match.group(0)).toList();
            contentList.add(tdElems[j].text.replaceAll('\n', '').replaceAll('  ', ''));
            }
          }
        }
      }
    }

    print(labelList.toString());

    msgList.add(Divider());
    var j = 0;
    labelList.forEach((title) {
      msgList.add(ListTile(
        title: Center(child: Text('「' + title + '」')),
      ));
      msgList.add(ListTile(
        title: Center(
          child: Text(contentList[j]),
        ),
      ));
      j++;
      msgList.add(Divider());
    });
    setState(() {
      msgListView = msgList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('詳細情報'),
      ),
      body: ListView(
        children: msgListView,
      ),
    );
  }
}
