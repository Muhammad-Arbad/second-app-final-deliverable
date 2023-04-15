import 'package:flutter/material.dart';

class Custom_AppBar extends StatelessWidget{
  const Custom_AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              Colors.deepOrangeAccent.withOpacity(0.5),
              Colors.purple.withOpacity(0.5)
            ]),
      ),
    );
  }


}
