library flutter_shapes;

import 'dart:math';
import 'dart:ui';
import 'dart:developer';

double radians(double degree) {
  return degree * pi / 180;
}

class Shapes {
  Shapes(
      {this.canvas,
        this.paint,
        this.radius = 1,
        this.center = Offset.zero,
        this.angle = 0}) {
    paint ??= Paint();
  }

  static List<String> types = ShapeType.values
      .map((ShapeType type) => type.toString().split('.')[1])
      .toList();

  Canvas? canvas;
  Paint? paint;
  double radius;
  Offset center;
  double angle;

  Rect rect() => Rect.fromCircle(center: Offset.zero, radius: radius);

  void drawCircle() {
    rotate(() {
      canvas!.drawCircle(Offset.zero, radius, paint!);
    });
  }

  void drawRect() {
    rotate(() {
      canvas!.drawRect(rect(), paint!);
    });
  }

  void drawRRect({double? cornerRadius}) {
    rotate(() {
      canvas!.drawRRect(
          RRect.fromRectAndRadius(
              rect(), Radius.circular(cornerRadius ?? radius * 0.2)),
          paint!);
    });
  }

  void drawPolygon(int num, {double initialAngle = 0}) {
    rotate(() {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = radians(initialAngle + 360 / num * i.toDouble());
        final double x = radius * cos(radian);
        final double y = radius * sin(radian);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas!.drawPath(path, paint!);
    });
  }

  Path drawHeart() {
    final Path path = Path();
    // Path path = Path() ;
    rotate(() {
      // // final Path path = Path();
      // path = Path()..moveTo(0, radius)..cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0,
      //     -radius * 0.5)..cubicTo(
      //     radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);

      path.moveTo(0, radius);

      path.cubicTo(-radius * 2, -radius * 0.5, -radius * 0.5, -radius * 1.5, 0, -radius * 0.5);
      path.cubicTo(radius * 0.5, -radius * 1.5, radius * 2, -radius * 0.5, 0, radius);



      canvas!.drawPath(path, paint!);



    });
    return path;
  }

  void drawStar(int num, {double initialAngle = 0}) {
    rotate(() {
      final Path path = Path();
      for (int i = 0; i < num; i++) {
        final double radian = radians(initialAngle + 360 / num * i.toDouble());
        final double x = radius * (i.isEven ? 0.5 : 1) * cos(radian);
        final double y = radius * (i.isEven ? 0.5 : 1) * sin(radian);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas!.drawPath(path, paint!);
    });

  }

  Path? drawType(ShapeType type) {
    switch (type) {

      case ShapeType.Heart:
        return drawHeart();

    }
  }




  Path? draw(String typeString) {
    final ShapeType type = ShapeType.values.firstWhere(
            (ShapeType t) => t.toString() == 'ShapeType.$typeString',
        orElse: () => ShapeType.Circle);
    // drawType(type);
    return drawType(type);
  }

  void rotate(VoidCallback callback) {
    canvas!.save();
    canvas!.translate(center.dx, center.dy);
    canvas!.rotate(angle);
    callback();
    canvas!.restore();
  }
}

enum ShapeType {
  Circle,
  Rect,
  RoundedRect,
  Triangle,
  Diamond,
  Pentagon,
  Hexagon,
  Octagon,
  Decagon,
  Dodecagon,
  Heart,
  Star5,
  Star6,
  Star7,
  Star8,
}