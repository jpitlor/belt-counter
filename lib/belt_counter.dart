import 'dart:math';

import 'package:image/image.dart';
import 'package:tuple/tuple.dart';

class Annotations {
  const Annotations({this.marker, this.sample, this.chains, this.density});

  final Tuple4<int, int, int, int> marker;
  final Tuple4<int, int, int, int> sample;
  final List<Tuple2<int, int>> chains;
  final int density;
}

Annotations getAnnotations(List<int> bytes) {
  var image = decodeImage(bytes);
  if (image.width > image.height) image = copyRotate(image, 90);

  final marker = _findMarker(image);
  final sample = _findBeltSample(image, marker);

  var inBelt = false;
  var belts = 0;
  for (var x = 0; x < sample.item4 - sample.item2; x++) {
    var isWhite = _isWhite(image.getPixel(x, 2));

    if (isWhite && !inBelt) belts++;
    inBelt = isWhite;
  }

  return Annotations(marker: marker, sample: sample, chains: null, density: belts);
}

Tuple4<int, int, int, int> _findBeltSample(Image image, Tuple4<int, int, int, int> marker) {
  final ppi = min(marker.item4 - marker.item2, marker.item3 - marker.item1);
  if (marker.item1 - ppi > 0) {
    // Left
    return Tuple4(marker.item1 - ppi, marker.item2, marker.item1, marker.item2 + ppi);
  } else if (marker.item2 - ppi > 0) {
    // Top
    return Tuple4(marker.item1, marker.item2 - ppi, marker.item1 + ppi, marker.item2);
  } else if (marker.item3 + ppi < image.width) {
    // Right
    return Tuple4(marker.item3, marker.item4 - ppi, marker.item3 + ppi, marker.item4);
  } else /* if (marker.item4 + ppi < image.height) */ {
    // Bottom
    return Tuple4(marker.item3 - ppi, marker.item4, marker.item3, marker.item4 + ppi);
  }
}

Tuple4<int, int, int, int> _findMarker(Image image) {
  List<Tuple2<int, int>> greens = List();
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (_isGreen(image.getPixel(x, y))) greens.add(Tuple2(x, y));
    }
  }

  var x1 = greens.map((x) => x.item1).reduce(min);
  var y1 = greens.map((x) => x.item2).reduce(min);
  var x2 = greens.map((x) => x.item1).reduce(max);
  var y2 = greens.map((x) => x.item2).reduce(max);

  print("($x1, $y1) -> ($x2, $y2)");
  print("${image.width} x ${image.height}");

  return Tuple4(x1, y1, x2, y2);
}

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
