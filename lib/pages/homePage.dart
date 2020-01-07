import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import './drawer.dart';
import './LecMsgView.dart';
import 'package:url_launcher/url_launcher.dart';
import './loginPage.dart';
import './ForYouMsgView.dart';

class HomePage extends StatefulWidget {
  HomePage(this.firstLogin);
  final firstLogin;
  @override
  _HomePageState createState() => _HomePageState(firstLogin);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  _HomePageState(this.firstLogin);
  final firstLogin;
  final List<Tab> tabList = [
    Tab(text: '講義'),
    Tab(text: 'あなた宛'),
    Tab(text: '大学')
  ];
  TabController _tabController;
  List<Widget> tabBarViewList = [
    loginProcessWidget(),
    loginProcessWidget(),
    loginProcessWidget()
  ];

  static Widget loginProcessWidget() {
    var label;
    if(LoginCtrl.loggedIn){
      label='データ取得中';
    }else{
      label='ログイン中...';
    }
    return Container(
      child: Center(
        child: Text(label),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabList.length, vsync: this);
    loginCheck();
  }

  void loginCheck() async {
    var homePageDoc;
    //アプリを起動後すでにログイン処理を行っている場合
    if (LoginCtrl.loggedIn) {
      homePageDoc = await LoginCtrl.getHomePageHtml();
      bool sessionOutBool = homePageDoc
              .getElementsByTagName('meta')[0]
              .attributes['content']
              .indexOf('text/html; charset=SHIFT_JIS') !=
          -1;
      if (sessionOutBool) {
        print('session out');
        //セッション切れ
        LoginCtrl.loggedIn = false;
        loginCheck();
      } else {
        //ホームページ取得成功時
        setState(() {
          print('setState');
          tabBarViewList = [
            LecMsgTab(homePageDoc),
            ForYouMsgTab(homePageDoc),
            UnivMsgTab(homePageDoc)
          ];
        });
      }
    } else {
      //アプリ起動後の初回ログイン
      await LoginCtrl.setUnLoginSession();
      print('done setUnLoginSession');
      LoginCtrl.setLoginSession().then((success) async {
        if (success) {
          //ログインに成功
          print('login success');
          if (firstLogin) {
            //アプリ内での初回ログイン
            LoginCtrl.changeFirstLogin(false);
          }
          setState(() {
            print('setState');
            tabBarViewList = [
              Container(
                child: Center(
                  child: Text('データ取得中'),
                ),
              ),
              Container(
                child: Center(
                  child: Text('データ取得中'),
                ),
              ),
              Container(
                child: Center(
                  child: Text('データ取得中'),
                ),
              )
            ];
          });
          //ホームページ取得
          homePageDoc = await LoginCtrl.getHomePageHtml();
          setState(() {
            print('setState');
            tabBarViewList = [
              LecMsgTab(homePageDoc),
              ForYouMsgTab(homePageDoc),
              UnivMsgTab(homePageDoc)
            ];
          });
        } else {
          //ログインに失敗
          print('login failed');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('お知らせ'),
          bottom: TabBar(
//          isScrollable: true,
            tabs: tabList,
            controller: _tabController,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 2,
            indicatorPadding:
                EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            labelColor: Colors.black,
          ),
        ),
        drawer: Drawer(
          child: DrawerForm(context.widget.toString()),
        ),
        body: TabBarView(controller: _tabController, children: tabBarViewList));
  }
}

class LecMsgTab extends StatefulWidget {
  LecMsgTab(this.homePageDoc);
  final homePageDoc;
  @override
  _LecMsgTabState createState() => _LecMsgTabState(homePageDoc);
}

class _LecMsgTabState extends State<LecMsgTab> {
  _LecMsgTabState(this.homePageDoc);
  final homePageDoc;
  List<Widget> lecMsgList = [];
  List<Widget> lecMsgViewList = [];
  List<String> labels = [];
  List<String> links = [];

  @override
  void initState() {
    super.initState();
    setLecMsg(homePageDoc);
  }

  void getDetails() async {
//    http.Response lecMsgRes = await http
//        .post('https://www.portal.oit.ac.jp/CAMJWEB/prtlkkir.do', headers: {
//      'Cookie': LoginCtrl.sessionCookie,
//      'Content-Type': 'application/x-www-form-urlencoded',
//      'DNT': '1',
//      'user-agent':
//          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
//    }, body: {
//      // 'timestamp': 1574321405817,
//      'value(maxCount)': '50',
//      'sortMessgList': 'dummy',
//      'maxDispListCount': '50',
//      'value(rsunamSearchType)': 'partial',
//      'value(sndrNamSearchType)': 'partial',
//      'value(keijijyoken)': '1',
//      'value(keijijyoken)': 'forward',
//      'value(shimeiSearchType)': 'partial',
//      'value(kougicdSearchType)': 'forward',
//      'value(detailSearchShowFlg)': '2'
//    });
    http.Response lecMsgRes = await http.get(
        'https://www.portal.oit.ac.jp/CAMJWEB/prtlkopr.do?contenam=prtlkopr&buttonName=showAll',
        headers: {
          'Cookie': LoginCtrl.sessionCookie,
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'ja-JP,ja;q=0.9,en-US;q=0.8,en;q=0.7',
          'user-agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
        });
    print('cookie:' + LoginCtrl.sessionCookie);
    var lecMsgDoc = parse(lecMsgRes.body);
    List<dom.Element> msgElems =
        lecMsgDoc.getElementById('messglist').children[0].children;
    msgElems.forEach((msgElem) {
      print(
        msgElem.text.replaceAll('\n', '').replaceAll(' ', ''),
      );
    });
  }

  void setLecMsg(var homePageDoc) {
    List<dom.Element> msgElems;
    if (homePageDoc != null) {
      msgElems = homePageDoc
        .getElementsByClassName('canceled_class')[0]
            .getElementsByClassName('details');
      String timeStamp=homePageDoc.getElementById('koprForm').children[1].attributes['value'];
      msgElems.forEach((divElem) {
        var aElem = divElem.getElementsByTagName('a')[0];
        lecMsgList.add(msgListTile(
            aElem.text.replaceAll('\n', '').replaceAll(' ', ''),
            divElem,timeStamp));
        lecMsgList.add(Divider());
      });

      lecMsgList.add(
          ListTile(
            title:Center(
              child: Text('全てを見る',),
            ),
            onTap: (){},
          )
      );
      lecMsgList.add(Divider());
    } else {
      lecMsgList.add(ListTile(
        title: Text('ネットワークに接続されていません'),
      ));
    }

    setState(() {
      lecMsgViewList = lecMsgList;
    });
  }

  Widget msgListTile(String titleSt,dom.Element divElem,String timeStamp) {
    return ListTile(
      title: Text(titleSt),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LecMsgViewer(divElem,timeStamp),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: lecMsgViewList,
    );
  }
}

class ForYouMsgTab extends StatefulWidget {
  ForYouMsgTab(this.homePageDoc);
  final homePageDoc;
  @override
  _ForYouMsgTabState createState() => new _ForYouMsgTabState(homePageDoc);
}

class _ForYouMsgTabState extends State<ForYouMsgTab> {
  _ForYouMsgTabState(this.homePageDoc);
  final homePageDoc;
  List<Widget> msgTileList = [];
  List<Widget> msgViewList = [];

  void setToYouMsgTile(var topDocument) async {
    List<dom.Element> msgElems;
    if (topDocument != null) {
      msgElems = topDocument
          .getElementById('opprForm')
          .getElementsByClassName('inner')[0]
          .getElementsByClassName('details');
      String timeStamp=homePageDoc.getElementById('koprForm').children[1].attributes['value'];
      msgElems.forEach((divElem) {
        var aElem = divElem.getElementsByTagName('a')[0];
        msgTileList.add(msgListTile(
            divElem.text.replaceAll('\n', '').replaceAll(' ', ''),
            aElem,
            timeStamp
        ));
        msgTileList.add(Divider());
      });
      msgTileList.add(
          ListTile(
            title:Center(
              child: Text('全てを見る',),
            ),
            onTap: (){},
          )
      );
      msgTileList.add(Divider());
    } else {
      msgTileList.add(ListTile(
        title: Text('ネットワークに接続されていません'),
      ));
      msgTileList.add(Divider());
    }

    setState(() {
      msgViewList = msgTileList;
    });
    return;
  }

  Widget msgListTile(String titleSt,dom.Element aElem,String timeStamp) {
    return ListTile(
      title: Text(titleSt),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ForYouMsgViewer(aElem,timeStamp),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setToYouMsgTile(homePageDoc);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: msgViewList,
    );
  }
}



class UnivMsgTab extends StatefulWidget {
  UnivMsgTab(this.homePageDoc);
  final homePageDoc;
  @override
  _UnivMsgTabState createState() => new _UnivMsgTabState(homePageDoc);
}

class _UnivMsgTabState extends State<UnivMsgTab> {
  _UnivMsgTabState(this.homePageDoc);
  final homePageDoc;
  List<Widget> msgTileList = [];
  List<Widget> msgViewList = [];

  void setUnivMsgTile(var topDocument) async {
    List<dom.Element> msgElems;
    if (topDocument != null) {
      msgElems = topDocument
          .getElementsByClassName('public_inf')[0]
          .getElementsByClassName('inner')[0]
          .getElementsByClassName('details');
      String timeStamp=homePageDoc.getElementById('koprForm').children[1].attributes['value'];
      msgElems.forEach((divElem) {
        var aElem = divElem.getElementsByTagName('a')[0];
        msgTileList.add(msgListTile(
            divElem.text.replaceAll('\n', '').replaceAll(' ', ''),
            aElem,
            timeStamp
        ));
        msgTileList.add(Divider());
      });
      msgTileList.add(
          ListTile(
            title:Center(
              child: Text('全てを見る',),
            ),
            onTap: (){},
          )
      );
      msgTileList.add(Divider());
    } else {
      msgTileList.add(ListTile(
        title: Text('ネットワークに接続されていません'),
      ));
    }

    setState(() {
      msgViewList = msgTileList;
    });
    return;
  }

  Widget msgListTile(String titleSt,dom.Element aElem,String timeStamp) {
    return ListTile(
      title: Text(titleSt),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ForYouMsgViewer(aElem,timeStamp),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setUnivMsgTile(homePageDoc);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: msgViewList,
    );
  }
}
