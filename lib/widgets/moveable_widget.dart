import 'package:flutter/material.dart';
import 'package:photo_frame_second/widgets/test.dart';


typedef PointerMoveCallback = void Function(Offset offset);

class MoveableWidget extends StatefulWidget {

  Widget item;
  MoveableWidget({Key? key,required this.item,required this.onScaleStart,required this.onScaleEnd,required this.onDragUpdate}) : super(key: key);
  final Function onScaleStart;
  // final Function onScaleEnd;
  final PointerMoveCallback onScaleEnd;
  final PointerMoveCallback onDragUpdate;

  @override
  State<MoveableWidget> createState() => _MoveableWidgetState();
}

class _MoveableWidgetState extends State<MoveableWidget> {
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  late Offset offset;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event){
        offset = event.position;
        widget.onDragUpdate(offset);
        //widget.onDragUpdate(event.position);
      },
      child: MatrixGestureDetector(
        onScaleEnd: (){
          // print("On Scale End is Called");
          widget.onScaleEnd(offset);
        },
        onScaleStart: (){
          // print("On Scale Start is Called");
          widget.onScaleStart();
        },
        onMatrixUpdate: (m, tm, sm, rm) {
          notifier.value = m;
        },
        child: AnimatedBuilder(
          animation: notifier,
          builder: (context, child) {
            return Transform(
              transform: notifier.value,
              child: FittedBox(
                fit: BoxFit.contain,
                child: widget.item,
              )
            );
          },
        ),
      ),
    );
  }
}
