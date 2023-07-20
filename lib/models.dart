import 'dart:ui';

abstract class Shape {
  final Offset offset;
  final Color color;

  Shape({required this.offset, required this.color});

  bool inScreen(double w, double h, Offset central, double unitFactor);

  bool isPointInShape(Offset point);

  Shape copyWith({Offset? offset});
}

class Rectangle extends Shape {
  final double width;
  final double height;

  Rectangle({
    required super.offset,
    required super.color,
    required this.width,
    required this.height,
  });

  @override
  bool inScreen(double w, double h, Offset central, double unitFactor) {
    if (central.dx + width * unitFactor / 2 <= 0) return false;
    if (central.dx - width * unitFactor / 2 >= w) return false;
    if (central.dy + height * unitFactor / 2 <= 0) return false;
    if (central.dy - height * unitFactor / 2 >= h) return false;

    return true;
  }

  @override
  bool isPointInShape(Offset point) {
    if (point.dx >= offset.dx - width / 2 &&
        point.dx <= offset.dx + width / 2 &&
        point.dy >= offset.dy - height / 2 &&
        point.dy <= offset.dy + height / 2) {
      return true;
    }
    return false;
  }

  @override
  Shape copyWith({Offset? offset}) {
    return Rectangle(
      offset: offset ?? this.offset,
      color: color,
      width: width,
      height: height,
    );
  }
}

class Circle extends Shape {
  final double radius;

  Circle({
    required super.offset,
    required super.color,
    required this.radius,
  });

  @override
  bool inScreen(double w, double h, Offset central, double unitFactor) {
    if (central.dx + radius * unitFactor <= 0) return false;
    if (central.dx - radius * unitFactor >= w) return false;
    if (central.dy + radius * unitFactor <= 0) return false;
    if (central.dy - radius * unitFactor >= h) return false;

    return true;
  }

  @override
  bool isPointInShape(Offset point) {
    if (point.dx >= offset.dx - radius / 2 &&
        point.dx <= offset.dx + radius / 2 &&
        point.dy >= offset.dy - radius / 2 &&
        point.dy <= offset.dy + radius / 2) {
      return true;
    }
    return false;
  }

  @override
  Shape copyWith({Offset? offset}) {
    return Circle(
      offset: offset ?? this.offset,
      color: color,
      radius: radius,
    );
  }
}
