import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/helper/helperFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData, String username) async {
    Firestore.instance.collection("users").add(userData).catchError((e) {
      print(e.toString());
    });
//  Firestore.instance.collection("users").document(username).setData(userData).catchError((e) {
//    print(e);
//  });
  }

  getUserInfo(String email) async {
    return Firestore.instance.collection("users").where("userEmail", isEqualTo: email).getDocuments().catchError((e) {
      print(e.toString());
    });
  }

//  addUserImage(String userImage) async{
//    Firestore.instance.collection("users").document(Constants.myName).setData({
//      "userImage" : userImage
//    }, merge: true);
//  }
  
  searchForName(String user) async{
    return  await Firestore.instance.collection("users").where('userName', isEqualTo: user).getDocuments();
  }

  searchForName1(String user) async{
    var result =  await Firestore.instance.collection("users").limit(1).where('userName', isEqualTo: user).getDocuments();
    return result;
  }

  searchForEmail(String mail) async{
    var result = await Firestore.instance.collection("users").limit(1).where('userEmail', isEqualTo: mail).getDocuments();
    return result;
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    Firestore.instance.collection("ChatRoom").document(chatRoomId).setData(chatRoom).catchError((e) {
      print(e);
    });
  }

  getChats(String chatRoomId) async{
    var result = await Firestore.instance.collection("ChatRoom").document(chatRoomId).collection("chats")
        .orderBy("time").snapshots();
      return result;
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) async{
    Firestore.instance.collection("ChatRoom").document(chatRoomId).collection("chats").add(chatMessageData).catchError((e){
      print(e.toString());
    });
  }

  getAvailUsers(String MyName) async {
    return await Firestore.instance.collection("ChatRoom").where('users', arrayContains: MyName).snapshots();
  }
}