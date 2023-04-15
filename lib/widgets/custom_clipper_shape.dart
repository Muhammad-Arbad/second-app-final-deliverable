import 'package:flutter/material.dart';

class MyShapeClipper extends CustomClipper<Path> {

  Path path;
  MyShapeClipper({required this.path});


  @override
  Path getClip(Size size) {

    Path path1 = Path();
    path1 = path;
    return path1;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    throw false;
  }
}