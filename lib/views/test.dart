import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Mag extends StatefulWidget {
  const Mag({Key? key}) : super(key: key);

  @override
  State<Mag> createState() => _MagState();
}

class _MagState extends State<Mag> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: SampleImage(),
    )
        // Stack(
        //   children: [
        //     // Image(
        //     //     image: AssetImage('assets/logo/logo.png')
        //     // ),
        //     SampleImage()
        //   ],
        // ),
        );
  }
}



class SampleImage extends StatefulWidget {
  @override
  _SampleImageState createState() => _SampleImageState();
}

class _SampleImageState extends State<SampleImage> {

  static const double touchBubbleSize = 1;
  Offset position = Offset(0, 0);
  late double currentBubbleSize;
  bool magnifierVisible = false;

  @override
  void initState() {
    currentBubbleSize = touchBubbleSize;
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(image: AssetImage('assets/logo/logo.png')),
        TouchBubble(
          position: position,
          bubbleSize: currentBubbleSize,
          onStartDragging: _startDragging,
          onDrag: _drag,
          onEndDragging: _endDragging,
        ),
        Magnifier(
          position: position,
          visible: magnifierVisible,
          // child: Image(image: AssetImage('assets/lenna.png')),
          child: Container(),
        ),
        _getTouchBubble()
        // Stack(
        //   children: [
        //     Magnifier(
        //       position: position,
        //       visible: magnifierVisible,
        //       // child: Image(image: AssetImage('assets/lenna.png')),
        //       child: Container(),
        //     ),
        //     _getTouchBubble()
        //   ],
        // ),
      ],
    );
  }

  Positioned _getTouchBubble() {
    return Positioned(
        top: position == null ? 0 : position.dy - currentBubbleSize / 2,
        left: position == null ? 0 : position.dx - currentBubbleSize / 2,
        child: GestureDetector(
            child: Container(
          width: currentBubbleSize,
          height: currentBubbleSize,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).accentColor.withOpacity(0.5)),
        )));
  }

  void _startDragging(Offset newPosition) {
    setState(() {
      magnifierVisible = true;
      position = newPosition;
      currentBubbleSize = touchBubbleSize * 1.5;
    });
  }

  void _drag(Offset newPosition) {
    setState(() {
      position = newPosition;
    });
  }

  void _endDragging() {
    setState(() {
      currentBubbleSize = touchBubbleSize;
      magnifierVisible = false;
    });
  }
}

class TouchBubble extends StatelessWidget {
  TouchBubble({
    required this.position,
    required this.onStartDragging,
    required this.onDrag,
    required this.onEndDragging,
    required this.bubbleSize,
  })  : assert(onStartDragging != null),
        assert(onDrag != null),
        assert(onEndDragging != null),
        assert(bubbleSize != null && bubbleSize > 0);

  final Offset position;
  final double bubbleSize;
  final Function onStartDragging;
  final Function onDrag;
  final Function onEndDragging;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        child: GestureDetector(
          onPanStart: (details) => onStartDragging(details.globalPosition),
          onPanUpdate: (details) => onDrag(details.globalPosition),
          onPanEnd: (_) => onEndDragging(),
        ));
  }
}

class Magnifier extends StatefulWidget {
  const Magnifier(
      {required this.child,
      required this.position,
      this.visible = true,
      this.scale = 1.5,
      this.size = const Size(160, 160)})
      : assert(child != null);

  final Widget child;
  final Offset position;
  final bool visible;
  final double scale;
  final Size size;

  @override
  _MagnifierState createState() => _MagnifierState();
}

class _MagnifierState extends State<Magnifier> {
  late Size _magnifierSize;
  late double _scale;
  late Matrix4 _matrix;

  @override
  void initState() {
    _magnifierSize = widget.size;
    _scale = widget.scale;
    _calculateMatrix();

    super.initState();
  }

  @override
  void didUpdateWidget(Magnifier oldWidget) {
    super.didUpdateWidget(oldWidget);

    _calculateMatrix();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.visible && widget.position != null)
          _getMagnifier(context, _magnifierSize, _matrix)
      ],
    );
  }

  void _calculateMatrix() {
    if (widget.position == null) {
      return;
    }

    setState(() {
      double newX = widget.position.dx - (_magnifierSize.width / 2 / _scale);
      double newY = widget.position.dy - (_magnifierSize.height / 2 / _scale);

      final Matrix4 updatedMatrix = Matrix4.identity()
        ..scale(_scale, _scale)
        ..translate(-newX, -newY);

      _matrix = updatedMatrix;
    });
  }
}

class MagnifierPainter extends CustomPainter {
  MagnifierPainter({required this.color, this.strokeWidth = 5});

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCircle(canvas, size);
    _drawCrosshair(canvas, size);
  }

  void _drawCircle(Canvas canvas, Size size) {
    Paint paintObject = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawCircle(
        size.center(Offset(0, 0)), size.longestSide / 2, paintObject);
  }

  void _drawCrosshair(Canvas canvas, Size size) {
    Paint crossPaint = Paint()
      ..strokeWidth = strokeWidth / 2
      ..color = color;

    double crossSize = size.longestSide * 0.04;

    canvas.drawLine(size.center(Offset(-crossSize, -crossSize)),
        size.center(Offset(crossSize, crossSize)), crossPaint);

    canvas.drawLine(size.center(Offset(crossSize, -crossSize)),
        size.center(Offset(-crossSize, crossSize)), crossPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Widget _getMagnifier(BuildContext context, Size magnifierSize, Matrix4 matrix) {
  return Align(
    alignment: Alignment.topLeft,
    child: ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.matrix(matrix.storage),
        child: CustomPaint(
          painter: MagnifierPainter(color: Colors.red),
          size: magnifierSize,
        ),
      ),
    ),
  );
}
