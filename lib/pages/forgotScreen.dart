import 'package:chatapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {

  var email = TextEditingController();
  var numMail;
  QuerySnapshot isEmailPresent;
  DatabaseMethods databaseMethods = DatabaseMethods();

  var formKey = GlobalKey<FormState>();

  submit() async{
    var mail = await checkMail(email.text.trim());
    setState(() {
      this.numMail = mail;
    });

    if(formKey.currentState.validate()){
      FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim()).then((value) => print("Check ur mail"));
    }
  }

  checkMail(mail) async{
    print("Hellooooooo $mail");
    await databaseMethods.searchForEmail(mail.trim()).then((val){
      isEmailPresent = val;
    });
    numMail = isEmailPresent.documents.length;
    print("Nummail  ================ $numMail");
    return numMail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Center(child: Text("We will mail you a link. Please click on the link to reset your password.", style:
                TextStyle(color: Colors.white, fontSize: 20),),),
            ),
          ),

          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: email,
                validator: (val) {
                  return val.isEmpty || numMail != 1 && numMail == 0 ? 'This email does not exists' : null;
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
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
              ),
              child: FlatButton(
                child: Text("Send", style: TextStyle(color: Colors.white, fontSize: 20)),
                onPressed: () => submit(),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
