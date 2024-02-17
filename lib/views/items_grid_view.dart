import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_frame_second/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/models/image_detail_model.dart';
import 'package:photo_frame_second/views/single_frame.dart';

class ItemsGridView extends StatefulWidget {
  BannerModel bannerModel;
  ItemsGridView({Key? key, required this.bannerModel}) : super(key: key);
  @override
  State<ItemsGridView> createState() => _ItemsGridViewState();
}

class _ItemsGridViewState extends State<ItemsGridView> {
  RewardedAd? rewardedAd;
  InterstitialAd? _interstitialAd;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  final scrollController = ScrollController(initialScrollOffset: 0);
  late Future<ListResult> listOfFramesFromClod;
  List<ImgDetails> framesDetails = [];
  Map<int, bool> isDownloading = {};
  int localFramesCount = 0;
  late bool isConnected;
  bool isInterstitialLoaded = false;
  bool isRewardedAdLoaded = false;
  InterstitialAd? interstitialAd;
  RewardedInterstitialAd? rewardedInterstitialAd;
  // Map _source = {ConnectivityResult.none: false};
  // final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;

  @override
  void initState() {
    // TODO: implement initState
    print("INSIDE LIST OF FRAMES");
    super.initState();
    // loadAds();
    _createInterstitialAd();
    _createRewardedAd();

    loadAd();
    listOfFramesFromClod = FirebaseStorage.instance
        .ref(
            '${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
        .list();

    loadFramesFromAssets();
  }

  Future<void> _createRewardedAd() async {
    print("CREATE REWARDED AD");
    RewardedAd.loadWithAdManagerAdRequest(
      adUnitId: AdMobService.rewardedAdUnitId,
      adManagerRequest: const AdManagerAdRequest(),
      // adManagerAdRequest: AdManagerAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('RewardedAd ad loaded');
          print('$ad loaded.');
          rewardedAd = ad;

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

  void loadAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            isInterstitialLoaded = true;
            _numRewardedLoadAttempts = 0;
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                  loadAd();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  // void _createInterstitialAd() {
  //   log("INSIDE CREATE REWARDED AD");
  //   InterstitialAd.load(
  //       adUnitId: AdMobService.interstitialAdUnitId,
  //       request: const AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //           onAdLoaded: (ad) {
  //             isInterstitialLoaded = true;
  //             print("Ad Loaded");
  //
  //             interstitialAd = ad;
  //           },
  //           onAdFailedToLoad: (LoadAdError error) => interstitialAd = null));
  // }

  void _createInterstitialAd() {
    RewardedAd.load(
        // adUnitId: AdMobService.rewardedAdUnitId,
        adUnitId: AdMobService.interstitialAdUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            rewardedAd = ad;
            isInterstitialLoaded = true;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
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

  void loadFramesFromAssets() async {
    // print('${widget.bannerModel.assetsCompletePath}/${widget.bannerModel.frameLocationName}/');
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // log(json.decode(manifestContent).toString());
    final imagePaths = manifestMap.keys
        .where((String key) => key.contains(
            '${widget.bannerModel.assetsCompletePath}/${widget.bannerModel.frameLocationName}/'))
        .toList();
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
    String namePrefix = widget.bannerModel.cloudReferenceName +
        "%2F" +
        widget.bannerModel.frameLocationName;
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
  }

  void loadFramesFromCloud() async {
    print("Cloud reference name = " + widget.bannerModel.cloudReferenceName);
    print("Frame location name = " + widget.bannerModel.frameLocationName);
    localFramesCount = framesDetails.length;

    final _firestorage = FirebaseStorage.instance;
    final refs = await _firestorage
        .ref(
            '${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
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
      childAspectRatio: 9 / 16,
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
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
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
                      // framesDetails = await

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SingleFrame(
                                    bannerModel: widget.bannerModel,
                                    imageDetal: frameDetail,
                                    framesDetails: framesDetails,
                                    frameCategoryName:
                                        widget.bannerModel.frameLocationName,
                                  ))).then((value) => {setState(() {})});
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

                      child: Container(
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
                            image: NetworkImage(frameDetail.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // child: Positioned.fill(child: Image.network(frameDetail.path, fit: BoxFit.cover,)),
                      // child: CachedNetworkImage(
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

  void downloadSingleFrame(int index, dynamic frameName) async {
    print("INDEX VALUE :: $index");
    String namePrefix = widget.bannerModel.cloudReferenceName +
        "%2F" +
        widget.bannerModel.frameLocationName;
    // print("Location prefix name = "+namePrefix);
    setState(() {
      isDownloading[index] = true;
      // isInterstitialLoaded = false;
    });
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$namePrefix%2F${frameName}');

    await FirebaseStorage.instance
        .ref(
            '${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
        .child(frameName)
        .writeToFile(file);

    framesDetails.removeAt(index);
    framesDetails.insert(index,
        ImgDetails(path: file.path, category: "local", frameName: frameName));
    isInterstitialLoaded = false;
    setState(() {
      isDownloading[index] = false;
    });
  }

  Future<bool> _showRewardedAd(Function() onUserEarned) async {
    log("INSIDE SHOW REWARDED AD FUNCTION");
    if (rewardedAd == null) {
      // print('Warning: attempt to show rewarded before loaded.');
      log("INSIDE IF");
      return false;
    }
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {},
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
        },
        onAdImpression: (RewardedAd ad) => {});

    rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onUserEarned();
      _createRewardedAd();
    });

    log("BEFORE RETURN");
    return true;
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
                              _interstitialAd!.show().then((value) {
                                downloadSingleFrame(index, imageNames);
                              });
                            } else {
                              if (rewardedAd != null) {
                                _showRewardedAd(() {
                                  downloadSingleFrame(index, imageNames);
                                });
                              } else {
                                downloadSingleFrame(index, imageNames);
                              }
                            }
                          },
                          child:
                              isInterstitialLoaded == true || rewardedAd != null
                                  ? Text(
                                      "Watch Ad",
                                    )
                                  : const Text(
                                      "Download Frame",
                                    ),

                          // Text("Watch Ad")
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });

      // if (isInterstitialLoaded == true) {
      //   showModalBottomSheet(
      //       context: context,
      //       builder: (context) {
      //         return StatefulBuilder(
      //             builder: ((BuildContext context, StateSetter setState) {
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
      //                               MediaQuery.of(context).size.height * .21,
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
      //                           if (isInterstitialLoaded == true) {
      //                             interstitialAd!.fullScreenContentCallback =
      //                                 FullScreenContentCallback(
      //                                     onAdShowedFullScreenContent:
      //                                         (InterstitialAd ad) => print(
      //                                             '%ad onAdShowedFullScreenContent.'),
      //                                     onAdDismissedFullScreenContent:
      //                                         (InterstitialAd ad) async {
      //                                       print('$ad Ad has been Dismissed');
      //                                       print("INDEX VALUE :: $index");
      //                                       downloadSingleFrame(
      //                                           index, imageNames);
      //                                       print(
      //                                           '$ad onAdDismissedFullScreenContent.');
      //                                       _createInterstitialAd();
      //                                       Navigator.pop(context);
      //
      //                                       ad.dispose();
      //                                     },
      //                                     onAdFailedToShowFullScreenContent:
      //                                         (InterstitialAd ad,
      //                                             AdError error) {
      //                                       print(
      //                                           '$ad onAdFailedToShowFullScreenContent: $error');
      //                                       ad.dispose();
      //                                     },
      //                                     onAdImpression: (InterstitialAd ad) {
      //                                       isInterstitialLoaded = false;
      //                                       _createInterstitialAd();
      //                                       Navigator.pop(context);
      //                                       setState(() {});
      //                                     });
      //
      //                             interstitialAd!.show();
      //                           } else {
      //                             downloadSingleFrame(index, imageNames);
      //                           }
      //
      //                           //Navigator.pop(context);
      //                         },
      //                         child: Container(
      //                           decoration: BoxDecoration(
      //                               color: Colors.blue,
      //                               borderRadius: BorderRadius.circular(6)),
      //                           width: MediaQuery.of(context).size.width * .39,
      //                           height:
      //                               MediaQuery.of(context).size.height * .21,
      //                           child: Column(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: <Widget>[
      //                               Container(
      //                                 width: MediaQuery.of(context).size.width *
      //                                     .85,
      //                                 child: Icon(
      //                                   isInterstitialLoaded == true
      //                                       ? FontAwesomeIcons.award
      //                                       : Icons.download,
      //                                   color: Colors.white,
      //                                   size: 110,
      //                                 ),
      //                               ),
      //                               const SizedBox(
      //                                 height: 10,
      //                               ),
      //                               Flexible(
      //                                 child: isInterstitialLoaded == true
      //                                     ? const Text(
      //                                         "Watch Ad",
      //                                         style: TextStyle(
      //                                             fontWeight: FontWeight.bold,
      //                                             color: Colors.white,
      //                                             fontSize: 18),
      //                                       )
      //                                     : const Text(
      //                                         "Download Frame",
      //                                         style: TextStyle(
      //                                             fontWeight: FontWeight.bold,
      //                                             color: Colors.white,
      //                                             fontSize: 18),
      //                                       ),
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
      //
      //
      // else {
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
      //                               MediaQuery.of(context).size.height * .21,
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
      //                               MediaQuery.of(context).size.height * .21,
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
      // }
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

      // downloadSingleFrame(index, imageNames);

      // showModalBottomSheet(
      //     context: context,
      //     builder: (context) {
      //       return StatefulBuilder(builder: ((context, setState) {
      //         return Container(
      //           height: 310,
      //           child: Container(
      //             padding: EdgeInsets.only(top: 20),
      //             width: MediaQuery.of(context).size.width * 0.90,
      //             child: Column(
      //               children: [
      //                 const Text(
      //                   "Choose Your Option",
      //                   style: TextStyle(
      //                       fontWeight: FontWeight.bold, fontSize: 24),
      //                 ),
      //                 const SizedBox(
      //                   height: 20,
      //                 ),
      //                 Row(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
      //                   children: [
      //                     InkWell(
      //                       onTap: () {
      //                         Navigator.pop(context);
      //                       },
      //                       child: Container(
      //                         decoration: BoxDecoration(
      //                             color: Colors.blue,
      //                             borderRadius: BorderRadius.circular(6)),
      //                         width: MediaQuery.of(context).size.width * .39,
      //                         height: MediaQuery.of(context).size.height * .21,
      //                         child: Column(
      //                           mainAxisAlignment: MainAxisAlignment.center,
      //                           children: <Widget>[
      //                             Container(
      //                               width:
      //                                   MediaQuery.of(context).size.width * .85,
      //                               child: const Icon(
      //                                 Icons.close,
      //                                 color: Colors.white,
      //                                 size: 110,
      //                               ),
      //                             ),
      //                             const Text(
      //                               "May be Later",
      //                               style: TextStyle(
      //                                   fontWeight: FontWeight.bold,
      //                                   color: Colors.white,
      //                                   fontSize: 18),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                     InkWell(
      //                       onTap: () async {
      //                         //Navigator.pop(context);
      //                         print("DOWNLOAD");
      //                         print("INDEX VALUE :: $index");
      //                         downloadSingleFrame(index, imageNames);
      //                         Navigator.pop(context);
      //                         // Navigator.pop(context);
      //                       },
      //                       child: Container(
      //                         decoration: BoxDecoration(
      //                             color: Colors.blue,
      //                             borderRadius: BorderRadius.circular(6)),
      //                         width: MediaQuery.of(context).size.width * .39,
      //                         height: MediaQuery.of(context).size.height * .21,
      //                         child: Column(
      //                           mainAxisAlignment: MainAxisAlignment.center,
      //                           children: <Widget>[
      //                             Container(
      //                               width:
      //                                   MediaQuery.of(context).size.width * .85,
      //                               child: const Icon(
      //                                 Icons.download,
      //                                 color: Colors.white,
      //                                 size: 110,
      //                               ),
      //                             ),
      //                             const SizedBox(
      //                               height: 10,
      //                             ),
      //                             const Flexible(
      //                               child: Text(
      //                                 "Download Frame",
      //                                 style: TextStyle(
      //                                     fontWeight: FontWeight.bold,
      //                                     color: Colors.white,
      //                                     fontSize: 18),
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         );
      //       }));
      //     });
    }
  }
}
