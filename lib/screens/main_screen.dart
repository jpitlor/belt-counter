import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './camera_screen.dart';
import '../utils/belt_counter.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class TakePictureButton extends StatelessWidget {
  final Function(int, String) setState;

  TakePictureButton(this.setState);

  Future _takePicture(BuildContext context) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException("", "No cameras available");
      }

      final newScreen = MaterialPageRoute(
          builder: (context) => TakePictureScreen(camera: cameras.first));
      final imagePath = await Navigator.push(context, newScreen);
      if (imagePath == null) {
        // Picture taking cancelled
        return;
      }

      final chainsPerInch = getBeltDensity(imagePath);
      markPicture(imagePath);
      setState(chainsPerInch, imagePath);
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _takePicture(context),
      tooltip: 'New Picture',
      child: Icon(Icons.photo_camera),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  int _chainsPerInch = 0;
  String _imagePath = "";

  _setState(int chainsPerInch, String imagePath) {
    setState(() {
      _chainsPerInch = chainsPerInch;
      _imagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(children: [
        Expanded(
            child: _imagePath != "" ? Image.file(File(_imagePath)) : Text('')),
        Container(
          padding: EdgeInsets.all(32.0),
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black.withAlpha(0),
                Colors.black12,
                Colors.black26,
                Colors.black87,
                Colors.black
              ],
            ),
          ),
          child: Text(
            "$_chainsPerInch Chain${_chainsPerInch != 1 ? "s" : ""} per Inch",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0),
          ),
        ),
      ]),
      floatingActionButton: TakePictureButton(_setState),
    );
  }
}
