import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_frame_second/widgets/custom_painter.dart';
import 'package:photo_frame_second/widgets/customm_clipper.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'dart:ui' as ui;

import 'package:screenshot/screenshot.dart';

class ImageCropper extends StatefulWidget {
  const ImageCropper({super.key, required this.imageFile});

  final XFile? imageFile;

  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  List<Offset> pointsList = [];
  bool croppedImage = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  late ui.Image image;
  bool isImageLoaded = false;
  int rotation = 0;
  Uint8List? cropImage;
  Widget? cropedImage;

// bool showMagnifier = false;
  //TODO: To load image
  Future<ui.Image> loadImage(Uint8List img) {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image image) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(image);
    });
    return completer.future;
  }

  Future<void> initFunc() async {
    image = await loadImage(File(widget.imageFile!.path).readAsBytesSync());
  }

  static const double touchBubbleSize = 60;
  Offset position = Offset(0, 0);
  late double currentBubbleSize;
  bool magnifierVisible = false;

  Widget _buildImage() {
    if (isImageLoaded) {
      return Center(
        child: RotatedBox(
          quarterTurns: rotation,
          child: FittedBox(
            child: SizedBox(
              height: image.height.toDouble(),
              width: image.width.toDouble(),
              child: croppedImage
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.orange,
                    ))
                  : Stack(
                    children: [

                      TouchBubble(
                        position: position,
                        bubbleSize: currentBubbleSize,
                        onStartDragging: _startDragging,
                        onDrag: _drag,
                        onEndDragging: _endDragging,
                      ),
                      // _getTouchBubble(),
                      Magnifier(
                        size: Size(500, 500),
                        position: position,
                        visible: magnifierVisible,
                        // child: Image(image: AssetImage('assets/logo/logo.png')),
                        child: Container(
                          child: CustomPaint(
                            painter: MyImagePainter(
                                image: image,
                                context: context,
                                height: MediaQuery.of(context).size.height.toInt(),
                                crop: croppedImage,
                                pointList: pointsList),
                            // child: GestureDetector(
                            //   onPanUpdate: (details) {
                            //     Offset click = Offset(details.localPosition.dx,
                            //         details.localPosition.dy);
                            //     setState(() {
                            //       if (click.dx > 0 &&
                            //           click.dx < image.width &&
                            //           click.dy > 0 &&
                            //           click.dy < image.height) {
                            //         // showMagnifier = true;
                            //         pointsList.add(click);
                            //       }
                            //     });
                            //     // setState(() {});
                            //   },
                            // ),
                          ),
                        ),
                        // child: Container(),
                      ),
                      // _getTouchBubble()
                    ],
                  ),
            ),
          ),
        ),
      );
    }



    return const Center(
      child: Text("Loading...."),
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
            ),),);
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
      Offset click = Offset(newPosition.dx,
          newPosition.dy);
      setState(() {
        if (click.dx > 0 &&
            click.dx < image.width &&
            click.dy > 0 &&
            click.dy < image.height) {
          // showMagnifier = true;
          pointsList.add(click);
        }
      });
    });
  }

  void _endDragging() {
    setState(() {
      currentBubbleSize = touchBubbleSize;
      magnifierVisible = false;
    });
  }


  Widget rotate() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () async {
              setState(() {
                rotation--;
              });
            },
            icon: const Icon(Icons.rotate_left),
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                rotation++;
              });
            },
            icon: const Icon(Icons.rotate_right),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  croppedImage = true;
                });
                _screenshotController
                    .capture()
                    .then((Uint8List? imageList) async {
                  // print("INSIDE CAPTURE SCREENSHOT");
                  cropImage = imageList;
                  setState(() {
                    cropedImage = ClipPath(
                      clipper: MyClipper(pointsList: pointsList),
                      child: Image.file(File(widget.imageFile!.path)),
                      // child: Container(color: Colors.red,width: 200,height: 200,),
                    );
                  });

                  log(imageList.toString());
                  Navigator.pop(context, cropedImage);
                });
              },
              icon: const Icon(Icons.done)),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    currentBubbleSize = touchBubbleSize;
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
    initFunc();
  }

  @override
  Widget build(BuildContext context) {

    return OurScaffold(
      scaffoldBody: _buildImage(),
      appBarTitle: "Image cropping",
      bottomNavigatorBar: rotate(),
    );
    // return Scaffold(
    //   // key: GlobalKey(),
    //   appBar: appBar2,
    //   body: _buildImage(),
    //   bottomNavigationBar: rotate(),
    // );
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
          onPanStart: (details) => onStartDragging(details.localPosition),
          onPanUpdate: (details) => onDrag(details.localPosition),
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
    // _drawCrosshair(canvas, size);
  }

  void _drawCircle(Canvas canvas, Size size) {

    Paint paintObject = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawCircle(
        size.center(Offset(0,0)), 
        size.longestSide / 2, paintObject
    );
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
          painter: MagnifierPainter(color: Colors.deepOrange),
          size: magnifierSize,
          // size: Size(500,500),
        ),
      ),
    ),
  );
}
