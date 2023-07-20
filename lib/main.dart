import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:vibration/vibration.dart';

import 'axis.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: App(
        screenWidth: MediaQuery.of(context).size.width,
        screenHeight: MediaQuery.of(context).size.height,
      ),
    );
  }
}

class App extends StatefulWidget {
  const App({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  final double screenWidth;
  final double screenHeight;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Offset centralPoint, oldCentralPoint;
  late Offset oldStartDrag;
  Offset? touchCenter;
  late double scale, oldScale;
  late double unitStep;

  List<Shape> shapes = [];

  int movingShapeIndex = -1;
  Offset? currentMoving;

  @override
  void initState() {
    super.initState();

    centralPoint = Offset(widget.screenWidth / 2, widget.screenHeight / 2);
    oldCentralPoint = centralPoint;

    scale = 1.0;
    oldScale = scale;
    unitStep = 25.0;
  }

  Offset getCentralAxisPoint() {
    Offset central = Offset(widget.screenWidth / 2, widget.screenHeight / 2);
    return getPointAxis(central);
  }

  Offset getPointAxis(Offset offset) {
    Offset distance = offset - centralPoint;

    Offset axisOffset =
        Offset(distance.dx / (scale * 25), -(distance.dy / (scale * 25)));
    return axisOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            XGestureDetector(
              onLongPress: (event) {
                Offset axis = getPointAxis(event.position);

                movingShapeIndex = -1;
                for (int i = shapes.length - 1; i >= 0; i--) {
                  if (shapes[i].isPointInShape(axis)) {
                    print("move index: ${i}");
                    movingShapeIndex = i;
                    Future.delayed(Duration.zero, () => Vibration.vibrate(duration: 200));
                    break;
                  }
                }
              },
              onLongPressMove: (event) {
                setState(() {
                  currentMoving = getPointAxis(event.position);
                });
              },
              onLongPressEnd: () {
                if (movingShapeIndex != -1 && currentMoving != null) {
                  final item =
                      shapes[movingShapeIndex].copyWith(offset: currentMoving!);
                  shapes.removeAt(movingShapeIndex);
                  shapes.add(item);

                  setState(() {
                    movingShapeIndex = -1;
                    currentMoving = null;
                  });
                }
              },
              onMoveStart: (event) {
                oldStartDrag = Offset(event.localPos.dx, event.localPos.dy);
                oldCentralPoint = centralPoint;
              },
              onMoveUpdate: (event) {
                final distance = event.localPos - oldStartDrag;
                centralPoint = oldCentralPoint + distance;

                setState(() {});
              },
              onScaleStart: (initialFocusPoint) {
                oldScale = scale;
                oldCentralPoint = centralPoint;
                touchCenter = null;
              },
              onScaleUpdate: (event) {
                scale = oldScale * event.scale;

                touchCenter ??= event.focalPoint;

                if (scale >= 0.2 && scale <= 5 && touchCenter != null) {
                  var dis = touchCenter! - oldCentralPoint;
                  dis *= event.scale;

                  centralPoint = touchCenter! - dis;
                } else {
                  if (scale > 5) scale = 5;
                  if (scale < 0.2) scale = 0.2;
                }

                setState(() {});
              },
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: MyAxis(
                    centralPoint: centralPoint,
                    scale: scale,
                    unitStep: unitStep,
                    shapes: shapes,
                    movingShapeIndex: movingShapeIndex,
                    currentMoving: currentMoving,
                  ),
                  child: Container(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    InkWell(
                      onTap: () {
                        print("Add: ${getCentralAxisPoint()}");

                        var circle = Circle(
                            offset: getCentralAxisPoint(),
                            color: _randomColor(),
                            radius: _random().toDouble());
                        shapes.add(circle);
                        setState(() {});
                      },
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        print("Add: ${getCentralAxisPoint()}");

                        var rect = Rectangle(
                            offset: getCentralAxisPoint(),
                            color: _randomColor(),
                            width: _random().toDouble(),
                            height: _random().toDouble());
                        shapes.add(rect);
                        setState(() {});
                      },
                      child: Card(
                        elevation: 10,
                        child: Container(
                          width: 50,
                          height: 50,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _random() {
    return (Random().nextInt(11) + 10) / 10;
  }

  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.pink,
    Colors.cyan
  ];

  Color _randomColor() {
    return colors[Random().nextInt(colors.length)];
  }
}
