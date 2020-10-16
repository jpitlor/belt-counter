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
  var _imageAnnotations = img.Image(200, 200);

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    try {
      _addCalculatorOverlay();
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _addCalculatorOverlay() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.ultraHigh);
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    // _controller.startImageStream(_onNewImageAvailable);
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
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(children: [
              CameraPreview(_controller),
              Image.memory(_imageAnnotations.getBytes()),
              Container(
                padding: EdgeInsets.all(32.0),
                alignment: Alignment.bottomLeft,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(0),
                      Colors.black12,
                      Colors.black12,
                      Colors.black54,
                      Colors.black87
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
            ]);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        child: Icon(Icons.help),
        onPressed: () =>
            showDialog(context: context, child: InstructionDialog()),
      ),
    );
  }
}
