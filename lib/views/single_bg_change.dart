import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_frame_second/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/models/image_detail_model.dart';
import 'package:photo_frame_second/views/image_cropper.dart';
import 'package:photo_frame_second/views/shape_cropper.dart';
import 'package:photo_frame_second/widgets/moveable_widget.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'package:text_editor/text_editor.dart';



// Widget? moveableImagesOnImage;
Widget? selectedImageFromGallery;
class SingleBgChange extends StatefulWidget {
  ImgDetails imageDetal;
  List<ImgDetails> framesDetails;
  String frameCategoryName;
  BannerModel bannerModel;
  // bool imageOnFront = false;

  SingleBgChange({Key? key, required this.imageDetal, required this.framesDetails,required this.frameCategoryName,required this.bannerModel})
      : super(key: key);

  @override
  State<SingleBgChange> createState() => _SingleBgChangeState();
}

class _SingleBgChangeState extends State<SingleBgChange> {
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

  List<String> frames = [];
  List<String> fontsInTextEditor = [];
  List<String> stickersList = [];

  XFile? selectedImage;
  // File? imgFile;
  final ImagePicker picker = ImagePicker();
  GlobalKey _globalKey = GlobalKey();
  bool showFrameGrid = false,
      showDeleteButton = false,
      isDeleteButtonActive = false,
      showStickerGrid = false,
      showTextField = false,
      showEchoGrid = false;

  Widget? textOnImage;
  List<Widget> moveableWidgetsOnImage = [];
  Widget? moveableImagesOnImage;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

    loadFonts();
    // loadFrames();
    loadStickers();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backButtonPress,
      child: OurScaffold(
        appBarTitle: "Photo Editor",
        scaffoldBody: Padding(
          padding: //EdgeInsets.all(0),
          EdgeInsets.fromLTRB(
              0, 0, 0, MediaQuery.of(context).size.height * 0.08),
          child: Center(
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height * 80,
              child: RepaintBoundary(
                key: _globalKey,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          image: widget.imageDetal.category == "assets"
                              ? DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(widget.imageDetal.path))
                              : DecorationImage(
                              fit: BoxFit.cover,
                              image:
                              FileImage(File(widget.imageDetal.path))),
                        ),
                      ),
                    ),

                    moveableImagesOnImage!=null?
                    Positioned.fill(
                      child: MoveableWidget(
                        item: moveableImagesOnImage==null?IgnorePointer():moveableImagesOnImage!,
                        onScaleEnd: (offset) {
                          setState(() {
                            showDeleteButton = false;
                          });
                          // print("From Previous End");

                          if (offset.dy >
                              (MediaQuery.of(context).size.height - 300)) {
                            setState(() {
                              moveableImagesOnImage = IgnorePointer();
                              selectedImageFromGallery = IgnorePointer();
                            });
                          }
                        },
                        onScaleStart: () {
                          setState(() {
                            showDeleteButton = true;
                          });
                          // print("From Previous Start");
                        },
                        onDragUpdate: (offset) {
                          if (offset.dy >
                              (MediaQuery.of(context).size.height - 300)) {
                            if (!isDeleteButtonActive) {
                              setState(() {
                                isDeleteButtonActive = true;
                              });
                            }
                          } else {
                            setState(() {
                              isDeleteButtonActive = false;
                            });
                          }
                        },
                      ),
                    ):IgnorePointer(),

                    for (int i = 0; i < moveableWidgetsOnImage.length; i++)
                      Positioned.fill(
                        child: MoveableWidget(
                          item: moveableWidgetsOnImage[i],
                          onScaleEnd: (offset) {
                            setState(() {
                              showDeleteButton = false;
                            });
                            // print("From Previous End");

                            if (offset.dy >
                                (MediaQuery.of(context).size.height - 300)) {
                              setState(() {
                                moveableWidgetsOnImage
                                    .remove(moveableWidgetsOnImage[i]);
                                moveableWidgetsOnImage.insert(i, Text(""));
                              });
                            }
                          },
                          onScaleStart: () {
                            setState(() {
                              showDeleteButton = true;
                            });
                            // print("From Previous Start");
                          },
                          onDragUpdate: (offset) {
                            if (offset.dy >
                                (MediaQuery.of(context).size.height - 300)) {
                              if (!isDeleteButtonActive) {
                                setState(() {
                                  isDeleteButtonActive = true;
                                });
                              }
                            } else {
                              setState(() {
                                isDeleteButtonActive = false;
                              });
                            }
                          },
                        ),
                      ),


