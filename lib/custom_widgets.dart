import 'package:flutter/material.dart';

class IconList extends StatelessWidget {
  const IconList({Key key, this.items}) : super(key: key);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyText2;
    return Column(
      children: items
          .map((item) => Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.check,
                            size: style.fontSize, color: Colors.black87),
                      ),
                      Flexible(child: Text(item, style: style, softWrap: true)),
                    ]),
              ))
          .toList(),
    );
  }
}

class BodyText extends StatelessWidget {
  const BodyText({Key key, this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyText2);
  }
}
