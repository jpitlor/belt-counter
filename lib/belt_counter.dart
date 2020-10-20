import 'dart:math';

import 'package:flutter/material.dart' as material;
import 'package:image/image.dart';
import 'package:tuple/tuple.dart';

import 'util.dart';

class Annotations {
  Annotations({
    Image image,
    Tuple4<int, int, int, int> marker,
    Tuple4<int, int, int, int> sample,
    List<Tuple2<int, int>> chains,
  }) {
    final _marker = Image(image.width, image.height);
    drawRectWithThickness(_marker, marker, material.Colors.green.value, 4);
    drawRectWithThickness(_marker, sample, material.Colors.tealAccent.value, 4);
    this.boxes = encodePng(_marker);

    final _sample = Image(image.width, image.height);
    final padding = image.width ~/ 5;
    drawRectWithThickness(_sample, sample, material.Colors.tealAccent.value, 4);
    drawLine(
      _sample,
      sample.item1,
      sample.item2,
      padding,
      image.height - image.width,
      material.Colors.white.value,
      thickness: 2,
    );
    drawLine(
      _sample,
      sample.item3,
      sample.item2,
      padding + image.width - (2 * padding),
      image.height - image.width,
      material.Colors.white.value,
      thickness: 2,
    );
    drawLine(
      _sample,
      sample.item3,
      sample.item4,
      padding + image.width - (2 * padding),
      image.height - (2 * padding),
      material.Colors.white.value,
      thickness: 2,
    );
    drawLine(
      _sample,
      sample.item1,
      sample.item4,
      padding,
      image.height - (2 * padding),
      material.Colors.white.value,
      thickness: 2,
    );
    copyInto(
      _sample,
      copyRotate(
        copyResize(
          copyCrop(image, sample.item1, sample.item2, sample.item3 - sample.item1, sample.item4 - sample.item2),
          width: image.width - (2 * padding),
          height: image.width - (2 * padding),
        ),
        90,
      ),
      dstX: padding,
      dstY: image.height - image.width,
      srcX: 0,
      srcY: 0,
      srcW: image.width - (2 * padding),
      srcH: image.width - (2 * padding),
    );
    drawRectWithThickness(
      _sample,
      toCoordinates(padding, image.height - image.width, image.width - (2 * padding), image.width - (2 * padding)),
      material.Colors.tealAccent.value,
      4,
    );

    final densities = List<int>();
    final sampleWidth = sample.item3 - sample.item1;
    final enlargedWidth = image.width - (2 * padding);
    for (var y = sample.item2 + 10; y < sample.item4 - 10; y += ((sample.item4 - 10) - (sample.item2 + 10)) ~/ 10) {
      final row = chains.where((element) => element.item2 == y);
      drawString(
        _sample,
        arial_48,
        200, // padding,
        200, // image.height - image.width + y * (enlargedWidth ~/ sampleWidth),
        "->",
        color: material.Colors.white.value,
      );
      densities.add(row.length);
      for (var value in row) {
        final dx = (value.item1 - sample.item1) * (enlargedWidth ~/ sampleWidth);
        final dy = (value.item2 - sample.item2) * (enlargedWidth ~/ sampleWidth);

        drawCircleWithThickness(
          _sample,
          padding + dx,
          image.height - image.width + dy,
          8,
          material.Colors.white.value,
          4,
        );
      }
    }
    this.sample = encodePng(_sample);

    this.density = densities.reduce((value, element) => value + element) ~/ densities.length;
  }

  List<int> boxes;
  List<int> sample;
  int density;
}

Annotations getAnnotations(List<int> bytes) {
  var image = decodeImage(bytes);
  if (image.width > image.height) image = copyRotate(image, 90);

  final marker = _findMarker(image);
  final sample = _findBeltSample(image, marker);

  var inBelt = false;
  final chains = List<Tuple2<int, int>>();
  for (var y = sample.item2 + 10; y < sample.item4 - 10; y += ((sample.item4 - 10) - (sample.item2 + 10)) ~/ 10) {
    inBelt = false;
    for (var x = sample.item1; x < sample.item3; x++) {
      var isWhite = _isWhite(image.getPixel(x, y));
      if (isWhite && !inBelt) chains.add(Tuple2(x, y));
      inBelt = isWhite;
    }
  }

  return Annotations(image: image, marker: marker, sample: sample, chains: chains);
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