                    if (showDeleteButton)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Icon(
                          Icons.delete,
                          color:
                          isDeleteButtonActive ? Colors.red : Colors.black,
                          size: isDeleteButtonActive ? 40 : 30,
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              showStickerGrid
                  ? Container(
                alignment: Alignment.bottomCenter,
                child: addStickerToScreen(),
              )
                  : IgnorePointer(),
              showFrameGrid
                  ? Container(
                alignment: Alignment.bottomCenter,
                child: selectFramesForScreen(
                  // widget.frameLocationName,
                    widget.imageDetal.path,
                    frames,
                    widget.framesDetails),
              )
                  : IgnorePointer(),

              showTextField
                  ? Container(
                  alignment: Alignment.bottomCenter,
                  child:
                  addTextToScreen()

              )
                  : IgnorePointer(),

              showEchoGrid
                  ? Container(
                  alignment: Alignment.bottomCenter,
                  child:
                  addEchoEffectToScreen()

              )
                  : IgnorePointer(),

              Container(
                height: MediaQuery.of(context).size.height * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white // Background color
                      ),
                      onPressed: () {
                        setState(() {
                          showStickerGrid = false;
                          showTextField = false;
                          showEchoGrid = false;
                          // showFrameGrid = true;
                          showFrameGrid = !showFrameGrid;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_outlined,
                              color: showFrameGrid ? Colors.blue : Colors.black),
                          Text(
                            "Bgs",
                            style: TextStyle(
                                color:
                                showFrameGrid ? Colors.blue : Colors.black),
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white // Background color
                      ),
                      onPressed: () {
                        setState(() {
                          showStickerGrid = false;
                          showTextField = false;
                          showFrameGrid = false;
                          showEchoGrid = false;
                        });

                        // getImage(ImageSource.gallery);

                        getImageAndFreehandCropping(ImageSource.gallery);

                      },
                      //color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.photo_camera_outlined, color: Colors.black),
                          Text(
                            "Image",
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ),

                    widget.bannerModel.bannerName == "Echo photos"?
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white // Background color
                        ),
                        onPressed: () {
                          //addStickerToScreen();

                          setState(() {

                            showTextField = false;
                            showFrameGrid = false;
                            showStickerGrid= false;
                            // showStickerGrid = true;
                            showEchoGrid = !showEchoGrid;
                          });
                        },
                        //color: Colors.red,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.multitrack_audio,
                                color:
                                showEchoGrid ? Colors.blue : Colors.black),
                            Text(
                              "Echo",
                              style: TextStyle(
                                  color:
                                  showEchoGrid ? Colors.blue : Colors.black),
                            )
                          ],
                        ),
                      ):

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white // Background color
                      ),
                      onPressed: () {
                        //addStickerToScreen();

                        setState(() {
                          showTextField = false;
                          showFrameGrid = false;
                          showEchoGrid = false;
                          // showStickerGrid = true;
                          showStickerGrid = !showStickerGrid;
                        });
                      },
                      //color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline,
                              color:
                              showStickerGrid ? Colors.blue : Colors.black),
                          Text(
                            "Sticker",
                            style: TextStyle(
                                color:
                                showStickerGrid ? Colors.blue : Colors.black),
                          )
                        ],
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white // Background color
                      ),
                      onPressed: () {
                        setState(() {
                          showFrameGrid = false;
                          showStickerGrid = false;
                          showEchoGrid = false;
                          // showTextField = true;
                          showTextField = !showTextField;
                        });

                        // addTextToScreen();
                      },
                      //color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.text_rotation_angleup_sharp,
                              color: showTextField ? Colors.blue : Colors.black),
                          Text(
                            "Text",
                            style: TextStyle(
                                color:
                                showTextField ? Colors.blue : Colors.black),
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white // Background color
                      ),
                      onPressed: () {
                        setState(() {
                          showStickerGrid = false;
                          showTextField = false;
                          showFrameGrid = false;
                          showEchoGrid = false;
                        });
                        _capturePng(context);
                      },
                      //color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.save_alt_outlined, color: Colors.black),
                          Text(
                            "Save",
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Uint8List? image;
  // Widget? selectedImageFromGallery;

  getImageAndFreehandCropping(ImageSource media) async {

    var status = await Permission.storage.request();

    if(status.isGranted)
      {
        setState((){
          moveableImagesOnImage = Container();
          selectedImageFromGallery = IgnorePointer();
        });


        // final ImagePicker picker = ImagePicker();
        var img = await ImagePicker().pickImage(source: media);
        selectedImage = img;
        if(selectedImage != null){

          selectedImageFromGallery = await Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageCropper(imageFile: img)));


          if(widget.bannerModel.bannerName == "Echo photos" && selectedImageFromGallery!=null){

            setState(() {

              moveableImagesOnImage = IgnorePointer();
              moveableImagesOnImage = Row(
                children: [
                  selectedImageFromGallery!,
                  selectedImageFromGallery!,
                  selectedImageFromGallery!,
                  selectedImageFromGallery!,
                  selectedImageFromGallery!,
                ],
              );

            });

          }
          else{
            setState(() {
              // moveableWidgetsOnImage.add(Image.memory(image!));
              selectedImageFromGallery!=null?
              moveableWidgetsOnImage.add(selectedImageFromGallery!):
              moveableWidgetsOnImage.add(IgnorePointer());
            });
          }
      }
        else
        {
          Fluttertoast.showToast(msg: "Allow Permission to Proceed",backgroundColor: Colors.red,gravity: ToastGravity.CENTER);
        }



    }
  }

  getImageAndCropByShape(ImageSource media) async {

    setState((){
      moveableImagesOnImage = Container();
      selectedImageFromGallery = IgnorePointer();
    });


    // final ImagePicker picker = ImagePicker();
    var img = await ImagePicker().pickImage(source: media);
    selectedImage = img;
    if(selectedImage != null){

      selectedImageFromGallery = await Navigator.push(context, MaterialPageRoute(builder: (context)=>ShapeImageCropper(imageFile: img)));


      if(widget.bannerModel.bannerName == "Echo photos" && selectedImageFromGallery!=null){

        setState(() {

          moveableImagesOnImage = IgnorePointer();
          moveableImagesOnImage = Row(
            children: [
              selectedImageFromGallery!,
              selectedImageFromGallery!,
              selectedImageFromGallery!,
              selectedImageFromGallery!,
              selectedImageFromGallery!,
            ],
          );

        });

      }
      else{
        setState(() {
          selectedImageFromGallery!=null?
          moveableWidgetsOnImage.add(selectedImageFromGallery!):
          moveableWidgetsOnImage.add(IgnorePointer());
        });
      }



    }
  }



  void _capturePng(BuildContext context) async {



    var status = await Permission.storage.request();

    if(status.isGranted){
      final RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      //final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      //create file
//PAth/data/user/0/com.example.photo_frame/cache/baby2022-12-28 17:48:14.144455.png
//     final String dir = (await getApplicationDocumentsDirectory()).path;
      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String fullPath =
          '$dir/' + widget.frameCategoryName + '${DateTime.now()}.jpg';
      print(dir);
      File capturedFile = File(fullPath);
      await capturedFile.writeAsBytes(pngBytes);
      print("Captured Path" + capturedFile.path);

      await GallerySaver.saveImage(capturedFile.path,
          albumName: widget.frameCategoryName, toDcim: true)
      //await GallerySaver.saveImage(capturedFile.path)
          .then((value) {
        if (value == true) {
          Fluttertoast.showToast(
              msg: "Image saved Successfully", backgroundColor: Colors.green);
        } else {
          Fluttertoast.showToast(
              msg: "Failed to save", backgroundColor: Colors.red);
        }
      });
    }
    else{
      Fluttertoast.showToast(msg: "Allow Permission to Proceed",backgroundColor: Colors.red,gravity: ToastGravity.CENTER);
    }


  }

  addEchoEffectToScreen() {

    return Container(
      padding: EdgeInsets.only(bottom: 5, top: 5),
      height: MediaQuery.of(context).size.height * 0.15,
      // color: Colors.orangeAccent,
      color: Colors.purple.withOpacity(0.5),

      child: EchoGridView(
          StickersList: stickersList,
          addStickerToScreen: (imgName) {
            setState(() {
              // print(imgName);
              // moveableWidgetsOnImage.add(Image.asset(imgName));
              moveableImagesOnImage = IgnorePointer();
              moveableImagesOnImage = imgName;

              // moveableWidgetsOnImage.add(Image.asset(imgName));
            });
          }),
    );

  }

  addStickerToScreen() {
    return Container(
      padding: EdgeInsets.only(bottom: 5, top: 5),
      height: MediaQuery.of(context).size.height * 0.15,
      // color: Colors.orangeAccent,
      color: Colors.purple.withOpacity(0.5),
      child: StickersGrid(
          StickersList: stickersList,
          addStickerToScreen: (imgName) {
            setState(() {
              // print(imgName);
              moveableWidgetsOnImage.add(Image.asset(imgName));
            });
          }),
    );
  }

  addTextToScreen() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          // topRight: Radius.circular(30),
          // topLeft: Radius.circular(30),
        ),
      ),
      height: MediaQuery.of(context).size.height / 2,
      child: TextEditor(
        fonts: const [
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
          '7',
          '8',
          '9',
          '10',
          '11',
          '12',
          '13'
        ],
        maxFontSize: 50,
        textStyle: TextStyle(fontSize: 25),
        decoration: EditorDecoration(
          doneButton: Container(
            decoration:
            const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: const Icon(
              Icons.check,
              color: Colors.green,
              size: 50,
            ),
          ),
          fontFamily: Icon(Icons.title, color: Colors.white),
        ),
        onEditCompleted: (TextStyle, TextAlign, String) {
          textOnImage = Text(String, style: TextStyle);
          setState(() {
            showTextField = false;
            moveableWidgetsOnImage.add(textOnImage!);
          });
        },
      ),
    );
  }

  selectFramesForScreen(
      String frameLocationName, List<String> frames, framesDetails) {
    return Container(
      padding: EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.18,
      color: Colors.black,
      // color: Colors.purple.withOpacity(0.5),
      child: FramesGrid(
        bannerModel: widget.bannerModel,
        framesDetails: framesDetails,
        frameLocationName: frameLocationName,
        frames: frames,
        changeFrame: (frameName) {
          setState(() {
            widget.imageDetal = frameName;
          });
        },
      ),
    );
  }



  // void loadFrames() async {
  //   final manifestContent = await rootBundle.loadString('AssetManifest.json');
  //   final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  //
  //   final framesPath = manifestMap.keys
  //       .where((String key) => key.contains(
  //           'assets/categories/frames/' + widget.imageDetal.frameName + '/'))
  //       .toList();
  //   frames = framesPath;
  // }

  void loadStickers() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final stickersPath = manifestMap.keys
        .where((String key) => key.contains('assets/stickers/'))
        .toList();
    stickersList = stickersPath;
  }

  void loadFonts() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final fontsPath = manifestMap.keys
        .where((String key) => key.contains('assets/fonts'))
        .toList();
    fontsInTextEditor = fontsPath;
  }

  Future<bool> backButtonPress() async {
    if (showStickerGrid == true ||
        showTextField == true ||
        showFrameGrid == true ||
        showEchoGrid ==true) {
      setState(() {
        showStickerGrid = false;
        showTextField = false;
        showFrameGrid = false;
        showEchoGrid =false;
      });

      return await false;
    } else
      Navigator.pop(context);
      return await false;
      // return await true;
  }



}

