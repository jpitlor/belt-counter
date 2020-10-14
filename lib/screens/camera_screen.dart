import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/custom_widgets.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({Key key, @required this.camera}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.ultraHigh);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _takePicture(BuildContext context) async {
    try {
      await _initializeControllerFuture;
      final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');

      await _controller.takePicture(path);
      Navigator.pop(context, path);
    } catch (e) {
      print(e);
    }
  }

  _showInstructions(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyText2;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Instructions'),
              content: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(text: "Use the ", style: style),
                      WidgetSpan(child: Icon(Icons.photo_camera, color: Colors.black87, size: style.fontSize)),
                      TextSpan(
                          text: " button to take a picture, and the app will calculate the chain density", style: style)
                    ]),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                          "Adhere to the following instructions to ensure the density gets calculated correctly",
                          style: style)),
                  IconList(items: [
                    "Ensure the belt is well lit",
                    "Cut a rectangular green piece of paper 1 inch long tall and at least 2 inches wide",
                    "Put the paper on the belt, oriented such that the short side goes in the direction the belt travels",
                  ])
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  textColor: Theme.of(context).primaryColor,
                  child: const Text('Okay, got it!'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                  heroTag: "instructionFab",
                  mini: true,
                  backgroundColor: Theme.of(context).accentColor,
                  child: Icon(Icons.help),
                  onPressed: () => _showInstructions(context))),
          FloatingActionButton(
              heroTag: "takePhotoFab", child: Icon(Icons.camera_alt), onPressed: () => _takePicture(context)),
        ]));
  }
}
