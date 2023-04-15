import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_frame_second/views/shapes.dart';
import 'package:photo_frame_second/widgets/custom_clipper_shape.dart';
import 'package:photo_frame_second/widgets/custom_painter.dart';
import 'package:photo_frame_second/widgets/customm_clipper.dart';
import 'package:photo_frame_second/widgets/moveable_widget.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'dart:ui' as ui;

import 'package:screenshot/screenshot.dart';

class ShapeImageCropper extends StatefulWidget {
  const ShapeImageCropper({super.key, required this.imageFile});

  final XFile? imageFile;

  @override
  State<ShapeImageCropper> createState() => _ShapeImageCropperState();
}

class _ShapeImageCropperState extends State<ShapeImageCropper> {
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
                  :
              CustomPaint(
                painter:MyCustomPainterScreen(index: 10,image: image),

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

  Widget rotate() {
    // return BottomAppBar(
    return BottomAppBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () async {
                    setState(() {
                      rotation--;
                    });
                  },
                  icon: const Icon(Icons.rotate_left)),
              IconButton(
                  onPressed: () async {
                    setState(() {
                      rotation++;
                    });
                  },
                  icon: const Icon(Icons.rotate_right)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      croppedImage = true;
                    });
                    _screenshotController
                        .capture()
                        .then((Uint8List? imageList) async {
                      print("INSIDE CAPTURE SCREENSHOT");
                      cropImage = imageList;
                      setState(() {
                        cropedImage = ClipPath(
                          clipper: MyShapeClipper(path: p!),
                          child:Image.file(File(widget.imageFile!.path)),

                        );
                      });

                      log(imageList.toString());
                      Navigator.pop(context, cropedImage);
                      // if (imageList != null) {
                      //   String path = await FileSaver.instance
                      //       .saveAs('result image', imageList, 'png', MimeType.PNG);
                      //   log(path);
                      // }
                    });
                  },
                  icon: const Icon(Icons.done)),
            ],
          ),
          Container(
              height: MediaQuery.of(context).size.height * 0.1,
              child: ShapesGrid())
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initFunc();
  }

  @override
  Widget build(BuildContext context) {
    return OurScaffold(
      scaffoldBody: _buildImage(),
      appBarTitle: "Shape cropping",
      bottomNavigatorBar: rotate(),
    );
  }
}

class ShapesGrid extends StatefulWidget {
  ShapesGrid({Key? key,}) : super(key: key);
  @override
  State<ShapesGrid> createState() => _ShapesGridState();
}

class _ShapesGridState extends State<ShapesGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      children: List.generate(
        Shapes.types.length,
        (index) => singleSticker(context, index, () {
          log(index.toString());
        }),
      ),
    );
  }

  Widget singleSticker(BuildContext context, int index, Function() tapOnShape) {
    return GestureDetector(
      onTap: () {
        tapOnShape();
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.white,
        child: Container(
          color: Colors.purpleAccent,
          child: Center(
            child: CustomPaint(
              painter: _MyPainter(index: index),
            ),
          ),
        ),
      ),
    );
  }
}


class _MyPainter extends CustomPainter {
  int index;

  _MyPainter({required this.index});

  @override
  bool shouldRepaint(_MyPainter oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {


    final Paint stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Paint fill = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    const double radius = 25;
    final Shapes shapes = Shapes(canvas: canvas);

    String type = Shapes.types[10];

    for (Paint paint in <Paint>[stroke]) {
      Path? p = (shapes
        ..paint = paint
        ..radius = radius
        ..center = Offset(0, 0))
          .draw(type);

      log(p.toString());
    }
  }
}
Path? p;

class MyCustomPainterScreen extends CustomPainter {
  int index;
  ui.Image image;
  MyCustomPainterScreen({required this.index,required this.image});

  @override
  bool shouldRepaint(MyCustomPainterScreen oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {


    canvas.drawImage(image,  Offset(700,700), Paint());


    final Paint stroke = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 23;

    final Paint fill = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    const double radius = 500;
    final Shapes shapes = Shapes(canvas: canvas);

    String type = Shapes.types[10];
    p = null;
    for (Paint paint in <Paint>[stroke]) {

          p = (shapes
            ..paint = paint
            ..radius = radius
            ..center = Offset(size.width/2, size.height/2)
            // ..center = Offset(700,700)
          ).draw(type);

    }
  }
}
