import 'package:flutter/material.dart';

class iconNameBlock extends StatelessWidget {
  Icon icon;
  String nameOfIcon;
  Color bgColor;
  Function inkwellOnTap;
  // String nonrRadius;
  double borderRadius = 30;
  bool? rightTop = false;
  bool? rightBottom = false;
  bool? leftTop = false;
  bool? leftBottom = false;
  iconNameBlock(
      {Key? key,
      required this.icon,
      required this.nameOfIcon,
      required this.bgColor,
      required this.inkwellOnTap,
      this.rightBottom,
      this.leftBottom,
      this.rightTop,
      this.leftTop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: leftTop == true
              ? Radius.circular(0)
              : Radius.circular(borderRadius),
          topRight: rightTop == true
              ? Radius.circular(0)
              : Radius.circular(borderRadius),
          bottomRight: rightBottom == true
              ? Radius.circular(0)
              : Radius.circular(borderRadius),
          bottomLeft: leftBottom == true
              ? Radius.circular(0)
              : Radius.circular(borderRadius),
          //
          // topLeft: Radius.circular(borderRadius),
          // topRight: Radius.circular(borderRadius),
          // bottomLeft: nonrRadius=="left"?Radius.circular(0):
          // nonrRadius=="none" ? Radius.circular(borderRadius):Radius.circular(borderRadius),
          // bottomRight:nonrRadius=="right"? Radius.circular(0):
          // nonrRadius=="none" ? Radius.circular(borderRadius):Radius.circular(borderRadius),
        ),
        onTap: () => inkwellOnTap(),
        //highlightColor: Colors.red,
        //highlightColor: bgColor,
        splashColor: bgColor,
        //splashColor: Colors.black,
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: leftTop == true
                  ? Radius.circular(0)
                  : Radius.circular(borderRadius),
              topRight: rightTop == true
                  ? Radius.circular(0)
                  : Radius.circular(borderRadius),
              bottomRight: rightBottom == true
                  ? Radius.circular(0)
                  : Radius.circular(borderRadius),
              bottomLeft: leftBottom == true
                  ? Radius.circular(0)
                  : Radius.circular(borderRadius),

              // bottomLeft: nonrRadius=="left"?Radius.circular(0):
              // nonrRadius=="none" ? Radius.circular(borderRadius):Radius.circular(borderRadius),
              // bottomRight:nonrRadius=="right"? Radius.circular(0):
              // nonrRadius=="none" ? Radius.circular(borderRadius):Radius.circular(borderRadius),
            ),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  bgColor,
                  // bgColor.withOpacity(0.8)
                  bgColor.withOpacity(1)
                ]),
          ),
          child: Column(
            children: [
              icon,
              Text(
                nameOfIcon,
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}
