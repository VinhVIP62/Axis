import 'package:flutter/material.dart';

import 'models.dart';

class MyAxis extends CustomPainter {
  Offset centralPoint;
  double scale = 1.0;
  double unitStep = 25;

  List<Shape> shapes;

  int movingShapeIndex = -1;
  Offset? currentMoving;

  MyAxis({
    required this.centralPoint,
    required this.scale,
    required this.unitStep,
    required this.shapes,
    this.movingShapeIndex = -1,
    this.currentMoving,
  });

  var linePaint = Paint()
    ..color = Colors.black45
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.round;

  var gridPaint = Paint()
    ..color = Colors.black12
    ..strokeWidth = 0.5
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, centralPoint.dy),
        Offset(size.width, centralPoint.dy), linePaint);
    canvas.drawLine(Offset(centralPoint.dx, 0),
        Offset(centralPoint.dx, size.height), linePaint);

    _drawUnit(canvas, size);
    _drawShape(canvas, size);
    _drawMovingShape(canvas, size);
  }

  List<double> configScale = [0.4, 0.75, 1.5, 3, 5];
  List<double> configUnitStep = [3, 2, 1, 0.5, 0.25];

  Offset toRealPoint(Offset point) {
    double x = centralPoint.dx + point.dx * scale * unitStep;
    double y = centralPoint.dy - point.dy * scale * unitStep;

    return Offset(x, y);
  }

  double toRealLength(double axisLength) {
    return axisLength * unitStep * scale;
  }

  _drawUnit(Canvas canvas, Size size) {
    double i = -(centralPoint.dx / (unitStep * scale));

    int indexConfig = 0;
    for (int j = 0; j < configScale.length; j++) {
      if (scale <= configScale[j]) {
        indexConfig = j;
        break;
      }
    }

    i = (i / configUnitStep[indexConfig]).floor() * configUnitStep[indexConfig];

    while (true) {
      double x = centralPoint.dx + i * (unitStep * scale);

      if (i != 0) {
        canvas.drawLine(Offset(x, centralPoint.dy - 2),
            Offset(x, centralPoint.dy + 2), linePaint);

        if (i == i.toInt()) {
          _drawGrid(canvas, Offset(x, centralPoint.dy), size);

          _drawText(
              canvas, Offset(x, centralPoint.dy + 10), "${i.toInt()}", true);
        } else {
          _drawText(canvas, Offset(x, centralPoint.dy + 10), "$i", true);
        }
      }

      if (x > size.width) break;
      i += configUnitStep[indexConfig];
    }

    double j = -(centralPoint.dy / (unitStep * scale));
    j = (j / configUnitStep[indexConfig]).floor() * configUnitStep[indexConfig];

    while (true) {
      double y = centralPoint.dy + j * (unitStep * scale);

      if (j != 0) {
        canvas.drawLine(Offset(centralPoint.dx - 2, y),
            Offset(centralPoint.dx + 2, y), linePaint);
        if (j == j.toInt()) {
          _drawGrid(canvas, Offset(centralPoint.dx, y), size);
          _drawText(
              canvas, Offset(centralPoint.dx + 10, y), "${-j.toInt()}", false);
        } else {
          _drawText(canvas, Offset(centralPoint.dx + 10, y), "${-j}", false);
        }
      }

      if (y > size.height) break;
      j += configUnitStep[indexConfig];
    }
  }

  _drawText(Canvas canvas, Offset offset, String text, bool isDrawXAxis) {
    const textStyle = TextStyle(color: Colors.black54, fontSize: 10);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: 0);
    if (isDrawXAxis) {
      textPainter.paint(
          canvas, Offset(offset.dx - textPainter.size.width / 2, offset.dy));
    } else {
      textPainter.paint(
          canvas, Offset(offset.dx, offset.dy - textPainter.size.height / 2));
    }
  }

  _drawGrid(Canvas canvas, Offset point, Size size) {
    canvas.drawLine(
        Offset(0, point.dy), Offset(size.width, point.dy), gridPaint);
    canvas.drawLine(
        Offset(point.dx, 0), Offset(point.dx, size.height), gridPaint);
  }

  _drawShape(Canvas canvas, Size size) {
    for (int i = 0; i < shapes.length; i++) {
      if (i == movingShapeIndex) continue;

      final item = shapes[i];

      if (item.inScreen(size.width, size.height, toRealPoint(item.offset),
          unitStep * scale)) {
        if (item is Circle) {
          canvas.drawCircle(
            toRealPoint(item.offset),
            toRealLength(item.radius),
            Paint()..color = item.color,
          );
        } else if (item is Rectangle) {
          canvas.drawRect(
            Rect.fromCenter(
              center: toRealPoint(item.offset),
              width: toRealLength(item.width),
              height: toRealLength(item.height),
            ),
            Paint()..color = item.color,
          );
        }
      }
    }
  }

  _drawMovingShape(Canvas canvas, Size size) {
    if (movingShapeIndex != -1 &&
        movingShapeIndex < shapes.length &&
        currentMoving != null) {
      final item = shapes[movingShapeIndex];

      if (item is Circle) {
        canvas.drawCircle(
          toRealPoint(currentMoving!),
          toRealLength(item.radius),
          Paint()..color = item.color,
        );
      } else if (item is Rectangle) {
        canvas.drawRect(
          Rect.fromCenter(
            center: toRealPoint(currentMoving!),
            width: toRealLength(item.width),
            height: toRealLength(item.height),
          ),
          Paint()..color = item.color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
