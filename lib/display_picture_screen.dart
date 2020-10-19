import 'dart:io';

import 'package:flutter/material.dart';

import 'belt_counter.dart';
import 'custom_widgets.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var image = File(imagePath).readAsBytesSync();
    final annotations = getAnnotations(image);
    var screen = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.white.withAlpha(0), shadowColor: Colors.white.withAlpha(0), elevation: 0),
      body: Stack(children: [
        Positioned(
          left: 0,
          top: 0,
          width: screen.width,
          height: screen.height,
          child: Image.memory(image),
        ),
        Positioned(
          left: annotations.marker.item1.toDouble(),
          top: annotations.marker.item2.toDouble(),
          width: (annotations.marker.item3 - annotations.marker.item1).toDouble(),
          height: (annotations.marker.item4 - annotations.marker.item2).toDouble(),
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 4.0)),
          ),
        ),
        // Positioned(
        //   left: annotations.sample.item1.toDouble(),
        //   top: annotations.sample.item2.toDouble(),
        //   width: (annotations.sample.item3 - annotations.sample.item1).toDouble(),
        //   height: (annotations.sample.item4 - annotations.sample.item2).toDouble(),
        //   child: Container(
        //     decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey, width: 4.0)),
        //   ),
        // ),
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
          child: Text(
            "${toCountedString("Chain", annotations.density)} per Inch",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
        ),
      ]),
    );
  }
}
