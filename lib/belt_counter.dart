import 'dart:developer' as Logger;
import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';
import 'package:tuple/tuple.dart';

Tuple4<int, int, int, int> _marker;

int getBeltDensity(String imagePath) {
	Image image = _getImage(imagePath);
	Image oneInch = _getOneSquareInchOfBelt(image);
	oneInch = copyRotate(oneInch, 90);

	bool inBelt = false;
	int belts = 0;
	for (int x = 0; x < oneInch.width; x++) {
		bool isWhite = _isWhite(oneInch.getPixel(x, 2));
		Logger.log("$x: $isWhite");

		if (isWhite && !inBelt) belts++;
		inBelt = isWhite;
	}

	return belts;
}

markPicture(String imagePath) {
	Image image = _getImage(imagePath);

	Tuple4<int, int, int, int> marker = _findMarker(image);
	drawRect(image, marker.item1, marker.item2, marker.item3, marker.item4, Color.fromRgb(255, 0, 0));


//	image = _getOneSquareInchOfBelt(image);
	image = copyRotate(image, 90);
	File(imagePath).writeAsBytesSync(encodePng(image));
}

Image _getImage(String imagePath) {
	return decodeImage(File(imagePath).readAsBytesSync());
}

int _getPpi(Image image) {
	Tuple4<int, int, int, int> marker = _findMarker(image);
	return marker.item4 - marker.item2;
}

Image _getOneSquareInchOfBelt(Image image) {
	Tuple4<int, int, int, int> marker = _findMarker(image);
	int ppi = _getPpi(image);

	int x = marker.item1 < ppi ? marker.item3 + 1 : marker.item1 - ppi;
	return copyCrop(image, x, marker.item2, ppi, ppi);
}

Tuple4<int, int, int, int> _findMarker(Image image) {
	if (_marker != null) return _marker;

	List<Tuple2<int, int>> greens = new List();
	for (int y = 0; y < image.height; y++) {
		for (int x = 0; x < image.width; x++) {
			if (_isGreen(image.getPixel(x, y))) greens.add(new Tuple2(x, y));
		}
	}

	int x1 = greens.map((x) => x.item1).reduce(min);
	int y1 = greens.map((x) => x.item2).reduce(min);
	int x2 = greens.map((x) => x.item1).reduce(max);
	int y2 = greens.map((x) => x.item2).reduce(max);
	
	var marker = new Tuple4(x1, y1, x2, y2);
	_marker = marker;
	return marker;
}

// Color is encoded in a Uint32 as #AABBGGRR
bool _isGreen(int pixel) {
	int red = pixel & 0xFF;
	int green = (pixel & 0xFF00) >> 8;
	int blue = (pixel & 0xFF0000) >> 16;

	int minGreen = 150;
	int maxNonGreen = 130;

	return red < maxNonGreen && green > minGreen && blue < maxNonGreen;
}

bool _isWhite(int pixel) {
	int red = pixel & 0xFF;
	int green = (pixel & 0xFF00) >> 8;
	int blue = (pixel & 0xFF0000) >> 16;

	Logger.log("Checking RGB $red $green $blue (${pixel.toRadixString(16)})");

	int min = 100;

	return ((red / green).abs() <= 1.05)
		&& ((red / blue).abs() <= 1.05)
		&& ((green / blue).abs() <= 1.05)
		&& red >= min && green >= min && blue >= min;
}