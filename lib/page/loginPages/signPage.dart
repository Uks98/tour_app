import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../data/userInfo.dart';

class SignPage extends StatefulWidget {
  const SignPage({Key? key}) : super(key: key);

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  String _databaseUrl = "https://tourapp-4594d-default-rtdb.firebaseio.com";

  TextEditingController _idTextController = TextEditingController();
  TextEditingController _pwTextController = TextEditingController();
  TextEditingController _pwCheckController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _database = FirebaseDatabase(databaseURL: _databaseUrl);
    reference = _database!.reference().child("user");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입"),),
      body: Container(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _idTextController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "4자 이상 입력해주세요",
                    labelText: "아이디",
                  ),
                ),
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _pwTextController,
                  obscureText: true,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "6자 이상 입력해주세요",
                    labelText: "비밀번호",
                  ),
                ),
              ),
              SizedBox(height: 20,),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _pwCheckController,
                  obscureText: true,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "비밀번호 확인",
                  ),
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                if(_idTextController.text.length >=4 && _pwTextController.text.length >=6){
                  if(_pwTextController.text == _pwCheckController.text){
                    final bytes = utf8.encode(_pwTextController.text);
                    var digest = sha1.convert(bytes);
                    print("digest: ${digest}");
                    reference!.child(_idTextController.text).push().set(User(
                      _idTextController.text,digest.toString(),DateTime.now().toIso8601String()
                    ).toMap()).then((_) => Navigator.of(context).pop());
                  }else{
                    makeDialog("비밀번호가 틀립니다.");
                  }
                }else{
                  makeDialog("길이가 짧습니다.");
                }

              }, child: Text("회원가입",style: TextStyle(color: Colors.white),))
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
  void makeDialog(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(text),
          );
        });
  }
}
