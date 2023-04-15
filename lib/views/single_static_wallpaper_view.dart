
import 'dart:developer';
import 'dart:io';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_frame_second/models/image_detail_model.dart';
import 'package:photo_frame_second/widgets/custom_dialog_box.dart';
import 'package:photo_frame_second/widgets/icon_with_name.dart';



class SingleStaticWallpaperView extends StatefulWidget {
  ImgDetails wallpaperDetail;

  SingleStaticWallpaperView({Key? key,required this.wallpaperDetail}) : super(key: key);

  @override
  State<SingleStaticWallpaperView> createState() => _SingleStaticWallpaperViewState();
}

class _SingleStaticWallpaperViewState extends State<SingleStaticWallpaperView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child:
            widget.wallpaperDetail.category == "assets" ?Image.asset(widget.wallpaperDetail.path,fit: BoxFit.cover,):
            Image.file( File(widget.wallpaperDetail.path),fit: BoxFit.cover,),

          ),

          Positioned(
              bottom: 100,
              left: 100,
              right: 100,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueGrey,
                    padding: EdgeInsets.all(18),
                    onPrimary: Colors.white,
                    elevation: 3,
                    shape: const RoundedRectangleBorder(
                        // borderRadius: BorderRadius.only(
                        //   bottomLeft: Radius.circular(30),
                        //   topRight:  Radius.circular(30),
                        // ),
                        side: BorderSide(color: Colors.black)),
                  ),
                child: Text("Set Wallpaper"),onPressed: (){

                showDialog(
                  context: context,
                  builder: (BuildContext context) => dialogBox(
                    home: (){
                      Navigator.pop(context);
                      setLiveWallpaper(AsyncWallpaper.HOME_SCREEN);},
                    lock: (){
                      Navigator.pop(context);
                      setLiveWallpaper(AsyncWallpaper.LOCK_SCREEN);},
                    both: (){
                      Navigator.pop(context);
                      setLiveWallpaper(AsyncWallpaper.BOTH_SCREENS);},
                  ),
                );
                    // setLiveWallpaper();

                    },)),


          isLoading ? const Center(
            child: CircularProgressIndicator(color: Colors.deepOrange,),
          ):IgnorePointer()
        ],
      ),
    );
  }

  void setLiveWallpaper(int homeLockBoth) async {

    String result;
    String path = widget.wallpaperDetail.path;

    if(widget.wallpaperDetail.category == "assets"){

      log("inside if");

      log("FILE PATH ${widget.wallpaperDetail.frameName}");
      log(path);

      final byteData = await rootBundle.load(widget.wallpaperDetail.path);
      final file = File('${(await getTemporaryDirectory()).path}/${widget.wallpaperDetail.frameName}');
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      path = file.path;

      setState(() {
        isLoading = true;
      });

      try {
        result = await AsyncWallpaper.setWallpaperFromFile(
          filePath: path,
          wallpaperLocation: homeLockBoth,
          goToHome: true,
        )
            ? 'Wallpaper set'
            : 'Failed to get wallpaper.';
      } on PlatformException {
        result = 'Failed to get wallpaper.';
      }

      setState(() {
        isLoading = false;
      });

      if(result == 'Wallpaper set'){
        Fluttertoast.showToast(msg: "Wallpaper Set Successfully",backgroundColor: Colors.green,gravity: ToastGravity.CENTER);
      }
      else{
        Fluttertoast.showToast(msg: "Error while Setting. Try again.",backgroundColor: Colors.red,gravity: ToastGravity.CENTER);
      }

      deleteFile(File(path));

    }

    else{

      log("FILE PATH ${widget.wallpaperDetail.frameName}");
      log(path);

      final byteData  = await File(path).readAsBytes();

      log("BYTE DATA");
      log(byteData.toString());

      // dynamic file = File('${(await getTemporaryDirectory()).path}/test.jpg');
      final file = File('${(await getTemporaryDirectory()).path}/${widget.wallpaperDetail.frameName}');
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      path = file.path;

      log("FILE PATH");
      log(path);


        setState(() {
          isLoading = true;
        });

        try {
          result = await AsyncWallpaper.setWallpaperFromFile(
            filePath: path,
            wallpaperLocation: homeLockBoth,
            goToHome: true,
          )
              ? 'Wallpaper set'
              : 'Failed to get wallpaper.';
        } on PlatformException {
          result = 'Failed to get wallpaper.';
        }

      if (await File(file.path).exists()) {
        log("FILE EXIST");
        await File(file.path).delete();
        path = '';
        // file = '';

      }

      log("After Deleting");
      log(path);

        setState(() {
          isLoading = false;
        });

        if(result == 'Wallpaper set'){
          Fluttertoast.showToast(msg: "Wallpaper Set Successfully",backgroundColor: Colors.green,gravity: ToastGravity.CENTER);
        }
        else{
          Fluttertoast.showToast(msg: "Error while Setting. Try again.",backgroundColor: Colors.red,gravity: ToastGravity.CENTER);
        }

      deleteFile(File(path));

    }

  }

  Future<void> deleteFile(File file) async {

    print("Inside delete file function");
    try {
      if (await file.exists()) {
        await file.delete();
        log("This is Try in deleteFile");
      }
    } catch (e) {
      log("This is Cash in deleteFile");
      // Error in getting access to the file.
    }
  }
}

class dialogBox extends StatelessWidget {

  Function home,lock,both;
  dialogBox({
    Key? key,required this.home,required this.lock,required this.both
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            iconNameBlock(icon:
            Icon(Icons.home_outlined),
              nameOfIcon: "HomeScreen",
              bgColor: Colors.green,
              inkwellOnTap:(){
                home();
              },

              leftBottom: true,

            ),
            iconNameBlock(icon: Icon(Icons.lock_outlined),
                nameOfIcon: "LockScreen",
                bgColor: Colors.orange,
                inkwellOnTap:(){lock();},
                rightBottom: true),

            iconNameBlock(icon: Icon(Icons.sync),
                nameOfIcon: "Both Screens",
                bgColor: Colors.purple,
                inkwellOnTap:(){both();},
                leftBottom: true),
          ],
        ),
      ),

    );
  }
}
