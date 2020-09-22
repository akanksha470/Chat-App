import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/helper/helperFunctions.dart';
import 'package:chatapp/pages/Signin.dart';
import 'package:chatapp/pages/chatScreen.dart';
import 'package:chatapp/pages/search.dart';
import 'package:chatapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var searchField = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();
  LocalData localData = LocalData();
  Stream usersStream;

  Widget usersList() {
    return StreamBuilder(
        stream: usersStream,
        builder: (context, snapshot) {
          if (snapshot.data == null)
            return Center(child: CircularProgressIndicator());
          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 20),
                        child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: Colors.indigoAccent),
                              child: Center(
                                child: Text(snapshot
                                      .data.documents[index].data["chatRoomId"].toString().replaceAll(Constants.myName, "")
                                      .replaceAll("_", "").substring(0, 1).toUpperCase(),
                                  style: TextStyle(color: Colors.white, fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            snapshot.data.documents[index].data["chatRoomId"].toString().replaceAll(Constants.myName, "")
                                .replaceAll("_", ""),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: (){
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => ChatScreen(snapshot.data.documents[index].data["chatRoomId"].toString().replaceAll(Constants.myName, "")
                            .replaceAll("_", ""), snapshot.data.documents[index].data["chatRoomId"].toString())));
                      },
                    ),
                    Divider(color: Colors.white70,)
                  ],
                );
              });
        });
  }

  getUserInfo() async {
    Constants.myName = await localData.getUserName();
    print("My name  ${Constants.myName}");
    var myemail = await localData.getUserEmail();
    print("My email $myemail") ;
    databaseMethods.getAvailUsers(Constants.myName).then((val) {
      setState(() {
        usersStream = val;
      });
    });
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Exit App"),
      content: Text("Are you sure you want to exit?"),
      actions: <Widget>[
        FlatButton(
          child: Text("Yes"),
          onPressed: () {
            Navigator.of(context).pop();
            SystemNavigator.pop();
          },
        ),
        FlatButton(
          child: Text("No"),
          onPressed:  () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showLogoutDialog(BuildContext context) {

    AlertDialog alert = AlertDialog(
      title: Text("Log Out"),
      content: Text("Are you sure you want to log out?"),
      actions: <Widget>[
        FlatButton(
          child: Text("Yes"),
          onPressed: () async {
            Navigator.of(context).pop();
            await localData.saveUserLoggedIn(false);
            await localData.saveUserName(null);
            await localData.saveUserEmail(null);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage()));
          },
        ),
        FlatButton(
          child: Text("No"),
          onPressed:  () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget popUpMenu(){
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: "logout",
          child: Row(
            children: <Widget>[
              Icon(Icons.exit_to_app, color: Colors.black,),
              SizedBox(width: 10,),
              Text("Log out"),
            ],
          ),
        )
      ],

      onSelected: (val){
        if(val == "logout"){
          showLogoutDialog(context);
        }
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => showAlertDialog(context),
          ),
          title: Text("Chat"),
          actions: <Widget>[
//            IconButton(
//              icon: Icon(Icons.exit_to_app, color: Colors.white,),
//              tooltip: "Log Out",
//              onPressed: () => showLogoutDialog(context)
//            )
          popUpMenu()
          ],
      ),
      body: usersList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchPage()));
        },
      ),
    );
  }
}
