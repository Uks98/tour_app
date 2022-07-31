import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  final DatabaseReference reference;
  final String id;
   SettingPage({Key? key,required this.reference, required this.id}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool pushCheck = true;
  void _setData(bool value)async{
    var key = "push";
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }
  void _loadData ()async{
    var key = "push";
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState((){
      var value = pref.getBool(key);
      if(value == null){
        setState((){
          pushCheck = true;
        });
      }else{
        setState((){
          pushCheck = value;
        });
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   _loadData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("설정"),),
      body: Container(
        child: Center(
          child: Column(children: [
            Row(
              children: [
              Text("푸쉬 알림",style: TextStyle(fontSize: 20),),
              Switch(value: pushCheck, onChanged: (value){
                setState((){
                  pushCheck = value;
                });
                _setData(value);
              }),
            ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            ),
            SizedBox(height: 50,),
            MaterialButton(onPressed: (){
              //Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },child: Text("로그아웃",style: TextStyle(fontSize: 20),),),
            SizedBox(height: 50,),
            MaterialButton(
              onPressed: () {
                AlertDialog dialog = new AlertDialog(
                  title: Text('아이디 삭제'),
                  content: Text('아이디를 삭제하시겠습니까?'),
                  actions: <Widget>[
                    MaterialButton(
                        onPressed: () {
                          print(widget.id);
                          widget.reference
                              .child('user')
                              .child(widget.id)
                              .remove();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/', (Route<dynamic> route) => false);
                        },
                        child: Text('예')),
                    MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('아니요')),
                  ],
                );
                showDialog(
                    context: context,
                    builder: (context) {
                      return dialog;
                    });
              },
              child: Text('회원 탈퇴', style: TextStyle(fontSize: 20)),
            ),
          ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),

        ),
      ),
    );
  }
}
