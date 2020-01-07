import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import './loginPage.dart';
//import 'package:url_launcher/url_launcher.dart';

class LecMsgViewer extends StatefulWidget {
  LecMsgViewer(this.divElem, this.timeStamp);
  final divElem;
  final timeStamp;
  @override
  _LecMsgViewerState createState() =>
      new _LecMsgViewerState(divElem, timeStamp);
}

class _LecMsgViewerState extends State<LecMsgViewer> {
  _LecMsgViewerState(this.divElem, this.timeStamp);
  dom.Element divElem;
  String msgTitle = '';
  String msgDate = '';
  String msgContent = '';
  String timeStamp;
  List<Widget> msgList = [];
  List<Widget> msgListView = [];

  @override
  void initState() {
    super.initState();
    print(divElem.children.toString());
    getContent(divElem).then((contentDoc) {
      setContentTile(contentDoc);
    });
  }

  Future getContent(dom.Element divElem) async {
    List<dom.Element> inputElem = divElem.getElementsByTagName('input');
    String koprIndexSt = divElem.attributes['onclick'];
    List<String> koprIndexList = koprIndexSt
        .substring(koprIndexSt.length - 6, koprIndexSt.length - 2)
        .split(',');
    print('timestamp:' + timeStamp);
    print('session:' + LoginCtrl.sessionCookie);
    print(koprIndexList);
    var body;
    if (inputElem.length == 6) {
      body = {
        'value(koprMessgId)': inputElem[0].attributes['value'],
        'value(koprRisyunen)': inputElem[1].attributes['value'],
        'value(koprSemekikn)': inputElem[2].attributes['value'],
        'value(koprKougicd)': inputElem[3].attributes['value'],
        'value(koprJikanNo)': inputElem[4].attributes['value'],
        'value(koprTaisyDy)': inputElem[5].attributes['value'],
        'value(koprIndex)': koprIndexList[0],
        'value(koprMsgsyukn)': koprIndexList[1],
        'timestamp': timeStamp,
        'buttonName': getButtonName(koprIndexList[1]),
      };
    } else {
      body = {
        'value(koprMessgId)': inputElem[0].attributes['value'],
        'value(koprRisyunen)': inputElem[1].attributes['value'],
        'value(koprSemekikn)': inputElem[2].attributes['value'],
        'value(koprKougicd)': inputElem[3].attributes['value'],
        'value(koprJikanNo)': inputElem[4].attributes['value'],
        'value(koprIndex)': koprIndexList[0],
        'value(koprMsgsyukn)': koprIndexList[1],
        'timestamp': timeStamp,
        'buttonName': getButtonName(koprIndexList[1])
      };
    }
    var contentRes =
        await http.post('https://www.portal.oit.ac.jp/CAMJWEB/prtlkopr.do',
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
    List<dom.Element> trElems1 = contentDoc
        .getElementsByClassName('contents_1')[1]
        .getElementsByTagName('tr');
    List<String> labelList = [];
    List<String> labelList2 = [];
    List<String> contentList = [];
    List<String> contentList2 = [];
    for (var i = 0; i < trElems0.length; i++) {
      if (i.isEven) {
        var tdElems = trElems0[i].getElementsByTagName('td');
        for (var j = 0; j < tdElems.length; j++) {
          if (j.isEven) {
            if (tdElems[j].className == 'label_nodot') {
              labelList.add(
                  tdElems[j].text.replaceAll('\n', '').replaceAll('  ', ''));
            } else {
              contentList.add(
                  tdElems[j].text.replaceAll('\n', '').replaceAll('  ', ''));
            }
          }
        }
      }
    }

    for (var i = 0; i < trElems1.length; i++) {
      if (i.isEven) {
        var k = 0;
        var tdElems = trElems1[i].getElementsByTagName('td');
        for (var j = 0; j < tdElems.length; j++) {
          if (j.isEven) {
            if (k.isEven) {
              labelList2.add(
                  tdElems[j].text.replaceAll('\n', '').replaceAll('  ', ''));
              k++;
            } else {
              contentList2.add(
                  tdElems[j].text.replaceAll('\n', '').replaceAll('  ', ''));
            }
          }
        }
      }
    }

    print(labelList2.toString());
    print(contentList2.toString());

    var i = 0;
    labelList.forEach((title) {
      msgList.add(ListTile(
        title: Row(
          children: <Widget>[
            SizedBox(
              width: context.size.width / 3,
              child: Text(title + ':'),
            ),
            Expanded(
              //width: context.size.width*2/3,
              child: Text(contentList[i]),
            )
          ],
        ),
      ));
      i++;
    });
    msgList.add(Divider());
    var j = 0;
    labelList2.forEach((title) {
      msgList.add(ListTile(
        title: Center(child: Text('「'+title+'」')),
      ));
      msgList.add(ListTile(
        title: Center(child: Text(contentList2[j]),),
      ));
      j++;
      msgList.add(Divider());
    });
    setState(() {
      msgListView = msgList;
    });
  }

  String getButtonName(String buttonNo) {
    String buttonName;
    if (buttonNo == '11') {
      buttonName = "selectKyukouMessg";
    } else if (buttonNo == '12') {
      buttonName = "selectHokouMessg";
    } else if (buttonNo == '13') {
      buttonName = "selectJikanwariMessg";
    } else if (buttonNo == '14') {
      buttonName = "selectKougiMessg";
    } else if (buttonNo == '15') {
      buttonName = "selectReportMessg";
    } else if (buttonNo == '16') {
      buttonName = "selectJyugyouMessg";
    }
    return buttonName;
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
