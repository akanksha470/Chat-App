import 'package:chatapp/helper/helperFunctions.dart';
import 'package:chatapp/pages/Signin.dart';
import 'package:chatapp/pages/display.dart';
import 'package:chatapp/pages/signup.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LocalData localData = LocalData();
  bool isLoggedIn = false;

  autoLogin() async{
    print("Logged1 $isLoggedIn");
    if(await localData.getUserEmail() != null){
      setState(() {
        localData.saveUserLoggedIn(true);
        isLoggedIn = true;

      });
      print("Logged2 $isLoggedIn");
    }
  }

  @override
  void initState() {
    autoLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,

        body: isLoggedIn ? Home() : SignInPage(),
      )
    );
  }
}
