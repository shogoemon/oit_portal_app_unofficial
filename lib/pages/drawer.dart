import 'package:flutter/material.dart';
import './loginPage.dart';
import './topPage.dart';
import './homePage.dart';
import './TimeTable.dart';

class DrawerForm extends StatefulWidget {
  DrawerForm(this.fromWidgetName);
  final fromWidgetName;
  @override
  _DrawerFormState createState() => new _DrawerFormState(fromWidgetName);
}

class _DrawerFormState extends State<DrawerForm> {
  _DrawerFormState(this.fromWidgetName);
  final fromWidgetName;
  //final loginPageKey=new GlobalKey<_LoginPageState>();
  //final loginPageKey=new GlobalKey<_DrawerFormState>();

  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.info),
          title: Text('ニュース'),
          onTap: () {
            if (fromWidgetName != 'TopPage') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TopPage()),
                (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pop(context);
            }
            //await launch('https://www.supremecommunity.com/',forceSafariVC: true);
          },
        ),
        ListTile(
            leading: Icon(Icons.home),
            title: Text('お知らせ'),
            onTap: () async {
              if (fromWidgetName != 'LoginPage' && fromWidgetName != 'HomePage') {
                //現在開いているページと遷移先が同じでない
                bool firstLogin = await LoginCtrl.loadLoginInfo();
                if (firstLogin) {
                  //一度もログインしたことがない
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                  );
                } else {
                  //過去にログインに成功している
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(firstLogin)),
                        (Route<dynamic> route) => false,
                  );
                }
              } else {
                //現在開いているページと遷移先が同じ
                Navigator.pop(context);
              }
            }
            //Navigator.push(context, MaterialPageRoute(builder: (context) => Identify())
            ),
        ListTile(
          leading: Icon(Icons.alarm),
          title: Text('時間割り'),
          onTap: () {
            if (fromWidgetName != 'TimeTablePage') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TimeTablePage(MediaQuery.of(context).size)),
                    (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pop(context);
            }
            //await launch('https://www.supremecommunity.com/',forceSafariVC: true);
          },
        )
      ],
    );
  }
}
