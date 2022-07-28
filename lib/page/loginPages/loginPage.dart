import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tourapp/page/mainpage/mainPage.dart';

import '../../data/userInfo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  String _databaseUrl = "https://tourapp-4594d-default-rtdb.firebaseio.com";

  double opacity = 0;
  AnimationController? _animationController;
  Animation? _animation;
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animation = Tween<double>(begin: 0, end: pi * 2).animate(_animationController!);

    _animationController!.repeat();
    Timer(Duration(seconds: 2), () {
      //페이지 생성 후 2초 뒤 타이머 실행
      setState(() {
        opacity = 1;
      });
    });
    _database = FirebaseDatabase(databaseURL: _databaseUrl);
    reference = _database?.reference().child("user");
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _animationController!,
                builder: (context, widget) {
                  return Transform.rotate(
                    angle: _animation!.value,
                    child: widget,
                  );
                },
                child: Icon(
                  Icons.airplanemode_active,
                  color: Colors.deepOrangeAccent,
                  size: 80,
                ),
              ),
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    "모두의 여행",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: opacity,
                duration: Duration(seconds: 1),
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _idController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: "아이디",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _pwController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: "비밀번호",
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed("/sign");
                            },
                            child: Text("회원가입")),
                        SizedBox(width: 30,),
                        ElevatedButton(
                          onPressed: () {
                            if (_idController.text.length == 0 ||
                                _pwController.text.length == 0) {
                              makeDialog("빈칸이 존재합니다.");
                            } else {
                              reference!
                                  .child(_idController.text)
                                  .onValue
                                  .listen((event) {
                                if (event.snapshot.value == null) {
                                  makeDialog("아이디가 없습니다");
                                } else {
                                  reference!
                                      .child(_idController.text)
                                      .onChildAdded
                                      .listen(
                                    (event) {
                                      User user = User.fromSnapShot(event.snapshot);
                                      final bytes = utf8.encode(_pwController.text); //암호화
                                      final digest = sha1.convert(bytes);
                                      print("digest: ${digest}");
                                      if (user.pw == digest.toString()) {
                                        //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MainPage()));
                                        Navigator.of(context).pushReplacementNamed('/main',arguments: _idController.text);
                                      } else {
                                        makeDialog("비밀번호가 틀립니다.");
                                      }
                                    },
                                  );
                                }
                              });
                            }
                          },
                          child: Text("로그인"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
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
