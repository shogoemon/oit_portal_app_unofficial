import 'package:flutter/material.dart';
import './EditSubect.dart';
import './drawer.dart';

class TimeTablePage extends StatefulWidget {
  TimeTablePage(this.sizes);
  final sizes;
  @override
  _TimeTablePageState createState() => new _TimeTablePageState(sizes);
}

class _TimeTablePageState extends State<TimeTablePage> {
  _TimeTablePageState(this.sizes);
  final sizes;
  List<String> week=['月','火','水','木','金','土'];
  List<TableRow> tableView=[];
  Widget table=Center(child: Text('loading...'),);

  @override
  void initState() {
    super.initState();
  }

  void setCell(){
    List<TableRow> tableList=[];
    List<Widget> weekRowList=[];
    weekRowList.add(empCell());
    week.forEach((day){
      weekRowList.add(weekCell(day));
    });
    tableList.add(
        TableRow(
            children: weekRowList
        )
    );
    //縦のループ
    for(var i=1;i<6;i++){
      weekRowList=[];
      weekRowList.add(numCell(i.toString()));
      //横のループ
      for(var j=0;j<week.length;j++){
        weekRowList.add(subjectCell(title:'',name:'',place:'',week:week[j],num: i.toString()));
      }
      //段を追加
      tableList.add(
          TableRow(
              children: weekRowList
          )
      );
    }
    setState((){
      table=Table(
          columnWidths: <int, TableColumnWidth>{
            0: FixedColumnWidth(sizes.width / 15),
            1: FixedColumnWidth(sizes.width / 6.5),
            2: FixedColumnWidth(sizes.width / 6.5),
            3: FixedColumnWidth(sizes.width / 6.5),
            4: FixedColumnWidth(sizes.width / 6.5),
            5: FixedColumnWidth(sizes.width / 6.5),
            6: FixedColumnWidth(sizes.width / 6.5),
          },
          children: tableList
      );
    });
  }

  Widget subjectCell({String title,String name,String place,String week,String num}) {
    return SizedBox(
        height: sizes.height / 7,
        child: InkWell(
          onTap: (){
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context)=>EditSubjectPage(week,num)
                ));
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    place,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget numCell(String num) {
    return SizedBox(
        height: sizes.height / 7,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue
          ),
          child: Center(
            child: Text(
              num,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }

  Widget weekCell(String week){
    return SizedBox(
        height: sizes.height / 30,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue
          ),
          child: Center(
            child: Text(
              week,
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
    );
  }

  Widget empCell(){
    return SizedBox(
        height: sizes.height / 30,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    setCell();
    return Scaffold(
        appBar: AppBar(
          title: Text('時間割り'),
        ),
        drawer: Drawer(
          child: DrawerForm(context.widget.toString()),
        ),
        body: table
    );
  }
}