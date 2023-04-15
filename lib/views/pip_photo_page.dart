import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_frame_second/global_items/global_items.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/models/image_detail_model.dart';
import 'package:photo_frame_second/widgets/moveable_widget.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'package:text_editor/text_editor.dart';
import 'package:widget_mask/widget_mask.dart';

class SinglePipFrame extends StatefulWidget {
  ImgDetails imageDetal;
  List<ImgDetails> framesDetails;
  String frameCategoryName;
  bool imageOnFront = false;
  BannerModel bannerModel;

  SinglePipFrame(
      {Key? key,
        required this.imageDetal,
        required this.framesDetails,
        required this.frameCategoryName,
        required this.bannerModel})
      : super(key: key);

  @override
  State<SinglePipFrame> createState() => _SinglePipFrameState();
}

class _SinglePipFrameState extends State<SinglePipFrame> {
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());

  List<String> frames = [];
  List<String> fontsInTextEditor = [];
  List<String> stickersList = [];

  XFile? selectedImage;
  File? imgFile;
  final ImagePicker picker = ImagePicker();
  GlobalKey _globalKey = GlobalKey();
  bool showFrameGrid = false,
      showDeleteButton = false,
      isDeleteButtonActive = false,
      showStickerGrid = false,
      showTextField = false;

  Widget? textOnImage;
  List<Widget> moveableWidgetsOnImage = [];
  List<Widget> moveableImagesOnImage = [];

  String whiteBackground ="";
  String framePath = "";
  double blurValue = 5.0;


  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    log(widget.imageDetal.path);
    log(widget.imageDetal.frameName);
    log(widget.imageDetal.category);
    whiteBackground = widget.imageDetal.path.replaceAll("preview", "whiteBackground");
    framePath = widget.imageDetal.path.replaceAll("preview", "frames");
    loadFonts();
    // loadFrames();
    loadStickers();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backButtonPress,
      child: OurScaffold(
        appBarTitle: "Photo Frame",
        scaffoldBody: Padding(
          padding: //EdgeInsets.all(0),
          EdgeInsets.fromLTRB(
              0, 0, 0, MediaQuery.of(context).size.height * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text("Change Blur Effect",style: TextStyle(fontWeight: FontWeight.bold),),
                  Slider(
                    activeColor: Colors.deepOrange,
                    inactiveColor: Colors.orangeAccent,
                    min: 0,
                    max: 50,
                    value: blurValue,
                    onChanged: (value) {
                      setState(() {
                        blurValue = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height * 80,
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                      Positioned.fill(
                        child: selectedImage == null
                            ? Container()
                            : MoveableWidget(
                          onDragUpdate: (offset) {},
                          onScaleStart: () {},
                          onScaleEnd: (offset) {},
                          item: Image.file(File(selectedImage!.path)),
                        ),
                      ),


                      Stack(
                        children: [
                          Stack(
                            fit: StackFit.expand,
                            children: [
                              // Image.asset("assets/categories/pip/arbad.jpg"),
                              selectedImage == null
                                  ? Image.asset(
                                  fit: BoxFit.cover,
                                  widget.bannerModel.bannerImagePath)
                                  : Image.file(
                                  fit: BoxFit.cover,
                                  File(selectedImage!.path)),
                              ClipRRect(
                                // Clip it cleanly.
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      // sigmaX: 3, sigmaY: 3
                                      sigmaX:blurValue, sigmaY: blurValue
                                  ),
                                  child: Container(
                                    // color: Colors.grey.withOpacity(0.1),
                                    alignment: Alignment.center,
                                    // child: Text('CHOCOLATE'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 300,
                                  height: 300,
                                  child: WidgetMask(
                                    blendMode: BlendMode.srcATop,
                                    child: Column(
                                      children: [
                                        widget.imageDetal.category ==
                                            "assets"?
                                        Image.asset(whiteBackground):
                                        Image.file(File(whiteBackground)),
                                      ],
                                    ),
                                    childSaveLayer: true,
                                    mask: MoveableWidget(
                                        onDragUpdate: (offset) {},
                                        onScaleStart: () {},
                                        onScaleEnd: (offset) {},
                                        item: selectedImage == null
                                            ? IgnorePointer()
                                            : Image.file(File(selectedImage!.path),),),
                                  ),
                                ),
                                IgnorePointer(
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    // child:
                                    decoration: BoxDecoration(
                                      image: widget.imageDetal.category ==
                                          "assets"
                                          ? DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              // widget.imageDetal.path
                                                  framePath
                                          ),)
                                          : DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(File(
                                              // widget.imageDetal.path
                                              framePath
                                          ),),),
                                    ),
                                    // Image.asset("assets/categories/pip/3_fg.png")
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

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
                                  (MediaQuery.of(context).size.height - 250)) {
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
                                  (MediaQuery.of(context).size.height - 250)) {
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
                      // showTextField
                      //     ? Container(
                      //         alignment: Alignment.bottomCenter,
                      //         child: addTextToScreen(),
                      //       )
                      //     : IgnorePointer(),

                      // showFrameGrid
                      //     ? Container(
                      //         alignment: Alignment.bottomCenter,
                      //         child: selectFramesForScreen(
                      //             // widget.frameLocationName,
                      //             widget.imageDetal.path,
                      //             frames),
                      //       )
                      //     : IgnorePointer(),

                      // showStickerGrid
                      //     ? Container(
                      //         alignment: Alignment.bottomCenter,
                      //         child: addStickerToScreen(),
                      //       )
                      //     : IgnorePointer(),
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
            ],
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
                  child: addTextToScreen())
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
                          // showFrameGrid = true;
                          showFrameGrid = !showFrameGrid;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_frames_outlined,
                              color:
                              showFrameGrid ? Colors.blue : Colors.black),
                          Text(
                            "Frames",
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
                        });
                        getImage(ImageSource.gallery);
                      },
                      //color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_outlined, color: Colors.black),
                          Text(
                            "Image",
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
                        //addStickerToScreen();

                        setState(() {
                          showTextField = false;
                          showFrameGrid = false;
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
                                color: showStickerGrid
                                    ? Colors.blue
                                    : Colors.black),
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
                              color:
                              showTextField ? Colors.blue : Colors.black),
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
                        });
                        _capturePng(context);
                      },
                      //color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    // print("Img Path"+img!.path);

    setState(() {
      selectedImage = img;
      moveableImagesOnImage.add(Image.file(File(selectedImage!.path)));
    });
  }

  void _capturePng(BuildContext context) async {
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
        fonts: [
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
            BoxDecoration(color: Colors.black, shape: BoxShape.circle),
            child: Icon(
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
            whiteBackground = widget.imageDetal.path.replaceAll("preview", "whiteBackground");
            framePath = widget.imageDetal.path.replaceAll("preview", "frames");
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
        showFrameGrid == true) {
      setState(() {
        showStickerGrid = false;
        showTextField = false;
        showFrameGrid = false;
      });

      return await false;
    } else

      return await true;
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
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.vertical,
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: List.generate(
        widget.framesDetails.length,
            (index) => singleFrame(context, widget.framesDetails[index], index),
      ),
    );
  }

  Widget singleFrame(BuildContext context, ImgDetails imageDetail, int index) {
    return GestureDetector(
      onTap: () async {
        if (imageDetail.category == 'cloud') {
          widget.changeFrame(await downloadFrame(imageDetail.frameName, index));
        } else {
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
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                    BorderRadius.all(Radius.circular(30))),
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


    String namePrefixFrames = widget.bannerModel.cloudReferenceName + "%2F" + "frames";
    String namePrefixPreview = widget.bannerModel.cloudReferenceName + "%2F" + "preview";
    String namePrefixWhiteBackground = widget.bannerModel.cloudReferenceName + "%2F" + "whiteBackground";




    final dir = await getApplicationDocumentsDirectory();

    final filePreview = File('${dir.path}/$namePrefixPreview%2F${imageNames}');
    final fileFrame = File('${dir.path}/$namePrefixFrames%2F${imageNames}');
    final fileWhiteBackground = File('${dir.path}/$namePrefixWhiteBackground%2F${imageNames}');


    await FirebaseStorage.instance
        .ref('${widget.bannerModel.cloudReferenceName}/preview')
        .child(imageNames)
        .writeToFile(filePreview);

    await FirebaseStorage.instance
        .ref('${widget.bannerModel.cloudReferenceName}/frames')
        .child(imageNames)
        .writeToFile(fileFrame);

    await FirebaseStorage.instance
        .ref('${widget.bannerModel.cloudReferenceName}/whiteBackground')
        .child(imageNames)
        .writeToFile(fileWhiteBackground);

    widget.framesDetails.removeAt(index);
    widget.framesDetails.insert(index,
        ImgDetails(
            path: filePreview.path, category: "local", frameName: imageNames));


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
