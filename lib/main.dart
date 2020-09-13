import 'package:camera/camera.dart';
import 'package:chatbot_dialogflow/screens/speechscreen.dart';
import 'package:chatbot_dialogflow/stream/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:io';
import 'model.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/chatscreen.dart';

List<CameraDescription> cameras;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e);
  }

  runApp(
    MaterialApp(
        home: MyApp(),
      debugShowCheckedModeBanner: false,
//      initialRoute: '/',
//      routes: {
//        '/': (context) => MyApp(),
//        '/live': (context) => NewStream(),
//      },
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _image;
  List _recognitions;
  double _imageHeight;
  double _imageWidth;
  bool _loadingSpinner = false;
  int accuracy = 50; // % minimum accuracy required in integer
  // ignore: non_constant_identifier_names
  String _intentChat;

  Future galleryImagePicker() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _loadingSpinner = true;
    });
    predictImage(image);
  }

  Future cameraImagePicker() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _loadingSpinner = true;
    });
    predictImage(image);
  }

  Future predictImage(File image) async {
    if (image == null) return;
    var recognitions = await Model().ssdMobileNet(image);
    setState(() {
      _recognitions = recognitions;
    });
    new FileImage(image).resolve(new ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          setState(() {
            _imageHeight = info.image.height.toDouble();
            _imageWidth = info.image.width.toDouble();
          });
        },
      ),
    );
    setState(() {
      _image = image;
      _loadingSpinner = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _loadingSpinner = true;

    Model().loadModel().then((val) {
      setState(() {
        _loadingSpinner = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Get Screen Size
    List<Widget> stackChildren = [];

    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        child: _image == null
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(child: Text('No Image selected.')),
              )
            : Image.file(_image),
      ),
    );

    // Render Boxes
    stackChildren.addAll(
      Model().renderBoxes(
        size,
        _recognitions,
        _imageHeight,
        _imageWidth,
        accuracy,
      ),
    );

    if (_loadingSpinner) {
      stackChildren.add(
        const Opacity(
          child: ModalBarrier(dismissible: false, color: Colors.grey),
          opacity: 0.3,
        ),
      );
      stackChildren.add(
        const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: _image != null ? 80.0 : 150.0,
          elevation: 0.0,
          backgroundColor: Colors.blue,
          title: Text(
            'Blind App',
            style: TextStyle(
              fontSize: _image != null ? 28.0 : 40.0,
            ),
          ),
          actions: <Widget>[
//            FloatingActionButton(
//              mini: true,
//              onPressed: () async {
//                if (await Permission.camera.request().isGranted) {
//                  print('Button pressed');
//                  try {
//                    Navigator.pushNamed(context, '/live');
//                    print('Route Executed');
//                  } catch (e) {
//                    print('Error Occured');
//                    print(e);
//                  }
//                } else if (await Permission.camera.isPermanentlyDenied) {
//                  openAppSettings();
//                }
//              },
//              child: Icon(
//                Icons.live_tv,
//                color: Colors.blue,
//                size: 22.0,
//              ),
//              backgroundColor: Colors.white,
//            ),
            SizedBox(
              width: 10.0,
            ),
            FloatingActionButton(
              mini: true,
              onPressed: () async {
                if (await Permission.camera.request().isGranted) {
                  print('Button pressed');
                  try {
                    cameraImagePicker();
                    print('Route Executed');
                  } catch (e) {
                    print('Error Occured');
                    print(e);
                  }
                } else if (await Permission.camera.isPermanentlyDenied) {
                  openAppSettings();
                }
              },
              child: Icon(
                Icons.camera_alt,
                color: Colors.blue,
                size: 22.0,
              ),
              backgroundColor: Colors.white,
            ),
            SizedBox(
              width: 10.0,
            ),
            FloatingActionButton(
              mini: true,
              onPressed: () async {
                if (await Permission.mediaLibrary.request().isGranted) {
                  print('Button pressed');
                  try {
                    galleryImagePicker();
                    print('Route Executed');
                  } catch (e) {
                    print('Error Occured');
                    print(e);
                  }
                } else if (await Permission.mediaLibrary.isDenied) {
                  openAppSettings();
                }
              },
              child: Icon(
                Icons.image,
                color: Colors.blue,
                size: 22.0,
              ),
              backgroundColor: Colors.white,
            ),
            SizedBox(
              width: 10.0,
            ),
            FloatingActionButton(
              mini: true,
              onPressed: () async {
                _intentChat = await showModalBottomSheet<String>(
                  context: context,
                  builder: (context) => ChatApp(),
                );
                if (_intentChat == 'Camera') {
                  setState(() {
                    _loadingSpinner = false;
                  });
                  cameraImagePicker();
                  print('Opening Camera');
                } else if (_intentChat == 'Gallery') {
                  setState(() {
                    _loadingSpinner = false;
                  });
                  galleryImagePicker();
                  print('Opening Gallery');
                } else if (_intentChat == 'UseMic') {
                  if (await Permission.microphone.request().isGranted) {
                    _intentChat = await showModalBottomSheet<String>(
                      context: context,
                      builder: (context) => SpeechApp(),
                    );
                  } else if (await Permission.speech.isPermanentlyDenied) {
                    print('Microphone Disabled');
                    openAppSettings();
                  }
                }
              },
              child: Icon(
                Icons.chat,
                color: Colors.blue,
                size: 22.0,
              ),
              backgroundColor: Colors.white,
            ),
            SizedBox(
              width: 15.0,
            ),
          ],
        ),
        body: Container(
          color: Colors.blue,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: Color(0xffF2FAFF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(2.0, 20.0, 2.0, 0.0),
              child: Stack(
                children: stackChildren,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (await Permission.microphone.request().isGranted) {
              _intentChat = await showModalBottomSheet<String>(
                context: context,
                builder: (context) => SpeechApp(),
              );

              if (_intentChat == 'Camera') {
                setState(() {
                  _loadingSpinner = false;
                });
                cameraImagePicker();
                print('Opening Camera');
              } else if (_intentChat == 'Gallery') {
                setState(() {
                  _loadingSpinner = false;
                });
                galleryImagePicker();
                print('Opening Gallery');
              }
            } else if (await Permission.speech.isPermanentlyDenied) {
              print('Microphone Disabled');
              openAppSettings();
            }
          },
          tooltip: 'Pick Image',
          child: Icon(Icons.mic),
        ),
      ),
    );
  }
}
