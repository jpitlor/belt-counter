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

  void drawSquare(int x1, int y1, int size, {Color color = Colors.white, int thickness = 4}) {
    for (int i = 0; i < thickness; i++) {
      img.drawRect(
        this,
        x1 - i + thickness ~/ 2,
        y1 - i + thickness ~/ 2,
        x1 + size + i - thickness ~/ 2,
        y1 + size + i - thickness ~/ 2,
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

  List<int> getRowOfPixels(int x1, int x2, int y) {
    var result = List<int>();
    for (var x = x1; x <= x2; x++) {
      result.add(this.getPixel(x, y));
    }

    return result;
  }
}

extension StringUtils on String {
  String toCountedString(int count) {
    return count == 1 ? "1 $this" : "$count ${this}s";
  }
}

extension DoubleListUtils on List<double> {
  List<int> getLocalMaxima() {
    List<int> maxima = new List<int>();
    int tolerance = 15;

    for (var i = 10; i < this.length - 10; i++) {
      var isMaxima = true;

      for (var j = i + 1; j < i + 10; j++) {
        if (this[j] >= this[i] - tolerance) isMaxima = false;
      }

      if (isMaxima) {
        maxima.add(i);
        i += 10;
      }
    }

    return maxima;
  }
}
