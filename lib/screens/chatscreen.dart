import 'dart:async';
import 'package:chatbot_dialogflow/widgets/messagebubble.dart';
import 'package:chatbot_dialogflow/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter/material.dart';

class ChatApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ChatApp> {

  String _audio_result;
  bool _send = false;

  @override
  void initState() {
    super.initState();
    messages.insert(
      0,
      {'data': 0, 'message': 'Hi'},
    );
  }


  void useMic() {
    print('Using Mic');
    Navigator.pop(context,'UseMic');
  }


  void response(query) async {
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: 'assets/alice-wauc-7878df05e34d.json')
            .build();
    Dialogflow dialogflow =
        await Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);

    setState(() {
      messages.insert(
        0,
        {'data': 0, 'message': response.getMessage()},
      );
    });

    if (response.getMessage() == 'Sure, Turning on Camera') {
      Navigator.pop(context, 'Camera');
    } else if (response.getMessage() == 'Sure, Opening Gallery') {
      Navigator.pop(context, 'Gallery');
    }
  }

  void sendmessage() {
    if (messageController.text.isEmpty) {
      print('empty');
    } else {
      setState(() {
        messages.insert(
          0,
          {'data': 1, 'message': messageController.text},
        );
        _send = false;
      });
      response(messageController.text);
      messageController.clear();
    }
  }


  final messageController = TextEditingController();
  List<Map> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff757575),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: Color(0xffF2FAFF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) => messages[index]['data'] == 0
                      ? MessageBubble(
                          text: messages[index]['message'].toString(),
                          isMe: false,colour: Colors.blue,)
                      : MessageBubble(
                          text: messages[index]['message'].toString(),
                          isMe: true,colour: Colors.blue),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                padding: EdgeInsets.only(bottom: 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                        controller: messageController,
                        decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Send Message',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _send = value != '' ? true : false;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    FloatingActionButton(
                      onPressed: _send ? sendmessage : useMic,
                      child: _send
                          ? Icon(
                              Icons.send,
                              size: 28.0,
                              color: Colors.white,
                            )
                          :  Icon(
                              Icons.mic,
                              size: 32.0,
                              color: Colors.white,
                            ) ,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


