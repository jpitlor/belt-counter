import 'package:belt_counter/custom_widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'display_picture_screen.dart';
import 'instruction_dialog.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<void> _initializeControllerFuture;

  List<CameraDescription> _cameras;
  CameraController _controller;
  var _cameraNumber = 0;

  final _instructionDialog = InstructionDialog();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    availableCameras().then((cameras) {
      _cameras = cameras;
      _initCameraPreview();
    });
  }

  void _flipCamera() {
    _cameraNumber = (_cameraNumber + 1) % _cameras.length;
    _initCameraPreview();
  }

  void _initCameraPreview() async {
    _controller = CameraController(_cameras[_cameraNumber], ResolutionPreset.ultraHigh);
    setState(() {
      _initializeControllerFuture = _controller.initialize();
    });
  }

  void _takePicture(BuildContext context) async {
    final path = join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
    await _controller.takePicture(path);
    await Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: path)));
    _initCameraPreview();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: FutureLoader(
            future: _initializeControllerFuture,
            child: CameraPreview(_controller),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 64.0),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.flip_camera_android, color: Colors.white),
                onPressed: _flipCamera,
              ),
              IconButton(
                icon: Icon(Icons.photo_camera, color: Colors.white),
                iconSize: 48.0,
                onPressed: () => _takePicture(context),
              ),
              IconButton(
                icon: Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => showDialog(context: context, child: _instructionDialog),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
