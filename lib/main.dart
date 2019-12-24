import 'package:flutter/material.dart';
import 'app.dart';

void main() => runApp(App());

class App extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Belt Density Counter',
			theme: ThemeData(
				primarySwatch: Colors.indigo,
			),
			home: MainScreen(title: 'Belt Density Counter'),
		);
	}
}
