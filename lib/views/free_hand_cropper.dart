import 'package:flutter/material.dart';

class FreeHandCropper extends StatefulWidget {
  @override
  _FreeHandCropperState createState() => _FreeHandCropperState();
}

class _FreeHandCropperState extends State<FreeHandCropper> {
  List<Offset> _points = <Offset>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox object = context.findRenderObject() as RenderBox;
                    Offset _localPosition =
                    object.globalToLocal(details.globalPosition);
                    _points = new List.from(_points)..add(_localPosition);
                  });
                },
                // onPanEnd: (details) => _points.add(null),
                onPanEnd: (details) => _points.add(Offset(0,0)),
                child: CustomPaint(
                  painter: FreeHandPainter(_points),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.red,
            child: Text("Container"),
          ),
          MaterialButton(
            child: Text("Crop"),
            onPressed: () {
              // Do cropping logic here
              // e.g. using _points to draw a Path and crop the image
            },
          ),
        ],
      ),
    );
  }
}

class FreeHandPainter extends CustomPainter {
  List<Offset> points;

  FreeHandPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(FreeHandPainter oldDelegate) => true;
}