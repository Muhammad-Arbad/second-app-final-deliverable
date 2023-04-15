//
//
//
//
//
// import 'package:flutter/material.dart';
//
//
// class MyClipper extends CustomClipper<Path>{
//   final List<Offset> pointsList;
//
//   MyClipper({required this.pointsList});
//
//   @override
//   Path getClip(Size size) {
//     Path path =  Path();
//
//     if(pointsList.isNotEmpty) path.moveTo(pointsList[0].dx, pointsList[0].dy);
//
//     for(int i=0;i<pointsList.length;i++){
//       path.lineTo(pointsList[0].dx, pointsList[0].dy);
//     }
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     // TODO: implement shouldReclip
//     throw UnimplementedError();
//   }
//
//
// }

import 'package:flutter/material.dart';

class MyClipper extends CustomClipper<Path> {
  List<Offset> pointsList = [];
  MyClipper({required this.pointsList});


  @override
  Path getClip(Size size) {

    Path path = Path();

    if(pointsList.isNotEmpty) path.moveTo(pointsList[0].dx, pointsList[0].dy);
    for(int i=1; i<pointsList.length; i++)
    {
      path.lineTo(pointsList[i].dx, pointsList[i].dy);
    }
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    throw false;
  }
}
