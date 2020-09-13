import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.isMe,this.colour});

  //final String sender;
  final String text;
  final bool isMe;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
//            borderRadius: isMe
//                ? BorderRadius.only(
//                topLeft: Radius.circular(30.0),
//                topRight: Radius.circular(2.5),
//                bottomRight: Radius.circular(25.0),
//                bottomLeft: Radius.circular(30.0))
//                : BorderRadius.only(
//                topLeft: Radius.circular(2.5),
//                topRight: Radius.circular(30.0),
//                bottomRight: Radius.circular(25.0),
//                bottomLeft: Radius.circular(30.0)),
            elevation: 3,
            color: isMe ? colour : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '$text',
                textAlign: isMe ? TextAlign.end : TextAlign.start,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
