import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_frame_second/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/models/image_detail_model.dart';
import 'package:photo_frame_second/views/pip_photo_page.dart';
import 'package:photo_frame_second/views/single_frame.dart';

class PipItemsGridView extends StatefulWidget {
  BannerModel bannerModel;
  PipItemsGridView({Key? key, required this.bannerModel}) : super(key: key);
  String conivicityString = "CON";
  @override
  State<PipItemsGridView> createState() => _PipItemsGridViewState();
}

class _PipItemsGridViewState extends State<PipItemsGridView> {
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  final scrollController = ScrollController(initialScrollOffset: 0);
  late Future<ListResult> listOfFramesFromClod;
  List<ImgDetails> framesDetails = [];
  Map<int, bool> isDownloading = {};
  int localFramesCount = 0;
  late bool isConnected;
  bool isInterstitialLoaded = false;
  InterstitialAd? interstitialAd;
  // Map _source = {ConnectivityResult.none: false};
  // final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createInterstitialAd();

    // _createRewardedAd();
    listOfFramesFromClod = FirebaseStorage.instance
        // .ref('${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
        .ref('${widget.bannerModel.cloudReferenceName}/preview')
        .list();

    loadFramesFromAssets();
  }

  Future<void> _createRewardedAd() async {
    RewardedAd.loadWithAdManagerAdRequest(
      adUnitId: AdMobService.rewardedAdUnitId,
      adManagerRequest: const AdManagerAdRequest(),
      // adManagerAdRequest: AdManagerAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('$ad loaded.');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          //  _rewardedAd = null;
          //_numRewardedLoadAttempts += 1;
          // if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
          //   _createRewardedAd();
          // }
        },
      ),
    );
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

  // void _createRewardedAd() {
  //   RewardedAd.load(
  //     // adUnitId: AdMobService.rewardedAdUnitId,
  //       adUnitId: AdMobService.interstitialAdUnitId,
  //
  //       request: AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (RewardedAd ad) {
  //           print('$ad loaded.');
  //           _rewardedAd = ad;
  //           _numRewardedLoadAttempts = 0;
  //         },
  //         onAdFailedToLoad: (LoadAdError error) {
  //           print('RewardedAd failed to load: $error');
  //           _rewardedAd = null;
  //           _numRewardedLoadAttempts += 1;
  //           if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
  //             _createRewardedAd();
  //           }
  //         },
  //       ));
  // }

  void loadFramesFromAssets() async {
    // print('${widget.bannerModel.assetsCompletePath}/${widget.bannerModel.frameLocationName}/');
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // log(json.decode(manifestContent).toString());
    final imagePaths = manifestMap.keys.where((String key) => key.contains(
        // '${widget.bannerModel.assetsCompletePath}/${widget.bannerModel.frameLocationName}/'))
        '${widget.bannerModel.assetsCompletePath}/preview/')).toList();
    for (int i = 0; i < imagePaths.length; i++) {
      framesDetails.add(ImgDetails(
          path: imagePaths[i],
          category: 'assets',
          frameName: imagePaths[i].split(Platform.pathSeparator).last));
    }

    setState(() {});
    loadFramesFromLocal();
  }

  void loadFramesFromLocal() async {
    // String namePrefix = widget.bannerModel.cloudReferenceName +"%2F"+ widget.bannerModel.frameLocationName;
    String namePrefix =
        widget.bannerModel.cloudReferenceName + "%2F" + "preview";
    final String dir = (await getApplicationDocumentsDirectory()).path;
    io.Directory("$dir").listSync().forEach((element) {
      if (element.path.contains(namePrefix)) {
        // print("foreash");
        // print(element.path);
        framesDetails.add(ImgDetails(
            path: element.path,
            category: 'local',
            frameName: element.path.split(Platform.pathSeparator).last));
      }
      ;
    });

    setState(() {});
    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      loadFramesFromCloud();
    }
    // loadFramesFromCloud();
  }

  void loadFramesFromCloud() async {
    print("INSIDE CLOUD");
    // print("Cloud reference name = " +widget.bannerModel.cloudReferenceName);
    // print("Frame location name = " +widget.bannerModel.frameLocationName);
    localFramesCount = framesDetails.length;

    final _firestorage = FirebaseStorage.instance;
    final refs = await _firestorage
        // .ref('${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
        .ref('${widget.bannerModel.cloudReferenceName}/preview')
        .list();

    for (Reference ref in refs.items) {
      String url = await ref.getDownloadURL();
      bool isFrameFoundLocally = false;

      // print("URL=");
      // print(url);
      for (int i = 0; i < localFramesCount; i++) {
        if (url.contains(framesDetails[i].frameName)) {
          isFrameFoundLocally = true;
        }
      }

      if (isFrameFoundLocally == false) {
        framesDetails
            .add(ImgDetails(path: url, category: 'cloud', frameName: ref.name));
        setState(() {});
      }
    }
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      controller: scrollController,
      scrollDirection: Axis.vertical,
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      childAspectRatio: 1,
      children: List.generate(
        framesDetails.length,
        (index) => singleCategory(context, framesDetails[index], index),
      ),
      // ),
    );
  }

  singleCategory(BuildContext context, ImgDetails frameDetail, int index) {
    if (isDownloading[index] == null) {
      isDownloading[index] = false;
    }

    // print("in build method = "+isDownloading[index].toString());
    return isDownloading[index]!
        ? Center(child: CircularProgressIndicator(color: Colors.orange))
        : Container(
            padding: EdgeInsets.all(5),
            child: frameDetail.category != 'cloud'
                ? InkWell(
                    borderRadius: BorderRadius.only(
                      bottomLeft: index % 2 == 1
                          ? Radius.circular(6)
                          : Radius.circular(6),
                      bottomRight: index % 2 == 0
                          ? Radius.circular(6)
                          : Radius.circular(6),
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    highlightColor: Colors.orangeAccent.withOpacity(0.3),
                    splashColor: Colors.orangeAccent.withOpacity(0.3),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SinglePipFrame(
                                    bannerModel: widget.bannerModel,
                                    imageDetal: frameDetail,
                                    framesDetails: framesDetails,
                                    frameCategoryName:
                                        widget.bannerModel.frameLocationName,
                                  ))).then((value) => (setState(() {})));
                    },
                    child: isDownloading[index]!
                        ? const CircularProgressIndicator(color: Colors.orange)
                        : Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: index % 2 == 1
                                    ? Radius.circular(6)
                                    : Radius.circular(6),
                                bottomRight: index % 2 == 0
                                    ? Radius.circular(6)
                                    : Radius.circular(6),
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              image: frameDetail.category == 'assets'
                                  ? DecorationImage(
                                      image: AssetImage(frameDetail.path),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: FileImage(File(frameDetail.path)),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                  )
                : Stack(children: [
                    InkWell(
                      borderRadius: BorderRadius.only(
                        bottomLeft: index % 2 == 1
                            ? Radius.circular(6)
                            : Radius.circular(6),
                        bottomRight: index % 2 == 0
                            ? Radius.circular(6)
                            : Radius.circular(6),
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      highlightColor: Colors.orangeAccent.withOpacity(0.3),
                      splashColor: Colors.orangeAccent.withOpacity(0.3),
                      onTap: () {
                        downloadFrame(frameDetail.frameName, index);
                      },
                      child:
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: index % 2 == 1
                                ? Radius.circular(6)
                                : Radius.circular(6),
                            bottomRight: index % 2 == 0
                                ? Radius.circular(6)
                                : Radius.circular(6),
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                          image: DecorationImage(
                            image:NetworkImage(frameDetail.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // CachedNetworkImage(
                      //   imageUrl: frameDetail.path,
                      //   progressIndicatorBuilder:
                      //       (context, url, downloadProgress) => Center(
                      //           child: CircularProgressIndicator(
                      //               color: Colors.orange,
                      //               value: downloadProgress.progress)),
                      //   imageBuilder: (context, imageProvider) => Ink(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.only(
                      //         bottomLeft: index % 2 == 1
                      //             ? Radius.circular(6)
                      //             : Radius.circular(6),
                      //         bottomRight: index % 2 == 0
                      //             ? Radius.circular(6)
                      //             : Radius.circular(6),
                      //         topLeft: Radius.circular(6),
                      //         topRight: Radius.circular(6),
                      //       ),
                      //       image: DecorationImage(
                      //         // image: NetworkImage(frameDetail.path),
                      //         image: imageProvider,
                      //         fit: BoxFit.cover,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: index % 2 == 1 ? null : 10,
                      left: index % 2 == 1 ? 10 : null,
                      child: IgnorePointer(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                bottomLeft: index % 2 == 1
                                    ? Radius.circular(6)
                                    : Radius.circular(6),
                                bottomRight: index % 2 == 0
                                    ? Radius.circular(6)
                                    : Radius.circular(6),
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              )),
                          child: Icon(
                            index % 2 == 0 ? Icons.download : Icons.lock,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ]),
          );
  }



  Future<void> _showRewardedAd() async {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        print('ad onAdShowedFullScreenContent.');
        log("1");
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        // _createRewardedAd();
        log("2");
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        // _createRewardedAd();
        log("3");
      },
      onAdImpression: (RewardedAd ad) => print('$ad impression occurred.'),
    );

    // _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print("Inside Show Functions");
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
  }

  Future downloadFrame(imageNames, int index) async {

    if (index % 2 == 1) {
      print("It is Locked Frame: $index");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 200,
                child: Column(
                  children: [
                    AppBar(
                      title: Text("Download"),
                      backgroundColor: Colors.lightBlue,
                      automaticallyImplyLeading: false,
                    ),
                    Container(
                      height: 15,
                      color: Colors.lightBlue.withOpacity(0.6),
                    ),
                    Container(
                      height: 15,
                      color: Colors.lightBlue.withOpacity(0.4),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Would you like to unlock frame ? ",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No")),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            // _createRewardedAd();


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
                                        downloadSingleFrame(
                                            index, imageNames);
                                        print(
                                            '$ad onAdDismissedFullScreenContent.');
                                        _createInterstitialAd();
                                        Navigator.pop(context);

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
                                        Navigator.pop(context);
                                        setState(() {});
                                      });

                              interstitialAd!.show();
                            } else {
                              downloadSingleFrame(index, imageNames);
                            }

                          },
                          child:
                          isInterstitialLoaded == true
                              ?  Text(
                            "Watch Ad",)
                              : const Text(
                            "Download Frame",),

                          // Text("Watch Ad")

                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
    } else {


      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 200,
                child: Column(
                  children: [
                    AppBar(
                      title: Text("Download"),
                      backgroundColor: Colors.lightBlue,
                      automaticallyImplyLeading: false,
                    ),
                    Container(
                      height: 15,
                      color: Colors.lightBlue.withOpacity(0.6),
                    ),
                    Container(
                      height: 15,
                      color: Colors.lightBlue.withOpacity(0.4),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Would you like to download frame ? ",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No")),
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);

                              if (await InternetConnectionChecker()
                                  .hasConnection) {
                                downloadSingleFrame(index, imageNames);
                                // downloadSingleFrame(index, imageNames);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Check internet Connection",
                                    backgroundColor: Colors.red);
                              }
                            },
                            child: Text("Download")),
                      ],
                    )
                  ],
                ),
              ),
            );
          });

    }





    // if (index % 2 == 1) {
    //   // await _createRewardedAd();
    //
    //   print("It is Locked Frame: $index");
    //
    //   if (isInterstitialLoaded == true) {
    //     showModalBottomSheet(
    //         context: context,
    //         builder: (context) {
    //           return StatefulBuilder(
    //               builder: ((BuildContext context, StateSetter setState) {
    //                 return Container(
    //                   height: 310,
    //                   child: Container(
    //                     padding: EdgeInsets.only(top: 20),
    //                     width: MediaQuery.of(context).size.width * 0.90,
    //                     child: Column(
    //                       children: [
    //                         const Text(
    //                           "Choose Your Option",
    //                           style: TextStyle(
    //                               fontWeight: FontWeight.bold, fontSize: 24),
    //                         ),
    //                         const SizedBox(
    //                           height: 20,
    //                         ),
    //                         Row(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                           children: [
    //                             InkWell(
    //                               onTap: () {
    //                                 Navigator.pop(context);
    //                               },
    //                               child: Container(
    //                                 decoration: BoxDecoration(
    //                                     color: Colors.blue,
    //                                     borderRadius: BorderRadius.circular(6)),
    //                                 width: MediaQuery.of(context).size.width * .39,
    //                                 height:
    //                                 MediaQuery.of(context).size.height * .21,
    //                                 child: Column(
    //                                   mainAxisAlignment: MainAxisAlignment.center,
    //                                   children: <Widget>[
    //                                     Container(
    //                                       width: MediaQuery.of(context).size.width *
    //                                           .85,
    //                                       child: const Icon(
    //                                         Icons.close,
    //                                         color: Colors.white,
    //                                         size: 110,
    //                                       ),
    //                                     ),
    //                                     const Text(
    //                                       "May be Later",
    //                                       style: TextStyle(
    //                                           fontWeight: FontWeight.bold,
    //                                           color: Colors.white,
    //                                           fontSize: 18),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                             InkWell(
    //                               onTap: () async {
    //                                 if (isInterstitialLoaded == true) {
    //                                   interstitialAd!.fullScreenContentCallback =
    //                                       FullScreenContentCallback(
    //                                           onAdShowedFullScreenContent:
    //                                               (InterstitialAd ad) => print(
    //                                               '%ad onAdShowedFullScreenContent.'),
    //                                           onAdDismissedFullScreenContent:
    //                                               (InterstitialAd ad) async {
    //                                             print('$ad Ad has been Dismissed');
    //                                             print("INDEX VALUE :: $index");
    //                                             downloadSingleFrame(
    //                                                 index, imageNames);
    //                                             print(
    //                                                 '$ad onAdDismissedFullScreenContent.');
    //                                             _createInterstitialAd();
    //                                             Navigator.pop(context);
    //
    //                                             ad.dispose();
    //                                           },
    //                                           onAdFailedToShowFullScreenContent:
    //                                               (InterstitialAd ad,
    //                                               AdError error) {
    //                                             print(
    //                                                 '$ad onAdFailedToShowFullScreenContent: $error');
    //                                             ad.dispose();
    //                                           },
    //                                           onAdImpression: (InterstitialAd ad) {
    //                                             isInterstitialLoaded = false;
    //                                             _createInterstitialAd();
    //                                             Navigator.pop(context);
    //                                             setState(() {});
    //                                           });
    //
    //                                   interstitialAd!.show();
    //                                 } else {
    //                                   downloadSingleFrame(index, imageNames);
    //                                 }
    //
    //                                 //Navigator.pop(context);
    //                               },
    //                               child: Container(
    //                                 decoration: BoxDecoration(
    //                                     color: Colors.blue,
    //                                     borderRadius: BorderRadius.circular(6)),
    //                                 width: MediaQuery.of(context).size.width * .39,
    //                                 height:
    //                                 MediaQuery.of(context).size.height * .21,
    //                                 child: Column(
    //                                   mainAxisAlignment: MainAxisAlignment.center,
    //                                   children: <Widget>[
    //                                     Container(
    //                                       width: MediaQuery.of(context).size.width *
    //                                           .85,
    //                                       child: Icon(
    //                                         isInterstitialLoaded == true
    //                                             ? FontAwesomeIcons.award
    //                                             : Icons.download,
    //                                         color: Colors.white,
    //                                         size: 110,
    //                                       ),
    //                                     ),
    //                                     const SizedBox(
    //                                       height: 10,
    //                                     ),
    //                                     Flexible(
    //                                       child: isInterstitialLoaded == true
    //                                           ? const Text(
    //                                         "Watch Ad",
    //                                         style: TextStyle(
    //                                             fontWeight: FontWeight.bold,
    //                                             color: Colors.white,
    //                                             fontSize: 18),
    //                                       )
    //                                           : const Text(
    //                                         "Download Frame",
    //                                         style: TextStyle(
    //                                             fontWeight: FontWeight.bold,
    //                                             color: Colors.white,
    //                                             fontSize: 18),
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 );
    //               }));
    //         });
    //
    //
    //
    // }
    // }
    // else {
    //   // String namePrefix = widget.bannerModel.cloudReferenceName + "%2F" +
    //   //     widget.bannerModel.frameLocationName;
    //
    //
    //   showModalBottomSheet(
    //       context: context,
    //       builder: (context) {
    //         return StatefulBuilder(builder: ((context, setState) {
    //           return Container(
    //             height: 310,
    //             child: Container(
    //               padding: EdgeInsets.only(top: 20),
    //               width: MediaQuery.of(context).size.width * 0.90,
    //               child: Column(
    //                 children: [
    //                   const Text(
    //                     "Choose Your Option",
    //                     style: TextStyle(
    //                         fontWeight: FontWeight.bold, fontSize: 24),
    //                   ),
    //                   const SizedBox(
    //                     height: 20,
    //                   ),
    //                   Row(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                     children: [
    //                       InkWell(
    //                         onTap: () {
    //                           Navigator.pop(context);
    //                         },
    //                         child: Container(
    //                           decoration: BoxDecoration(
    //                               color: Colors.blue,
    //                               borderRadius: BorderRadius.circular(6)),
    //                           width: MediaQuery.of(context).size.width * .39,
    //                           height:
    //                           MediaQuery.of(context).size.height * .21,
    //                           child: Column(
    //                             mainAxisAlignment: MainAxisAlignment.center,
    //                             children: <Widget>[
    //                               Container(
    //                                 width: MediaQuery.of(context).size.width *
    //                                     .85,
    //                                 child: const Icon(
    //                                   Icons.close,
    //                                   color: Colors.white,
    //                                   size: 110,
    //                                 ),
    //                               ),
    //                               const Text(
    //                                 "May be Later",
    //                                 style: TextStyle(
    //                                     fontWeight: FontWeight.bold,
    //                                     color: Colors.white,
    //                                     fontSize: 18),
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                       InkWell(
    //                         onTap: () async {
    //                           //Navigator.pop(context);
    //                           print("DOWNLOAD");
    //                           print("INDEX VALUE :: $index");
    //                           downloadSingleFrame(index, imageNames);
    //                           Navigator.pop(context);
    //                           // Navigator.pop(context);
    //                         },
    //                         child: Container(
    //                           decoration: BoxDecoration(
    //                               color: Colors.blue,
    //                               borderRadius: BorderRadius.circular(6)),
    //                           width: MediaQuery.of(context).size.width * .39,
    //                           height:
    //                           MediaQuery.of(context).size.height * .21,
    //                           child: Column(
    //                             mainAxisAlignment: MainAxisAlignment.center,
    //                             children: <Widget>[
    //                               Container(
    //                                 width: MediaQuery.of(context).size.width *
    //                                     .85,
    //                                 child: const Icon(
    //                                   Icons.download,
    //                                   color: Colors.white,
    //                                   size: 110,
    //                                 ),
    //                               ),
    //                               const SizedBox(
    //                                 height: 10,
    //                               ),
    //                               const Flexible(
    //                                 child: Text(
    //                                   "Download Frame",
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.bold,
    //                                       color: Colors.white,
    //                                       fontSize: 18),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           );
    //         }));
    //       });
    //
    // }
  }



  void downloadSingleFrame(int index, dynamic imageNames) async {

    String namePrefixFrames =
        widget.bannerModel.cloudReferenceName + "%2F" + "frames";
    String namePrefixPreview =
        widget.bannerModel.cloudReferenceName + "%2F" + "preview";
    String namePrefixWhiteBackground =
        widget.bannerModel.cloudReferenceName + "%2F" + "whiteBackground";

    setState(() {
      isDownloading[index] = true;
    });
    final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/$namePrefix%2F${imageNames}');
    final filePreview =
    File('${dir.path}/$namePrefixPreview%2F${imageNames}');
    final fileFrame = File('${dir.path}/$namePrefixFrames%2F${imageNames}');
    final fileWhiteBackground =
    File('${dir.path}/$namePrefixWhiteBackground%2F${imageNames}');

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

    framesDetails.removeAt(index);
    framesDetails.insert(
        index,
        ImgDetails(
            path: filePreview.path,
            category: "local",
            frameName: imageNames));

    setState(() {
      isDownloading[index] = false;
    });


  }
}



class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;
  void initialise() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    _checkStatus(result);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      // print(result);
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}
