import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tourapp/page/loginPages/loginPage.dart';
import 'package:tourapp/page/loginPages/signPage.dart';
import 'package:tourapp/page/mainpage/mainPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<Database> initDatabase() async {
    return openDatabase(join(await getDatabasesPath(), 'tour_database.db'),
        onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE place(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, tel TEXT , zipcode TEXT , address TEXT , mapx Number , mapy Number , imagePath TEXT)",
      );
    }, version: 1);
  }

  @override
  Widget build(BuildContext context) {
    Future<Database> database = initDatabase();


    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          return FutureBuilder(
            // Initialize FlutterFire
            future: Firebase.initializeApp(),
            builder: (context, snapshot) {
              // Check for errors
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error'),
                );
              }

              // Once complete, show your application
              if (snapshot.connectionState == ConnectionState.done) {
                _initFirebaseMessaging(context);
                return LoginPage();
              }

              // Otherwise, show something whilst waiting for initialization to complete
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
        '/sign': (context) => SignPage(),
        '/main': (context) => MainPage(database: database),
      },
    );
  }
  }

  _initFirebaseMessaging(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      print(event.data);
      print(event.notification!.title);
      bool? pushCheck = await _loadData();
      if (pushCheck!) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("알림"),
                content: Text(event.notification!.body!),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  Future<bool?> _loadData() async {
    var key = "push";
    SharedPreferences pref = await SharedPreferences.getInstance();
    var value = pref.getBool(key);
    return value;
  }
