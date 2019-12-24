import 'package:image/image.dart';

getBeltDensity(String imagePath) {
//	int ppi = getPpi(belt);


	return 1;
}

markPicture(String imagePath) {

}

_getImage(String imagePath) {

}

_writeImage(Image image, String path) {

}

_getPpi(Image belt) {
	for (int y = 0; y < belt.height; y++) {
		for (int x = 0; x < belt.width; x++) {

		}
	}
}

_getOneSquareInchOfBelt(Image belt) {

}

// Color is encoded in a Uint32 as #AABBGGRR
_isGreen(int pixel, double tolerance) {
	int red = pixel & 0xFF;
	int green = (pixel & 0xFF00) >> 2;
	int blue = (pixel & 0xFF0000) >> 4;

	int minGreen = (255 - (tolerance * 255)).ceil();
	int maxNonGreen = (tolerance * 255).ceil();

	return red < maxNonGreen && green > minGreen && blue < maxNonGreen;
}

_isGrey(int pixel, double tolerance) {
	int red = pixel & 0xFF;
	int green = (pixel & 0xFF00) >> 2;
	int blue = (pixel & 0xFF0000) >> 4;

	return ((red / green).abs() <= tolerance)
		&& ((red / blue).abs() <= tolerance)
		&& ((green / blue).abs() <= tolerance);
}