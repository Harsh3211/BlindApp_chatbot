import 'dart:async';
import 'package:chatbot_dialogflow/widgets/messagebubble.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:avatar_glow/avatar_glow.dart';

void main() {
  runApp(new SpeechApp());
}

class SpeechApp extends StatefulWidget {
  @override
  _SpeechAppState createState() => new _SpeechAppState();
}

class _SpeechAppState extends State<SpeechApp> {
  final messageController = TextEditingController();
  List<Map> messages = [];
  bool _send = false;

  SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = 'Audio Input';

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
    messages.insert(
      0,
      {'data': 0, 'message': 'Hi'},
    );
  }

  @override
  void dispose() {
    super.dispose();
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
    if (transcription.isEmpty) {
      print('empty');
    } else {
      setState(() {
        messages.insert(
          0,
          {'data': 1, 'message': transcription.toString()},
        );
        _send = false;
      });
      response(transcription.toString());
      transcription = '';
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    //print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
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
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        messages[index]['data'] == 0
                            ? MessageBubble(
                                text: messages[index]['message'].toString(),
                                isMe: false,colour:Colors.cyan.shade600)
                            : MessageBubble(
                                text: messages[index]['message'].toString(),
                                isMe: true,colour:Colors.cyan.shade600),
                  ),
                  flex: 4,
                ),
                Expanded(
                  child: ListView(
                    reverse: true,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30.0),
                        margin: EdgeInsets.only(top: 60.0),
                        color: Color(0xffF2FAFF),
                        child: Text(
                          transcription,
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.cyan.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AvatarGlow(
                  animate: _isListening,
                  glowColor: Colors.cyan.shade600,
                  endRadius: 50.0,
                  duration: const Duration(milliseconds: 1200),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: new FloatingActionButton(
                    onPressed: () {
                      _speechRecognitionAvailable && !_isListening
                          ? start()
                          : null;
                    },
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.cyan.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void start() => _speech.listen(locale: 'en_IN').then((result) {
        //print(result);
        //print('_MyAppState.start => result ${result}');
      });

  void cancel() => _speech.cancel().then((result) => setState(() {
        _isListening = result;
        //print(result);
      }));

  void stop() => _speech.stop().then((result) => setState(() {
        _isListening = result;
        //print(result);
      }));

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onRecognitionStarted() => setState(() {
        _isListening = true;
        //print('Audio Started');
      });

  void onRecognitionResult(String text) => setState(() {
        transcription = text;
        //print('Transcription is $transcription');
      });

  void onRecognitionComplete() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isListening = false;
        sendmessage();
      });
    });
  }
}
