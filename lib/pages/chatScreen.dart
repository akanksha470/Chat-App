import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speech_recognition/speech_recognition.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String chatRoomId;
  const ChatScreen(this.username, this.chatRoomId, {Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  var message = TextEditingController();
  Stream chatStream;

  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  bool _isStarted = false;
  String resultText;

  Widget chatList() {
    return StreamBuilder(
      stream: chatStream,
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator());
        return Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                print("going to messg");
                return MessageTile(
                    snapshot.data.documents[index].data["message"],
                    snapshot.data.documents[index].data["sendBy"] ==
                        Constants.myName);
              }),
        );
      },
    );
  }

  sendMessage() {
    print("message: ${message.text.trim()}");
    if (message.text.trim().isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": message.text.trim(),
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch
      };
      databaseMethods.addMessage(widget.chatRoomId, messageMap);
      message.text = "";
    }
  }

  speechTotext(){
    if(_isAvailable && !_isListening && ! _isStarted){
      _speechRecognition.listen(locale: "en_US").then((result) => setState(() {
        _isStarted = true;
        print('$result');
      }));
    }
    else if(_isListening && _isStarted){
      _speechRecognition.stop().then((result) => setState(() => _isListening = result));
    }
  }

  @override
  void initState() {
    databaseMethods.getChats(widget.chatRoomId).then((val) {
      setState(() {
        chatStream = val;
      });
    });
    initSpeechRecognizer();
    super.initState();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();
    _speechRecognition.setAvailabilityHandler(
        (result) => setState(() => _isAvailable = result));
    _speechRecognition.setRecognitionStartedHandler(
        () => setState(() => _isListening = true));
    _speechRecognition.setRecognitionResultHandler(
        (speech) => setState(() {
          message.text = speech;
          _isStarted = false;
        }));
    _speechRecognition.setRecognitionCompleteHandler(
        () => setState(() => _isListening = false));
    _speechRecognition
        .activate()
        .then((result) => setState(() => _isAvailable = result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.username),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            chatList(),
            Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)),
                          child: TextField(
                            controller: message,
                            decoration: InputDecoration(
                                hintText: "Enter message",
                                suffixIcon: IconButton(icon: _isStarted ? Icon(Icons.mic, color: Colors.green,) :
                                Icon(Icons.mic, color: Colors.red,),
                                onPressed: () => speechTotext(),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: FloatingActionButton(
                          child: Icon(Icons.send),
                          onPressed: () => sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    print("there is messg");
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width * 0.6,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSendByMe ? Colors.lightBlue : Colors.grey,
          borderRadius: isSendByMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24)),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
