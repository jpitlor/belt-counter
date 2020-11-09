import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tuple/tuple.dart';

extension ImageUtils on img.Image {
  void drawRect(Tuple4<int, int, int, int> coordinates, {Color color = Colors.white, int thickness = 4}) {
    for (int i = 0; i < thickness; i++) {
      img.drawRect(
        this,
        coordinates.item1 - i + thickness ~/ 2,
        coordinates.item2 - i + thickness ~/ 2,
        coordinates.item3 + i - thickness ~/ 2,
        coordinates.item4 + i - thickness ~/ 2,
        color.value,
      );
    }
  }

  void drawCircle(int x, int y, int radius, {Color color = Colors.white, int thickness = 1}) {
    for (int i = 0; i < thickness; i++) {
      img.drawCircle(this, x, y, radius - (thickness ~/ 2) + i, color.value);
    }
  }

  void drawLine(int x1, int y1, int x2, int y2, {Color color = Colors.white, int thickness = 2}) {
    img.drawLine(this, x1, y1, x2, y2, color.value, thickness: thickness);
  }
}

extension StringUtils on String {
  String toCountedString(int count) {
    return count == 1 ? "1 $this" : "$count ${this}s";
  }
}

Tuple4<int, int, int, int> toCoordinates(int x, int y, int w, int h) {
  return Tuple4(x, y, x + w, y + h);
}
