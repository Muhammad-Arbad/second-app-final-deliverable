import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_frame_second/widgets/icon_with_name.dart';

class CustomDialogBox extends StatelessWidget {

  CustomDialogBox({Key? key,required this.galleryImage,required this.shapeCropper}) : super(key: key);
  Function galleryImage;
  Function shapeCropper;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        // title: Text('Select'),
        child: Container(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              iconNameBlock(icon: Icon(Icons.crop),
                  nameOfIcon: "Free hand Cropping",
                  bgColor: Colors.green,
                  inkwellOnTap:(){
                    galleryImage();
                    // return getImage(ImageSource.gallery);
                  },

                leftBottom: true,

              ),
              iconNameBlock(icon: Icon(Icons.crop),
                  nameOfIcon: "Shape Cropping",
                  bgColor: Colors.blue,
                  inkwellOnTap:(){
                    shapeCropper();
                  },
                   rightBottom: true),
            ],
          ),
        ),

    );
  }

}