class FramesGrid extends StatefulWidget {
  String frameLocationName;
  List<String> frames;
  List<ImgDetails> framesDetails;
  void Function(ImgDetails) changeFrame;
  BannerModel bannerModel;

  FramesGrid(
      {Key? key,
        required this.frameLocationName,
        required this.frames,
        required this.changeFrame,
        required this.framesDetails,
      required this.bannerModel})
      : super(key: key);

  @override
  State<FramesGrid> createState() => _FramesGridState();
}

class _FramesGridState extends State<FramesGrid> {
  bool isInterstitialLoaded = false;
  InterstitialAd? interstitialAd;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _createInterstitialAd();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              isInterstitialLoaded = true;
              print("Ad Loaded");

              interstitialAd = ad;
            },
            onAdFailedToLoad: (LoadAdError error) => interstitialAd = null));
  }

  void showInterstitialAd() {
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('%ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
      onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
    );
    interstitialAd!.show();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.vertical,
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: List.generate(
        widget.framesDetails.length,
            (index) => singleFrame(context, widget.framesDetails[index],index),
      ),
    );
  }

  Widget singleFrame(BuildContext context, ImgDetails imageDetail,int index) {
    return GestureDetector(
      onTap: () async{
        if(imageDetail.category=='cloud'){
          if(index % 2 == 1){

            if (isInterstitialLoaded == true) {
              interstitialAd!.fullScreenContentCallback =
                  FullScreenContentCallback(
                      onAdShowedFullScreenContent:
                          (InterstitialAd ad) => print(
                          '%ad onAdShowedFullScreenContent.'),
                      onAdDismissedFullScreenContent:
                          (InterstitialAd ad) async {
                        print('$ad Ad has been Dismissed');
                        print("INDEX VALUE :: $index");
                        // downloadSingleFrame(
                        //     index, imageNames);
                        widget.changeFrame(await downloadFrame(imageDetail.frameName, index));
                        print(
                            '$ad onAdDismissedFullScreenContent.');
                        _createInterstitialAd();
                        // Navigator.pop(context);

                        ad.dispose();
                      },
                      onAdFailedToShowFullScreenContent:
                          (InterstitialAd ad,
                          AdError error) {
                        print(
                            '$ad onAdFailedToShowFullScreenContent: $error');
                        ad.dispose();
                      },
                      onAdImpression: (InterstitialAd ad) {
                        isInterstitialLoaded = false;
                        _createInterstitialAd();
                        // Navigator.pop(context);
                        setState(() {});
                      });

              interstitialAd!.show();
            } else {
              widget.changeFrame(await downloadFrame(imageDetail.frameName, index));
              // downloadSingleFrame(index, imageNames);
            }
          }else{
            widget.changeFrame(await downloadFrame(imageDetail.frameName, index));
          }
          widget.changeFrame(await downloadFrame(imageDetail.frameName,index));
        }else{
          widget.changeFrame(imageDetail);
        }


      },
      child: Container(
        color: Colors.white,
        child: imageDetail.category == "assets"
            ? Image(
          fit: BoxFit.cover,
          image: AssetImage(imageDetail.path),
        )
            : imageDetail.category == "local"
            ? Image(
          fit: BoxFit.cover,
          image: FileImage(File(imageDetail.path)),
        )
            : Stack(
          children: [
            Positioned.fill(
              child: Image(
                fit: BoxFit.cover,
                image: NetworkImage(imageDetail.path),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(
                        Radius.circular(6)
                    )),
                child: Icon(
                  index % 2 == 0 ? Icons.download : Icons.lock,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  downloadFrame(imageNames, int index) async {



    String namePrefix = widget.bannerModel.cloudReferenceName + "%2F" +
        widget.bannerModel.frameLocationName;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$namePrefix%2F${imageNames}');

    await FirebaseStorage.instance
        .ref('${widget.bannerModel.cloudReferenceName}/${widget.bannerModel
        .frameLocationName}')
        .child(imageNames)
        .writeToFile(file);


    widget.framesDetails.removeAt(index);
    widget.framesDetails.insert(index,
        ImgDetails(
            path: file.path, category: "local", frameName: imageNames));


    return widget.framesDetails[index];


  }
}

class StickersGrid extends StatefulWidget {
  List<String> StickersList;
  void Function(String) addStickerToScreen;

  StickersGrid(
      {Key? key, required this.StickersList, required this.addStickerToScreen})
      : super(key: key);

  @override
  State<StickersGrid> createState() => _StickersGridState();
}

class _StickersGridState extends State<StickersGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.vertical,
      crossAxisCount: 5,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      children: List.generate(
        widget.StickersList.length,
            (index) => singleSticker(context, widget.StickersList[index]),
      ),
    );
  }

  Widget singleSticker(BuildContext context, imageNames) {
    return GestureDetector(
      onTap: () {
        widget.addStickerToScreen(imageNames);
      },
      child: Container(
        color: Colors.white,
        child: Image(
          image: AssetImage(imageNames),
        ),
      ),
    );
  }
}

class EchoGridView extends StatefulWidget {
  List<String> StickersList;
  void Function(Widget) addStickerToScreen;

  EchoGridView(
      {Key? key, required this.StickersList, required this.addStickerToScreen})
      : super(key: key);

  @override
  State<EchoGridView> createState() => _EchoGridViewState();
}

class _EchoGridViewState extends State<EchoGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.vertical,
      crossAxisCount: 5,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      children: List.generate(
        5,
            (index) => singleSticker(context, widget.StickersList[index],index),
      ),
    );
  }

  Widget singleSticker(BuildContext context, imageNames,int index) {
    return GestureDetector(
      onTap: () {

        switch(index) {
          case 0: {
            // statements;
            widget.addStickerToScreen(Column(
              children: [
                selectedImageFromGallery!,
                selectedImageFromGallery!,
                selectedImageFromGallery!,
                selectedImageFromGallery!,
              ],
            ));


          }
          break;

          case 1: {
            //statements;

            widget.addStickerToScreen(Row(
              children: [
                selectedImageFromGallery!,
                selectedImageFromGallery!,
                selectedImageFromGallery!,
                selectedImageFromGallery!,
              ],
            ));


          }
          break;

          case 2: {
            //statements;


            widget.addStickerToScreen(Row(
              children: [
                Column(
                  children: [
                    selectedImageFromGallery!,
                    selectedImageFromGallery!,
                  ],
                ),

                Column(
                  children: [
                    selectedImageFromGallery!,
                    selectedImageFromGallery!,
                  ],
                ),

              ],
            ));

          }
          break;

          case 3: {
            //statements;
            widget.addStickerToScreen(Row(
              children: [
                Column(
                  children: [
                    selectedImageFromGallery!,
                    selectedImageFromGallery!,
                  ],
                ),
                selectedImageFromGallery!,
                Column(
                  children: [
                    selectedImageFromGallery!,
                    selectedImageFromGallery!,
                  ],
                ),

              ],
            ));


          }
          break;

          case 4: {
            //statements;
            widget.addStickerToScreen(Row(
              children: [
                Column(
                  children: [
                    selectedImageFromGallery!,
                    selectedImageFromGallery!,
                    selectedImageFromGallery!,
                  ],
                ),
                // selectedImageFromGallery!,
                // selectedImageFromGallery!,
                Column(
                  children: [
                    selectedImageFromGallery!,
                    selectedImageFromGallery!,
                    selectedImageFromGallery!,
                  ],
                ),

              ],
            ));
          }
          break;

          default: {
            //statements;
          }
          break;
        }
        // widget.addStickerToScreen(imageNames);
      },
      child: Container(
        color: Colors.white,
        child:Container(color: Colors.white,
        child: Center(child: Text((index+1).toString(),style: TextStyle(fontSize: 20),)),
        )
        // Image(
        //   image: AssetImage(imageNames),
        // ),
      ),
    );
  }
}
