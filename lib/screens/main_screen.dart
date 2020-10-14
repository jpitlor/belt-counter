import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import './camera_screen.dart';
import '../utils/belt_counter.dart';
import '../utils/custom_widgets.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

Future _takePicture(BuildContext context, Function(int, String) setState) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException("", "No cameras available");
    }

    final newScreen = MaterialPageRoute(builder: (context) => TakePictureScreen(camera: cameras.first));
    final imagePath = await Navigator.push(context, newScreen);
    if (imagePath == null) {
      // Picture taking cancelled
      return;
    }

    final chainsPerInch = getBeltDensity(imagePath, annotatePicture: true);
    setState(chainsPerInch, imagePath);
  } catch (e) {
    final snackBar = SnackBar(content: Text(e.toString()));
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

class _MainScreenState extends State<MainScreen> {
  var _chainsPerInch = 0;
  var _imagePath = "";

  _setState(int chainsPerInch, String imagePath) {
    setState(() {
      _chainsPerInch = chainsPerInch;
      _imagePath = imagePath;
    });
  }

  Widget _buildEmptyState() {
    final style = Theme.of(context).textTheme.bodyText2;

    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
            child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: "Use the ", style: style),
                        WidgetSpan(child: Icon(Icons.photo_camera, color: Colors.black87, size: style.fontSize)),
                        TextSpan(
                            text: " button to take a picture, and the app will calculate the chain density",
                            style: style)
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
                    ]),
                    Builder(
                        builder: (context) => Padding(
                            padding: EdgeInsets.only(top: 32.0),
                            child: ElevatedButton.icon(
                                onPressed: () => _takePicture(context, _setState),
                                icon: Icon(Icons.photo_camera),
                                label: Text("Take Picture"))))
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    if (_imagePath == "") {
      return _buildEmptyState();
    }

    final caption = "$_chainsPerInch Chain${_chainsPerInch != 1 ? "s" : ""} per Inch";
    return Scaffold(
      body: Stack(children: [
        Expanded(child: Image.file(File(_imagePath))),
        Container(
          padding: EdgeInsets.all(32.0),
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withAlpha(0), Colors.black12, Colors.black26, Colors.black87, Colors.black],
            ),
          ),
          child: Text(caption, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0)),
        ),
      ]),
      floatingActionButton: Builder(
        builder: (innerContext) => FloatingActionButton(
          onPressed: () => _takePicture(innerContext, _setState),
          tooltip: 'New Picture',
          child: Icon(Icons.photo_camera),
        ),
      ),
    );
  }
}
