import 'dart:io';

import 'package:belt_counter/belt_counter.dart';
import 'package:belt_counter/camera_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
	MainScreen({Key key, this.title}) : super(key: key);

	final String title;

	@override
	_MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
	int _chainsPerInch = 0;
	String _imagePath = "";

	Future _takePicture() async {
		final camera = (await availableCameras()).first;
		String imagePath = await Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen(camera: camera)));

		int chainsPerInch = getBeltDensity(imagePath);
		markPicture(imagePath);

		setState(() {
		    _chainsPerInch = chainsPerInch;
		    _imagePath = imagePath;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text(widget.title)),
			body: Center(
				child: Padding(
					padding: EdgeInsets.symmetric(vertical: 32.0),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Text('The belt has this many Chains per Inch:'),
							Text('$_chainsPerInch', style: Theme.of(context).textTheme.display1),
							Expanded(
								child: Padding(
									padding: EdgeInsets.only(top: 16.0),
									child: _imagePath != "" ? Image.file(File(_imagePath)) : Text('')
								),
							),
						],
					),
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: _takePicture,
				tooltip: 'New Picture',
				child: Icon(Icons.add_photo_alternate),
			),
		);
	}
}
