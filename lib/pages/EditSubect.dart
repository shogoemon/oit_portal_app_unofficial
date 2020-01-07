import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditSubjectPage extends StatefulWidget {
  EditSubjectPage(this.week,this.num);
  final String week;
  final String num;
  @override
  _EditSubjectPageState createState() => new _EditSubjectPageState(week,num);
}

class _EditSubjectPageState extends State<EditSubjectPage> {
  _EditSubjectPageState(this.week,this.num);
  final String week;
  final String num;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(week+'曜'+num+'限目(作成中...)'),
      ),
      body: ListView(
        children: <Widget>[
          EditorForm('科目名', 'subject'),
          EditorForm('講師名', 'teacher'),
          EditorForm('教室名', 'classroom'),
//          Container(
//            width: MediaQuery.of(context).size.width/2,
//            child: RaisedButton(
//              color: Colors.greenAccent,
//              onPressed: (){
//                print('作成中');
//              },
//              child: Text(
//                  '作成中...',
//                style: TextStyle(color: Colors.white),
//              ),
//            ),
//          )
        ],
      ),
    );
  }
}

class EditorForm extends StatefulWidget {
  EditorForm(this.title, this.prefsName);
  final String title;
  final String prefsName;
  @override
  _EditorFormState createState() => new _EditorFormState(title, prefsName);
}

class _EditorFormState extends State<EditorForm> {
  _EditorFormState(this.title, this.prefsName);
  final String title;
  final String prefsName;
  SharedPreferences prefs;
  TextEditingController txtCtrl;

  @override
  void initState() {
    super.initState();
  }

  void loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    txtCtrl =
        new TextEditingController(text: (prefs.getString(prefsName) ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
            title: Row(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Text(title)),
            Expanded(
              child: TextField(
                controller: txtCtrl,
              ),
            ),
          ],
        )),
      ],
    );
  }
}
