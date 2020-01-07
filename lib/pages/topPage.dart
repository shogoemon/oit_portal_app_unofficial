import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
//import '../main.dart';
import './drawer.dart';
import './NewsView.dart';
import 'package:url_launcher/url_launcher.dart';

class TopPage extends StatefulWidget {
  TopPage({Key key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> with SingleTickerProviderStateMixin {
  var topHtml;
  final List<Tab> tabList = [Tab(text: '最新ニュース'), Tab(text: '学部別コンテンツ')];
  TabController _tabController;
  List<Widget> tabBarViewList = [Container(), Container()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabList.length, vsync: this);
    getTopPageHtml();
  }

  void getTopPageHtml() async {
    var topHtmlRes;
    var topDoc;
    var newsHtmlRes;
    var newsDoc;
    try {
      newsHtmlRes = await http.get('https://www.oit.ac.jp/japanese/news/latest.php?type=2');
      newsDoc = parse(newsHtmlRes.body.toString());
      topHtmlRes =
          await http.get('https://www.portal.oit.ac.jp/CAMJWEB/top.do');
      topDoc = parse(topHtmlRes.body.toString());
      setState(() {
        tabBarViewList = [NewsTab(newsDoc), RightAreaTab(topDoc)];
      });
    } catch (e) {
      setState(() {
        tabBarViewList = [NewsTab(newsDoc), RightAreaTab(topDoc)];
      });
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Top'),
          bottom: TabBar(
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
        drawer: Drawer(child: DrawerForm(context.widget.toString()),),
        body: TabBarView(controller: _tabController, children: tabBarViewList));
  }
}

class RightAreaTab extends StatefulWidget {
  RightAreaTab(this.topDocument);
  final topDocument;
  @override
  _RightAreaTabState createState() => _RightAreaTabState(topDocument);
}

class _RightAreaTabState extends State<RightAreaTab> {
  _RightAreaTabState(this.topDocument);
  final topDocument;
  List<Widget> rightAreaList = [];
  List<Widget> rightAreaViewList = [];
  List<String> labels=[];
  List<String> links=[];

  @override
  void initState() {
    super.initState();
    setRightAreaLink(topDocument);
  }

  void setRightAreaLink(var document) {
    List<dom.Element> linkElems;
    List<Widget> rightAreaWidgets=[];
    if (document != null) {
      getLinksInfo('blueList');
      rightAreaWidgets.add(linksCard('工学部/大学院',labels,links,Colors.lightBlueAccent));

      getLinksInfo('yellowList');
      rightAreaWidgets.add(linksCard('ロボティクス＆デザイン工学部/大学院',labels,links,Colors.yellow));

      getLinksInfo('greenList');
      rightAreaWidgets.add(linksCard('情報科学部/大学院',labels,links,Colors.greenAccent));

      getLinksInfo('pinkList');
      rightAreaWidgets.add(linksCard('知的財産学部',labels,links,Colors.pinkAccent));

      getLinksInfo('pinkList2');
      rightAreaWidgets.add(linksCard('専門職大学院・知的財産研究科',labels,links,Colors.pinkAccent));

      setState(() {
        rightAreaViewList = rightAreaWidgets;
      });
    } else {
      setState(() {
        rightAreaViewList = [Center(child: Text('please check network'))];
      });
    }
  }

  void getLinksInfo(String className){
    List<dom.Element> linkElems;
    labels=[];
    links=[];
    if(className=='pinkList2'){
      linkElems=topDocument.getElementsByClassName('pinkList')[1].children;
    }else{
      linkElems=topDocument.getElementsByClassName(className)[0].children;
    }
    linkElems.forEach(
            (linkElem){
          labels.add(linkElem.children[0].text);
          links.add(linkElem.children[0].attributes['href']);
        }
    );
  }

  Widget linksCard(String title,List<String> labels,List<String> links,var color){
    List<Widget> linkTiles=[];
    for(int i=0;i<labels.length;i++){
      linkTiles.add(
          ListTile(
            title: Text(
              labels[i],
            ),
            onTap: (){
              print(links[i]);
              launch(links[i]);
            },
          )
      );
      linkTiles.add(Divider());
    }
    
    return Card(
      child: Column(
        children: <Widget>[
          Container(
            child: ListTile(
              title: Text(
                title,
                style: TextStyle(fontSize: 20,color: Colors.white),
              ),
              trailing: Icon(Icons.expand_more),
            ),
            color: color,
          ),
          Divider(),
          Column(
            children: linkTiles,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: rightAreaViewList,
    );
  }
}

class NewsTab extends StatefulWidget {
  NewsTab(this.topDocument);
//  NewsTab({Key key}):super(key:key);
  final topDocument;
  @override
  _NewsTabState createState() => new _NewsTabState(topDocument);
}

class _NewsTabState extends State<NewsTab> {
  _NewsTabState(this.topDocument);
  final topDocument;
  List<Widget> newsTileList = [];
  List<Widget> newsViewList = [];

  void setNewsDocument(var topDocument) async {
    List<dom.Element> newsElems;
    if (topDocument != null) {
      newsElems = topDocument.getElementById('news_box2').children;
      newsElems.forEach((dlElem) {
        var aElem = dlElem.children[1].children[0];
        newsTileList.add(newsListTile(
            aElem.text.replaceAll('\n', '').replaceAll(' ', ''),
            aElem.attributes['href']));
        newsTileList.add(Divider());
      });
    } else {
      newsTileList.add(ListTile(
        title: Text('ネットワークに接続されていません'),
      ));
    }

    setState(() {
      newsViewList = newsTileList;
    });
    return;
  }

  Widget newsListTile(String titleSt, String href) {
    String url = 'https://www.oit.ac.jp' + href;
    return ListTile(
      title: Text(titleSt),
      onTap: () {
        if(url.indexOf('pdf')!=-1){
          launch(href);
        }else{
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewsViewer(url),
            ),
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setNewsDocument(topDocument);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: newsViewList,
    );
  }
}
