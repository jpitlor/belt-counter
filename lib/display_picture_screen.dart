import 'dart:io';

import 'package:flutter/material.dart';

import 'belt_counter.dart';
import 'util.dart';

enum AnnotationTypes { Boxes, Sample, Density }

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<int> _image;
  Annotations _annotations;

  bool _showBoxAnnotations = true;
  bool _showSampleAnnotation = true;
  bool _showDensityAnnotation = true;

  @override
  void initState() {
    super.initState();
    var image = File(widget.imagePath).readAsBytesSync();
    final annotations = getAnnotations(image);
    setState(() {
      _image = image;
      _annotations = annotations;
    });
  }

  void toggleAnnotations(AnnotationTypes result) {
    setState(() {
      switch (result) {
        case AnnotationTypes.Boxes:
          _showBoxAnnotations = !_showBoxAnnotations;
          break;
        case AnnotationTypes.Sample:
          _showSampleAnnotation = !_showSampleAnnotation;
          break;
        case AnnotationTypes.Density:
          _showDensityAnnotation = !_showDensityAnnotation;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screen = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withAlpha(0),
        shadowColor: Colors.white.withAlpha(0),
        elevation: 0,
        actions: [
          PopupMenuButton<AnnotationTypes>(
            onSelected: toggleAnnotations,
            itemBuilder: (_context) => [
              CheckedPopupMenuItem(
                checked: _showBoxAnnotations,
                value: AnnotationTypes.Boxes,
                child: Text("Highlight Marker"),
              ),
              CheckedPopupMenuItem(
                checked: _showSampleAnnotation,
                value: AnnotationTypes.Sample,
                child: Text("Enlarge Sample"),
              ),
              CheckedPopupMenuItem(
                checked: _showDensityAnnotation,
                value: AnnotationTypes.Density,
                child: Text("Show Density"),
              ),
            ],
          )
        ],
      ),
      body: _annotations == null
          ? Center(child: CircularProgressIndicator())
          : Stack(children: [
              Positioned(
                left: 0,
                top: 0,
                width: screen.width,
                height: screen.height,
                child: Image.memory(_image),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: screen.width,
                height: screen.height,
                child: AnimatedOpacity(
                  opacity: _showBoxAnnotations ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Image.memory(_annotations.boxes),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: screen.width,
                height: screen.height,
                child: AnimatedOpacity(
                  opacity: _showSampleAnnotation ? 1 : 0,
                  duration: Duration(milliseconds: 200),
                  child: Image.memory(_annotations.sample),
                ),
              ),
              AnimatedOpacity(
                opacity: _showDensityAnnotation ? 1 : 0,
                duration: Duration(milliseconds: 200),
                child: Container(
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
                    "${"Chain".toCountedString(_annotations.density)} per Inch",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
              ),
            ]),
    );
  }
}
