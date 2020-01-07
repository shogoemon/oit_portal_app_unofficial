import 'package:flutter/material.dart';
import './pages/topPage.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import './pages/loginPage.dart';
import './pages/TimeTable.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (BuildContext context) {
          return TimeTablePage(MediaQuery.of(context).size);
        },
        '/pages/Top': (BuildContext context) {
          return TopPage();
        },
        '/pages/WebView': (BuildContext context,{String url}) {
          return WebViewScreen(url);
        },
        '/pages/loginPage': (BuildContext context) {
          return LoginPage();
        }
      },
    );
  }
}

class WebViewScreen extends StatelessWidget{
  WebViewScreen(this.url):super();
  final String url;

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      url:url,
      hidden: true,
      scrollBar: true,
      withZoom: true,
      withJavascript:true,
      supportMultipleWindows:true,
      displayZoomControls:true,
      appBar: new AppBar(
        title: new Text("Widget webview"),
      ),
      initialChild: Center(
        child: Text('loading..'),
      ),
    );
  }
}