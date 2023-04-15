// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
//
// class ImagePainter extends CustomPainter {
//   // final ui.Image image;
//   late ui.Image image;
//   final File FileImage;
//   final int height;
//   final bool crop;
//   final BuildContext context;
//   final List<Offset> pointsList;
//
//   ImagePainter({
//     // required this.image,
//     required this.FileImage,
//     required this.height,
//     required this.crop,
//     required this.context,
//     required this.pointsList,
//   });
//
//   Future<ui.Image> loadImage(Uint8List  img)async{
//     final Completer<ui.Image> completer = Completer();
//     ui.decodeImageFromList(img, (ui.Image img) {
//       return completer.complete(img);
//     });
//     return completer.future;
//   }
//
//   @override
//   void paint(Canvas canvas, Size size) async{
//     image = await loadImage(FileImage.readAsBytesSync());
//
//     print("Inside ImagePainter");
//     // canvas.drawImage(image,Offset(0, 0), Paint());
//
//     if (pointsList.isNotEmpty && crop) {
//       print("Inside If");
//       canvas.drawPoints(
//           ui.PointMode.polygon,
//           pointsList,
//           Paint()
//             ..strokeWidth = 40.0
//             // ..strokeWidth = 20 * (image.height / height)
//             ..color = Colors.red
//             ..strokeCap = StrokeCap.round);
//
//       canvas.drawLine(
//           pointsList[0],
//           pointsList[pointsList.length - 1],
//           Paint()
//             ..strokeWidth = 3.0
//             ..color = Colors.white
//             ..strokeCap = StrokeCap.round);
//     }
//     print("After If");
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     throw UnimplementedError();
//   }
// }


import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class MyImagePainter extends CustomPainter {
  late ui.Image image;
  int height;
  final bool crop;
  final BuildContext context;
  final List<Offset> pointList;

  MyImagePainter(
      {required this.image,
        required this.context,
        required this.height,
        required this.crop,
        required this.pointList});

  @override
  void paint(Canvas canvas, Size size) {
    // final Paint paint = Paint();
    canvas.drawImage(image, const Offset(0, 0), Paint());
    // _drawDashedLine(canvas, size, paint);


    if (pointList.isNotEmpty && !crop) {
      try {
        // print("POINTS LENGTH :: ${pointList.length}");

        canvas.drawPoints(
            ui.PointMode.polygon,
            pointList,
            Paint()
            //..strokeWidth = 20 * (image.height / height)
              ..strokeWidth = 15.0
              ..color = Colors.red
              ..strokeCap = StrokeCap.round);



        // canvas.drawLine(
        //     pointList[0],
        //     pointList[pointList.length - 1],
        //     Paint()
        //       ..strokeWidth = 3.0
        //       ..color = Colors.white
        //       ..strokeCap = StrokeCap.round);

      } catch (err) {
        // ignore: prefer_interpolation_to_compose_strings
        print("Error: " + err.toString());
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // log("INSDE SHOULD PAINT CALLBACK");
    return true;
  }
}
