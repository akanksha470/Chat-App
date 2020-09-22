import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/helper/helperFunctions.dart';
import 'package:chatapp/pages/chatScreen.dart';
import 'package:chatapp/pages/display.dart';
import 'package:chatapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  var searchField = TextEditingController();
  bool isClicked;
  bool isLoading;
  QuerySnapshot searchResult;
//  List <DocumentSnapshot> documents;

  @override
  void initState() {
    super.initState();
    isClicked = false;
    isLoading = false;
  }

  initiateSearch() async{
    print("Heelo");
    if(searchField.text.trim().isNotEmpty){
      setState(() {
        isLoading = true;
      });
    }
    await databaseMethods.searchForName(searchField.text.trim()).then((val){
        searchResult = val;
        print("result: $searchResult");
        setState(() {
          isLoading = false;
          isClicked = true;
        });
    });
    print("Length ${searchResult.documents.length}");
  }

  getChatRoomId(String a, String b){
    if(a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)){
      return "$a\_$b";
    }
    else{
      return "$b\_$a";
    }
  }

  createChatRoom(String username){
    String chatRoomId = getChatRoomId(username, Constants.myName);
    List<String> users = [username, Constants.myName];
    Map<String, dynamic> chatRoom = {
      "users" : users,
      "chatRoomId" : chatRoomId
    };

    databaseMethods.addChatRoom(chatRoom, chatRoomId);
    print("Done");
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(username, chatRoomId)));
  }


  searchList(){
    print("Search: $searchResult");
      return isClicked ? ListView.builder(
          itemCount: searchResult.documents.length,
          itemBuilder: (context, index) {
            return Container(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    child: ListTile(
                      title: Text(searchResult.documents[index].data["userName"], style: TextStyle(color: Colors.white),),
                      subtitle: Text(searchResult.documents[index].data["userEmail"], style: TextStyle(color: Colors.white)),
                    ),
                    onTap: () => createChatRoom(searchResult.documents[index].data["userName"]),
                  ),
                  Divider(color: Colors.white70,)
                ],
              ),

            );
          }
      ) : Container();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          appBar:  AppBar(
            leading: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => Home()
              ));
              },),
            title: TextField(
              cursorColor: Colors.white,
              controller: searchField,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Search Username",
                labelStyle: TextStyle(color: Colors.white),
                suffixIcon: IconButton(icon: Icon(Icons.search, color: Colors.white,),
                onPressed: initiateSearch
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white))
            ),
          ),
          ),
        body: isLoading ? Container(
          child: Center(child: CircularProgressIndicator(),),
        ) : searchList()
        );
  }
}
