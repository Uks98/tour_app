import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tourapp/page/mainpage/SettingPage.dart';
import 'package:tourapp/page/mainpage/favoritePage.dart';
import 'package:tourapp/page/mainpage/mapPage.dart';

class MainPage extends StatefulWidget {
  final Future<Database>? database;
   MainPage({Key? key,this.database}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  String _databaseUrl = "https://tourapp-4594d-default-rtdb.firebaseio.com";
  var id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _database = FirebaseDatabase(databaseURL: _databaseUrl);
    reference = _database!.reference().child('tour');
  }

  @override
  void dispose() {
    super.dispose();
  }
  int currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    id = ModalRoute.of(context)!.settings.arguments.toString();
    print("모달 아이디 ${id}");
    final page = [MapPage(databaseReference: reference!,db: widget.database,id: id!,),
      FavoritePage(),
      SettingPage()];
    return Scaffold(
      body: page[currentIndex],
        bottomNavigationBar: BottomAppBar(
          elevation: 0.0,
          child: Container(
            height: kBottomNavigationBarHeight,
            color: Colors.white,
            child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              IconButton(onPressed: () {
                setState((){
                  currentIndex = 0;
                });
              }, icon: Icon(Icons.map),
              ),
              IconButton(onPressed: (){
                setState((){
                  currentIndex = 1;
                });
              },  icon: Icon(Icons.star),),
              IconButton(onPressed: (){
                setState((){
                  currentIndex = 2;
                });
              },  icon: Icon(Icons.settings),)
            ],),
          ),
        ),
    );
  }
}
