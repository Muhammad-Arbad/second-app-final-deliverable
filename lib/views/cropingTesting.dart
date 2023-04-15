// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:photo_frame_second/widgets/custom_painter.dart';
// import 'dart:ui' as ui;
//
// import 'package:photo_frame_second/widgets/customm_clipper.dart';
//
//
// class ImageCropping extends StatefulWidget {
//   static const routeName = "/imageCropping";
//   XFile selectedImageFromPreScreen;
//   ImageCropping({Key? key,required this.selectedImageFromPreScreen}) : super(key: key);
//
//   @override
//   State<ImageCropping> createState() => _ImageCroppingState();
// }
// XFile? selectedImage;
//
// class _ImageCroppingState extends State<ImageCropping> {
//
//
//
//   // final String imageURL = 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg';
//
//
//   // final ImagePicker picker = ImagePicker();
//
//   // @override
//   // void initState() {
//   //   // TODO: implement initState
//   //   super.initState();
//   //   getImage(ImageSource.gallery);
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     // final routeArguments = ModalRoute.of(context)!.settings.arguments as Map<String,XFile?>;
//     // selectedImage = routeArguments['image'];
//     selectedImage = widget.selectedImageFromPreScreen;
//     return Scaffold(
//         backgroundColor: Colors.grey[300],
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Stack(
//       children: [
//                 Container(
//                   alignment: Alignment.topCenter,
//                   child: Opacity(
//                     opacity: 0.4,
//                     child: Container(
//                       alignment: Alignment.topCenter,
//                       width: 300,
//                       height: 300,
//                       color: Colors.grey,
//                       child:
//                       // Image.network(imageURL)
//                       Image.file(File(selectedImage!.path)),
//                     ),
//                   ),
//                 ),
//                 TouchControl(),
//                 // TouchControl(imageURL: imageURL),
//               ],
//             ),
//           ),
//         ),
//
//       bottomSheet: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//
//
//           Container(
//             height: MediaQuery.of(context).size.height * 0.08,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white // Background color
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.keyboard_return,
//                           color:Colors.black),
//                       Text(
//                         "Cancle",
//                         style: TextStyle(
//                             color:
//                             Colors.black),
//                       )
//                     ],
//                   ),
//                 ),
//
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white // Background color
//                   ),
//                   onPressed: () {
//
//                   },
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.sync,
//                           color:Colors.black),
//                       Text(
//                         "Reset",
//                         style: TextStyle(
//                             color:
//                             Colors.black),
//                       )
//                     ],
//                   ),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white // Background color
//                   ),
//                   onPressed: () async{
//
//                     // final byteData = await rootBundle.load(widget.wallpaperDetail.path);
//                     // final file = File('${(await getTemporaryDirectory()).path}/${widget.wallpaperDetail.frameName}');
//                     // await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//                     //
//                     // path = file.path;
//                     //
//                     // // final pathOfImage = await File('${directory.path}/legendary.png').create();
//                     // final pathOfImage =  await File(getApplicationDocumentsDirectory().path);
//                     // Navigator.pop(context,XFile( await pathOfImage.writeAsBytes(image!).path));
//
//
//                     Navigator.pop(context,image);
//                   },
//                   //color: Colors.red,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.check, color: Colors.black),
//                       Text(
//                         "Done",
//                         style: TextStyle(color: Colors.black),
//                       )
//                     ],
//                   ),
//                 ),
//
//               ],
//             ),
//           ),
//         ],
//       ),
//
//
//
//     );
//   }
//   //
//   // Future getImage(ImageSource media) async {
//   //   var img = await picker.pickImage(source: media);
//   //   setState(() {
//   //     selectedImage = img;
//   //   });
//   // }
// }
//
// class TouchControl extends StatefulWidget {
//   final double? xPos;
//   final double? yPos;
//   final ValueChanged<Offset>? onChanged;
//   // final String imageURL;
//
//
//   const TouchControl({Key? key, this.onChanged, this.xPos, this.yPos,
//     // required this.imageURL
//   }) : super(key: key);
//
//   @override
//   TouchControlState createState() => TouchControlState();
// }
//
// // This contains all locations user touched.
// List<Offset> points = [];
// Uint8List? image;
//
// class TouchControlState extends State<TouchControl> {
//
//   double? xPos;
//   double? yPos;
//
//   GlobalKey? cropperKey = GlobalKey();
//
//
//
// //this function crops image when gesture is ended.
// //thanks to https://github.com/speedkodi/flutter_cropperx
//   Future<Uint8List?> crop({
//     required GlobalKey cropperKey,
//     double pixelRatio = 3,
//   }) async {
//     // Get cropped image
//     final renderObject = cropperKey.currentContext!.findRenderObject();
//     final boundary = renderObject as RenderRepaintBoundary;
//     final image = await boundary.toImage(pixelRatio: pixelRatio);
//
//     // Convert image to bytes in PNG format and return
//     final byteData = await image.toByteData(
//       format: ImageByteFormat.png,
//     );
//     final pngBytes = byteData?.buffer.asUint8List();
//     return pngBytes;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     bool isfinal = false;
//     void onChanged(Offset offset) {
//       print("On Changed Callede");
//       // for prevent to null value and setState function
//       if (widget.onChanged != null) {
//         widget.onChanged!(offset);
//       }
//       setState(() {
//         xPos = offset.dx;
//         yPos = offset.dy;
//       });
//     }
//
// //This function related to GestureDetector.
// //This runs when user touch screen
//     void _handlePanStart(DragStartDetails details) {
//       // isfinal = true;
//       // setState(() {
//       //
//       // });
//       print('User started drawing');
//       final box = context.findRenderObject() as RenderBox;
//       final point = box.globalToLocal(details.globalPosition);
//       onChanged(Offset(details.localPosition.dx,details.localPosition.dy));
//       // onChanged(point);
//     }
//
// //this function runs crop future when user interaction ended.
//     void _handlePanEnd(DragEndDetails details) async {
//       isfinal = true;
//       print('_handlePanEnd');
//       image = await crop(cropperKey: cropperKey!);
//       setState(() {});
//     }
//
//     void _handlePanUpdate(DragUpdateDetails details) {
//       final box = context.findRenderObject() as RenderBox;
//       final point = box.globalToLocal(details.globalPosition);
//       onChanged(Offset(details.localPosition.dx,details.localPosition.dy));
//       // onChanged(point);
//     }
//
//     Future<ui.Image> getImage(String path) async {
//       var completer = Completer<ImageInfo>();
//       var img = new NetworkImage(path);
//       img.resolve(const ImageConfiguration()).addListener(ImageStreamListener((info, _) {
//         completer.complete(info);
//       }));
//       ImageInfo imageInfo = await completer.future;
//       return imageInfo.image;
//     }
//
//     return Column(
//       children: [
//       RepaintBoundary(
//       key: cropperKey,
//       child: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onPanStart: _handlePanStart,
//         onPanEnd: _handlePanEnd,
//         onPanUpdate: _handlePanUpdate,
//         child:
//         // isfinal?
//         ClipPath(
//           clipper: TouchControlPainter(xPos, yPos),
//           // clipper: MyClipper(pointsList: points),
//           child: Container(
//             width: 300,
//             height: 300,
//             decoration:  BoxDecoration(
//               // color: Colors.red,
//                 image: DecorationImage(
//                   // image: NetworkImage(widget.imageURL),
//                   image:  FileImage(File(selectedImage!.path)),
//                   // image: AssetImage("assets/categories/bannerImages/flower.jpg"),
//                 ),),
//           ),
//         )
//           //   :
//           // CustomPaint(
//           //   painter: ImagePainter(
//           //       height: 400,
//           //       FileImage: File(selectedImage!.path),
//           //       context: context,
//           //       crop: true,
//           //       pointsList: points
//           //   ),
//           // ),
//       ),
//     ),
// //below code is here to show it works while recording video.
//
//
//         image != null ? Image.memory(image!) : Container(
//       child: Text("Image will be here"),
//     )
//
//
//     ],
//     );
//   }
// }
//
//
// //CustomCipper class to crop image.
// class TouchControlPainter extends CustomClipper<Path> {
//   final double? xPos;
//   final double? yPos;
//
//   TouchControlPainter(this.xPos, this.yPos);
//
//   @override
//   Path getClip(Size size) {
//
//     print("Clipper is called");
//
//     Path path = Path();
//     if (xPos != null && yPos != null) {
//       points.add(Offset(xPos!, yPos!));
//     }
//     // path.addPolygon(points, true); // here contains point list that
//     path.addPolygon(points, false);
//     // path.close();
//     // for(int i = 0 ;i<points.length;i++){
//     //   path.lineTo(points[i].dx,points[i].dy);
//     // }
//     // here contains point list that
//     // path.addPolygon(points, true); // here contains point list that
// //I declared one of the previous lines and
// //addPolygon method creates a polygon using list of points.
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
//
// // here should be true to see what user draws
// // simultaneously.
// }
//
