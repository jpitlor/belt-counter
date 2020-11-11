import 'dart:math';

import 'package:flutter/material.dart' show Colors;
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
    _marker.drawRect(marker, color: Colors.green);
    _marker.drawRect(sample, color: Colors.tealAccent);
    this.boxes = encodePng(_marker);

    final _sample = Image(image.width, image.height);
    final bigSampleX = image.width ~/ 5;
    final bigSampleY = image.height - image.width;

    final sampleSize = sample.item3 - sample.item1;
    final bigSampleSize = image.width - (2 * bigSampleX);
    final bigSampleSizeRatio = bigSampleSize / sampleSize;

    _sample.drawRect(sample, color: Colors.cyanAccent);
    _sample.drawLine(sample.item1, sample.item2, bigSampleX, bigSampleY);
    _sample.drawLine(sample.item3, sample.item2, bigSampleX + bigSampleSize, bigSampleY);
    _sample.drawLine(sample.item1, sample.item4, bigSampleX, bigSampleY + bigSampleSize);
    _sample.drawLine(sample.item3, sample.item4, bigSampleX + bigSampleSize, bigSampleY + bigSampleSize);
    copyInto(
      _sample,
      copyRotate(
        copyResize(
          copyCrop(image, sample.item1, sample.item2, sampleSize, sampleSize),
          width: bigSampleSize,
          height: bigSampleSize,
        ),
        90,
      ),
      dstX: bigSampleX,
      dstY: bigSampleY,
      srcX: 0,
      srcY: 0,
      srcW: bigSampleSize,
      srcH: bigSampleSize,
    );
    _sample.drawSquare(bigSampleX, bigSampleY, bigSampleSize, color: Colors.cyanAccent);

    final densities = List<int>();
    for (var y = sample.item2 + 10; y < sample.item4 - 10; y += ((sample.item4 - 10) - (sample.item2 + 10)) ~/ 10) {
      final row = chains.where((element) => element.item2 == y);
      densities.add(row.length);
      for (var value in row) {
        final dx = (value.item1 - sample.item1) * bigSampleSizeRatio;
        final dy = (value.item2 - sample.item2) * bigSampleSizeRatio;

        _sample.drawCircle((bigSampleX + dx).floor(), (bigSampleY + dy).floor(), 8, thickness: 3);
      }
    }
    this.sample = encodePng(_sample);

    densities.forEach(print);
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

  final chains = List<Tuple2<int, int>>();
  for (var y = sample.item2 + 10; y < sample.item4 - 10; y += ((sample.item4 - 10) - (sample.item2 + 10)) ~/ 10) {
    final rowChains = image
        .getRowOfPixels(sample.item1, sample.item3, y)
        .map(_averageColorValue)
        .toList()
        .getLocalMaxima()
        .map((i) => Tuple2(sample.item1 + i, y));
    chains.addAll(rowChains);
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
  } else {
    // if (marker.item4 + ppi < image.height)
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

  final x1 = greens.map((x) => x.item1).reduce(min);
  final y1 = greens.map((x) => x.item2).reduce(min);
  final x2 = greens.map((x) => x.item1).reduce(max);
  final y2 = greens.map((x) => x.item2).reduce(max);

  return Tuple4(x1, y1, x2, y2);
}

bool _isGreen(int pixel) {
  final red = pixel & 0xFF;
  final green = (pixel & 0xFF00) >> 8;
  final blue = (pixel & 0xFF0000) >> 16;
  final tolerance = 20;

  return green > red + tolerance && green > blue + tolerance;
}

bool _isWhite(int pixel) {
  final red = pixel & 0xFF;
  final green = (pixel & 0xFF00) >> 8;
  final blue = (pixel & 0xFF0000) >> 16;
  final tolerance = 50;

  return red >= tolerance && green >= tolerance && blue >= tolerance;
}

double _averageColorValue(int pixel) {
  final red = pixel & 0xFF;
  final green = (pixel & 0xFF00) >> 8;
  final blue = (pixel & 0xFF0000) >> 16;

  return (red + green + blue) / 3;
}
