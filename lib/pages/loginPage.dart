import 'package:flutter/material.dart';
import './drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:html/parser.dart';
import './homepage.dart';

class LoginCtrl {
  static String loginID;
  static String loginPass;
  static String sessionCookie='';
  static bool loggedIn=false;
  static bool firstLogin=false;
  static SharedPreferences prefs;

  static Future<bool> setUnLoginSession()async{
    print('setUnLoginSession');
    var sessionRes = await http.get(
      'https://www.portal.oit.ac.jp/CAMJWEB/login.do',
    );
    sessionCookie=json.decode(jsonEncode(sessionRes.headers))['set-cookie'].toString();
    loggedIn=false;
    return sessionCookie!='null';
  }

  static Future<bool> setLoginSession()async{
    print('setLoginSession');
    var loginRes = await http.post(
      'https://www.portal.oit.ac.jp/CAMJWEB/login.do',
      headers: {
        'Cookie':sessionCookie,
        'DNT': '1',
        'user-agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
      },
      body: {
        'lang':'1',
        'userId': loginID,
        'password': loginPass,
        'login.x':'0',
        'login.y':'0'
      },
    );
    sessionCookie=json.decode(jsonEncode(loginRes.headers))['set-cookie'].toString();
    if(sessionCookie!='null'){
      loggedIn=true;
    }
    return sessionCookie!='null';
  }

  static Future getHomePageHtml()async{
    print('getiingHomePageHtml');
    var homePageRes= await http.get(
        'https://www.portal.oit.ac.jp/CAMJWEB/top.do',
        headers: {
          'Cookie':sessionCookie,
          'DNT': '1',
          'user-agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36'
        }
    );
    return parse(homePageRes.body.toString());
  }

  static Future<bool> loadLoginInfo()async{
    prefs=await SharedPreferences.getInstance();
    loginID=(prefs.getString('loginID')??'');
    loginPass=(prefs.getString('loginPass')??'');
    firstLogin=(prefs.getBool('firstLogin')??true);
    return firstLogin;
  }

  static void changeFirstLogin(bool firstBool){
   prefs.setBool('firstLogin', firstBool);
  }

}

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}):super(key:key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController idTxtCtrl=TextEditingController();
  TextEditingController passTxtCtrl=TextEditingController();
  SharedPreferences prefs;

  var loginValid=true;

  @override
  void initState() {
    super.initState();
    idTxtCtrl.text=LoginCtrl.loginID;
    passTxtCtrl.text=LoginCtrl.loginPass;
    SharedPreferences.getInstance().
    then((shredPrefs){
      prefs=shredPrefs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGIN  ログイン'),
      ),
      drawer: Drawer(child: DrawerForm(context.widget.toString()),),
      body: Center(
        child: Card(
            child: SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'ユーザID',
                style: TextStyle(color: Colors.black54, fontSize: 25),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 2 / 3,
                child: TextField(
                  controller: idTxtCtrl,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'UserID',
                  ),
                ),
              ),
              Text(
                'パスワード',
                style: TextStyle(color: Colors.black54, fontSize: 25),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 2 / 3,
                child: TextField(
                  controller: passTxtCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              FlatButton(
                color: Colors.greenAccent,
                textColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.greenAccent,
                onPressed: () async{
                      if(loginValid){
                        loginValid=false;
                        prefs.setString('loginID', idTxtCtrl.text);
                        prefs.setString('loginPass', passTxtCtrl.text);
                        bool firstLogin = await LoginCtrl.loadLoginInfo();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(firstLogin)),
                              (Route<dynamic> route) => false,
                        );
                      }
                },
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
