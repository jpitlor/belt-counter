import 'package:belt_counter/belt_counter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'instruction_dialog.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _chainsPerInch = 0;
  img.Image _imageAnnotations;
  var _loading = true;

  CameraController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _addCalculatorOverlay();
  }

  void _addCalculatorOverlay() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty == true) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text("No cameras available!")));
      }

      _controller = CameraController(cameras.first, ResolutionPreset.ultraHigh);
      await _controller.initialize();
      // _controller.startImageStream(_onNewImageAvailable);

      setState(() {
        _loading = false;
      });
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _onNewImageAvailable(CameraImage cameraImage) {
    final image = convertCameraImageToImage(cameraImage);
    final chainsPerInch = getBeltDensity(image);
    // final imageAnnotations = getImageAnnotations(image);

    setState(() {
      _chainsPerInch = chainsPerInch;
      // _imageAnnotations = imageAnnotations;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caption = "$_chainsPerInch Chain${_chainsPerInch != 1 ? "s" : ""} per Inch";
    final captionStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0);

    return Scaffold(
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Stack(children: [
              CameraPreview(_controller),
              // Image.memory(_imageAnnotations.getBytes()),
              Container(
                padding: EdgeInsets.all(32.0),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withAlpha(0), Colors.black12, Colors.black12, Colors.black54, Colors.black87],
                  ),
                ),
                child: Text(caption, style: captionStyle),
              ),
            ]),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(Icons.help),
          onPressed: () => showDialog(context: context, child: InstructionDialog())),
    );
  }
}
