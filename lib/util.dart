import 'package:image/image.dart';
import 'package:tuple/tuple.dart';

String toCountedString(String base, int count) {
  return count == 1 ? "1 $base" : "$count ${base}s";
}

void drawRectWithThickness(Image image, Tuple4<int, int, int, int> coordinates, int color, int thickness) {
  for (int i = 0; i < thickness; i++) {
    drawRect(
      image,
      coordinates.item1 - i + thickness ~/ 2,
      coordinates.item2 - i + thickness ~/ 2,
      coordinates.item3 + i - thickness ~/ 2,
      coordinates.item4 + i - thickness ~/ 2,
      color,
    );
  }
}

void drawCircleWithThickness(Image image, int x, int y, int radius, int color, int thickness) {
  for (int i = 0; i < thickness; i++) {
    drawCircle(image, x, y, radius - (thickness ~/ 2) + i, color);
  }
}

Tuple4<int, int, int, int> toCoordinates(int x, int y, int w, int h) {
  return Tuple4(x, y, x + w, y + h);
}
