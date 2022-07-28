import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tourapp/page/loginPages/loginPage.dart';
import 'package:tourapp/page/loginPages/signPage.dart';
import 'package:tourapp/page/mainpage/mainPage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) => LoginPage(),
        '/sign': (context) => SignPage(),
        '/main': (context) => MainPage()
      },
    );
  }
}
