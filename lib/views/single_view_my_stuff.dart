import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'home_page.dart';


class SingleViewMyStuff extends StatefulWidget {
  String imageNames;

  SingleViewMyStuff(
      {Key? key, required this.imageNames})
      : super(key: key);

  @override
  State<SingleViewMyStuff> createState() => _SingleViewMyStuffState();
}

class _SingleViewMyStuffState extends State<SingleViewMyStuff> {
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());



  XFile? selectedImage;
  GlobalKey _globalKey = GlobalKey();
  bool showFrameGrid = false,
      showDeleteButton = false,
      isDeleteButtonActive = false,
      showStickerGrid = false,
      showTextField = false;

  Widget? textOnImage;
  List<Widget> moveableWidgetsOnImage = [];


  @override
  Widget build(BuildContext context) {
    return OurScaffold(
      appBarTitle:"My Image",
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text("My Image"),
      // ),
      scaffoldBody: Padding(
        padding: EdgeInsets.fromLTRB(
            0, 20, 0, MediaQuery.of(context).size.height * 0.08),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 80,
          child: RepaintBoundary(
            key: _globalKey,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  child: Image.file(File(widget.imageNames)),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white // Background color
              ),
              onPressed: () {
                shareImage();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, color:
                  showFrameGrid?Colors.blue:Colors.black),
                  Text(
                    "Share",
                    style: TextStyle(color: showFrameGrid?Colors.blue:Colors.black),
                  )
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white // Background color
              ),
              onPressed: () {
                deleteImage();
              },
              //color: Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete_forever, color: Colors.black),
                  Text(
                    "Delete",
                    style: TextStyle(color: Colors.black),
                  )
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white // Background color
              ),
              onPressed: () {
                goHome();
              },
              //color: Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_filled,
                      color: showStickerGrid?Colors.blue:Colors.black),
                  Text(
                    "Home",
                    style: TextStyle(color: showStickerGrid?Colors.blue:Colors.black),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void shareImage() async {
    await Share.shareFiles([widget.imageNames]);
  }

  void deleteImage() async{

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Do you want to Delete ?'),
          actions: [
            TextButton(onPressed: (){Navigator.pop(context);}, child: Text("No")),
            TextButton(onPressed: ()async{
              final String dir = (await getApplicationDocumentsDirectory()).path;

              try {
                if (await File(widget.imageNames).exists()) {
                  await File(widget.imageNames).delete();
                }
                else{
                  // print("File not Exists");
                }
              } catch (e) {
                // print("E = "+e.toString());
              }

              Navigator.pop(context,true);
              Navigator.pop(context,true);

            }, child: Text("Yes")),
          ],
        )
    );

  }

  void goHome(){
    // final bgImage = AssetImage("assets/background/bgg3.jpg");
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        HomePage()), (Route<dynamic> route) => false);
  }
}
