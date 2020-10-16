import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:image/image.dart';
import 'package:tuple/tuple.dart';

Tuple4<int, int, int, int> _marker;

// https://github.com/flutter/flutter/issues/26348
const shift = (0xFF << 24);
Image convertCameraImageToImage(CameraImage image) {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;

    print("uvRowStride: " + uvRowStride.toString());
    print("uvPixelStride: " + uvPixelStride.toString());
    var img = Image(width, height);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = shift | (b << 16) | (g << 8) | r;
      }
    }

    PngEncoder pngEncoder = new PngEncoder(level: 0, filter: 0);
    List<int> png = pngEncoder.encodeImage(img);
    return Image.fromBytes(width, height, png);
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

int getBeltDensity(Image image) {
  var oneInch = _getOneSquareInchOfBelt(image);

  var inBelt = false;
  var belts = 0;
  for (var x = 0; x < oneInch.width; x++) {
    var isWhite = _isWhite(oneInch.getPixel(x, 2));

    if (isWhite && !inBelt) belts++;
    inBelt = isWhite;
  }

  return belts;
}

Image getImageAnnotations(Image image) {
  var annotations = Image(image.width, image.height);

  // var ppi = _getPpi(image);
  // var marker = _findMarker(image);
  //
  // for (var x = marker.item1 - ppi; x < marker.item1; x++) {
  //   var isWhite = _isWhite(image.getPixel(x, marker.item2 + 2));
  //   drawRect(annotations, x, (marker.item2 + (ppi / 2)).floor(), x, marker.item2 + ppi,
  //       isWhite ? Color.fromRgb(255, 255, 255) : Color.fromRgb(0, 0, 0));
  //   drawRect(annotations, x, marker.item2 + 10, x, (marker.item2 + (ppi / 2)).floor(), image.getPixel(x, 2));
  // }
  //
  // drawRect(annotations, marker.item1, marker.item2, marker.item3, marker.item4, Color.fromRgb(255, 0, 0));
  // drawRect(annotations, marker.item1 - ppi, marker.item2, marker.item1, marker.item2 + ppi, Color.fromRgb(0, 255, 0));

  return annotations;
}

Image _getImage(String imagePath) {
  return copyRotate(decodeImage(File(imagePath).readAsBytesSync()), 90);
}

int _getPpi(Image image) {
  var marker = _findMarker(image);
  return min(marker.item4 - marker.item2, marker.item3 - marker.item1);
}

Image _getOneSquareInchOfBelt(Image image) {
  var marker = _findMarker(image);
  int ppi = _getPpi(image);

  return copyRotate(copyCrop(image, marker.item1 - ppi, marker.item2, ppi, ppi), 90);
}

Tuple4<int, int, int, int> _findMarker(Image image) {
  if (_marker != null) return _marker;

  List<Tuple2<int, int>> greens = new List();
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (_isGreen(image.getPixel(x, y))) greens.add(new Tuple2(x, y));
    }
  }

  var x1 = greens.map((x) => x.item1).reduce(min);
  var y1 = greens.map((x) => x.item2).reduce(min);
  var x2 = greens.map((x) => x.item1).reduce(max);
  var y2 = greens.map((x) => x.item2).reduce(max);

  _marker = new Tuple4(x1, y1, x2, y2);
  return _marker;
}

// Color is encoded in a Uint32 as #AABBGGRR
bool _isGreen(int pixel) {
  var red = pixel & 0xFF;
  var green = (pixel & 0xFF00) >> 8;
  var blue = (pixel & 0xFF0000) >> 16;
  var tolerance = 20;

  return green > red + tolerance && green > blue + tolerance;
}

bool _isWhite(int pixel) {
  var red = pixel & 0xFF;
  var green = (pixel & 0xFF00) >> 8;
  var blue = (pixel & 0xFF0000) >> 16;

  var tolerance = 2.0;
  var min = 50;

  return (max(1.0 * red / green, 1.0 * green / red) <= tolerance) &&
      (max(1.0 * red / blue, 1.0 * blue / red) <= tolerance) &&
      (max(1.0 * green / blue, 1.0 * blue / green) <= tolerance) &&
      red >= min &&
      green >= min &&
      blue >= min;
}
