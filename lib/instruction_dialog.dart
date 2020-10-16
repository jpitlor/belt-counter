import 'package:flutter/material.dart';

import 'custom_widgets.dart';

class InstructionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyText2;

    return AlertDialog(
      title: const Text('Instructions'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(text: "Use the ", style: style),
              WidgetSpan(
                child: Icon(Icons.photo_camera,
                    color: Colors.black87, size: style.fontSize),
              ),
              TextSpan(
                  text:
                      " button to take a picture, and the app will calculate the chain density",
                  style: style),
            ]),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
                "Adhere to the following instructions to ensure the density gets calculated correctly",
                style: style),
          ),
          IconList(items: [
            "Ensure the belt is well lit",
            "Cut a rectangular green piece of paper 1 inch long tall and at least 2 inches wide",
            "Put the paper on the belt, oriented such that the short side goes in the direction the belt travels",
          ]),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          textColor: Theme.of(context).primaryColor,
          child: const Text('Okay, got it!'),
        ),
      ],
    );
  }
}
