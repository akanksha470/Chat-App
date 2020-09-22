import 'package:chatapp/helper/helperFunctions.dart';
import 'package:chatapp/pages/display.dart';
import 'package:chatapp/pages/forgotScreen.dart';
import 'package:chatapp/pages/signup.dart';
import 'package:chatapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var email = TextEditingController();
  var pwd = TextEditingController();
  var formKey = GlobalKey<FormState>();
  LocalData localData = LocalData();
  var snackbar;

  bool isLoading = false;
 // bool ifUserExists = true;

  signin() async{
    if(formKey.currentState.validate()) {
      //    localData.saveUserEmail(email.text.trim());
      setState(() {
        isLoading = true;
      });

      try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: pwd.text.trim());
        QuerySnapshot userInfoSnapshot =
        await DatabaseMethods().getUserInfo(email.text.trim());

        await localData.saveUserName(userInfoSnapshot.documents[0].data["userName"]);
        await localData.saveUserEmail(email.text.trim());
        await localData.saveUserLoggedIn(true);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      }on PlatformException catch(e){
        print("errorrrrr ${e.toString()}");
        setState(() {
          isLoading = false;
        });
        email.text = "";
        pwd.text = "";
        snackbar = SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: <Widget>[
              Icon(Icons.info_outline),
              SizedBox(width: 10,),
              Text("Check your username and password"),
            ],
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);

      }
    }
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Chat'),
        ),
      body: isLoading ? Container(
        child: Center(child: CircularProgressIndicator()),
      ) : Column(
        children: <Widget>[
          SizedBox(height: 20,),
          Text("Welcome To the ", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w400),),
          Center(child: Text("Chat", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w400),)),
          SizedBox(height: 40,),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: <Widget>[
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: email,
                        validator: (val) {
                            return val.isEmpty ? 'Please Enter Correct Email' : null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)
                            )
                        ),
                      ),

                      TextFormField(
                        controller: pwd,
                        obscureText: true,
                        validator: (val) {
                          return val.length < 6 || val.isEmpty ?
                          "Enter Password 6+ characters" : null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)
                            )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          alignment: Alignment.centerRight,
                            child: GestureDetector(
                              child: Text("Forgot Password", style: TextStyle(color: Colors.white,
                                  decoration: TextDecoration.underline, fontSize: 15),),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotScreen()));
                              },
                            )),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 40,),
                 Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                      ),
                      child: FlatButton(
                        child: Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 20)),
                        onPressed: () => signin(),
                      ),
                    ),
                  ),

                Text("Don't have an account?", style: TextStyle(color: Colors.white, fontSize: 15),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                    ),
                    child: FlatButton(
                        child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: (){
                        Navigator.push(
                            context, MaterialPageRoute(
                          builder: (context) => SignUpPage(),
                        )
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }
}
