import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_frame_second/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/models/image_detail_model.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'package:video_player/video_player.dart';

class LiveWallpapersPage extends StatefulWidget {
  BannerModel bannerModel;

  LiveWallpapersPage({Key? key, required this.bannerModel}) : super(key: key);

  @override
  State<LiveWallpapersPage> createState() => _LiveWallpapersPageState();
}

class _LiveWallpapersPageState extends State<LiveWallpapersPage> {

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  final scrollController = ScrollController(initialScrollOffset: 0);
  late Future<ListResult> listOfStaticWallpapersFromClod;
  List<ImgDetails> staticWallpapersDetails = [];
  Map<int, bool> isDownloading = {};
  int localStaticWallpaperCount = 0;
  late List<VideoPlayerController> videoPlayerController = [];

  // int nextVidControllerIndex = 0;
  late VideoPlayerController testVideoController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createRewardedAd();
    listOfStaticWallpapersFromClod = FirebaseStorage.instance
        .ref(
            '${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
        .list();
    loadStaticWallpapersFromAssets();
  }

  void _createRewardedAd() {
    RewardedAd.load(
      // adUnitId: AdMobService.rewardedAdUnitId,
        adUnitId: AdMobService.interstitialAdUnitId,

        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    videoPlayerController.forEach((element) {
      element.dispose();
    });
    super.dispose();
  }

  void loadStaticWallpapersFromAssets() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    log(json.decode(manifestContent).toString());
    final imagePaths = manifestMap.keys
        .where((String key) => key.contains(
            '${widget.bannerModel.assetsCompletePath}/${widget.bannerModel.frameLocationName}/'))
        .toList();

    for (int i = 0; i < imagePaths.length; i++) {
      print("Before Controller in");
      print("Image path = " + imagePaths[i]);

      testVideoController = VideoPlayerController.asset(imagePaths[i])
        ..addListener(() => setState(() {}))
        // ..setLooping(true)
        ..initialize().then((_) => testVideoController.pause());

      videoPlayerController.add(testVideoController);

      // nextVidControllerIndex++;

      print("After Controller in");
      staticWallpapersDetails.add(ImgDetails(
          path: imagePaths[i],
          category: 'assets',
          frameName: imagePaths[i].split(Platform.pathSeparator).last));
    }

    // setState(() {});
    loadStaticWallpapersFromLocal();
  }

  void loadStaticWallpapersFromLocal() async {
    String namePrefix = widget.bannerModel.cloudReferenceName +
        "%2F" +
        widget.bannerModel.frameLocationName;
    final String dir = (await getApplicationDocumentsDirectory()).path;
    io.Directory("$dir").listSync().forEach((element) {
      if (element.path.contains(namePrefix)) {
        testVideoController = VideoPlayerController.file(File(element.path))
          ..addListener(() => setState(() {}))
          // ..setLooping(true)
          ..initialize().then((_) => testVideoController.pause());

        videoPlayerController.add(testVideoController);
        // nextVidControllerIndex++;

        print("foreash");
        print(element.path);
        staticWallpapersDetails.add(ImgDetails(
            path: element.path,
            category: 'local',
            frameName: element.path.split(Platform.pathSeparator).last));
      }
      ;
    });

    // setState(() {});

    loadStaticWallpapersFromCloud();
  }

  void loadStaticWallpapersFromCloud() async {
    print("Cloud reference name = " + widget.bannerModel.cloudReferenceName);
    print("Frame location name = " + widget.bannerModel.frameLocationName);
    localStaticWallpaperCount = staticWallpapersDetails.length;

    final _firestorage = FirebaseStorage.instance;
    final refs = await _firestorage
        .ref(
            '${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
        .list();

    for (Reference ref in refs.items) {
      String url = await ref.getDownloadURL();
      bool isFrameFoundLocally = false;

      print(url);

      for (int i = 0; i < localStaticWallpaperCount; i++) {
        if (url.contains(staticWallpapersDetails[i].frameName)) {
          isFrameFoundLocally = true;
        }
      }

      if (isFrameFoundLocally == false) {
        testVideoController = VideoPlayerController.network(url)
          ..addListener(() => setState(() {}))
          // ..setLooping(true)
          ..initialize().then((_) => testVideoController.pause());

        videoPlayerController.add(testVideoController);
        // nextVidControllerIndex++;

        staticWallpapersDetails
            .add(ImgDetails(path: url, category: 'cloud', frameName: ref.name));
        setState(() {});
      }
    }
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return OurScaffold(
        appBarTitle: widget.bannerModel.bannerName,
        scaffoldBody: StaggeredGridView.countBuilder(
          staggeredTileBuilder: (index) =>
              StaggeredTile.count(1, index.isEven ? 1.5 : 1),
          controller: scrollController,
          scrollDirection: Axis.vertical,
          crossAxisCount: 2,
          itemCount: staticWallpapersDetails.length,
          itemBuilder: (context, index) =>
              singleCategory(context, staticWallpapersDetails[index], index),
        )
        // GridView.count(
        //   controller: scrollController,
        //   scrollDirection: Axis.vertical,
        //   crossAxisCount: 2,
        //   mainAxisSpacing: 10,
        //   childAspectRatio: 1,
        //   children: List.generate(
        //     framesDetails.length,
        //         (index) => singleCategory(context, framesDetails[index], index),
        //   ),
        //   ),
        );
  }

  singleCategory(
      BuildContext context, ImgDetails liveWallpaperDetail, int index) {
    if (isDownloading[index] == null) {
      isDownloading[index] = false;
    }

    // print("in build method = "+isDownloading[index].toString());
    return isDownloading[index]!
        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
        : Container(
            padding: EdgeInsets.all(5),
            child: liveWallpaperDetail.category != 'cloud'
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
                    onTapDown: (tapDownDetail) {
                      videoPlayerController[index].play();
                    },
                    onTapUp: (tapDownDetail) {
                      videoPlayerController[index].pause();
                    },
                    onTap: () async{


                      String path = liveWallpaperDetail.path;

                      if(liveWallpaperDetail.category == 'assets'){
                        final byteData = await rootBundle.load(liveWallpaperDetail.path);
                        final file = File('${(await getTemporaryDirectory()).path}/${liveWallpaperDetail.frameName}');
                        await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
                        path = file.path;
                      }


                      log(liveWallpaperDetail.frameName);
                      log(liveWallpaperDetail.category);
                      log(path);

                      setLiveWallpaper(path);

                    },
                    child: isDownloading[index]!
                        ? const CircularProgressIndicator(color: Colors.orange)
                        : Ink(


                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(6.0)),
                              child: videoPlayerController != null &&
                                      videoPlayerController[index]
                                          .value
                                          .isInitialized
                                  ? SizedBox(
                                      width: double.infinity,
                                      // height:
                                      //     MediaQuery.of(context).size.width *
                                      //         0.4,
                                      child: FittedBox(
                                        alignment: Alignment.center,
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          height: videoPlayerController[index]
                                              .value
                                              .size
                                              .height,
                                          width: videoPlayerController[index]
                                              .value
                                              .size
                                              .width,
                                          child: VideoPlayer(
                                            videoPlayerController[index],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Stack(
                                children: [

                                  Image.asset(
                                    'assets/loading.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    // height:
                                    //     MediaQuery.of(context).size.width * 0.4
                                  ),
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
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
                        downloadFrame(liveWallpaperDetail.frameName, index);
                      },
                      onTapDown: (tapDownDetail) {
                        videoPlayerController[index].play();
                      },
                      onTapUp: (tapDownDetail) {
                        videoPlayerController[index].pause();
                      },

                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        child: videoPlayerController != null &&
                                videoPlayerController[index].value.isInitialized
                            ? SizedBox(
                                width: double.infinity,
                                // height: MediaQuery.of(context).size.width * 0.4,

                                child: FittedBox(
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    height: videoPlayerController[index]
                                        .value
                                        .size
                                        .height,
                                    width: videoPlayerController[index]
                                        .value
                                        .size
                                        .width,
                                    child: VideoPlayer(
                                      videoPlayerController[index],
                                    ),
                                  ),
                                ),
                              )
                            : Stack(
                                children: [

                                  Image.asset(
                                    'assets/loading.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    // height:
                                    //     MediaQuery.of(context).size.width * 0.4
                                  ),
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                      ),


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
  void _showRewardedAd() {
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
        _createRewardedAd();
        log("2");
      },

      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
        log("3");
      },

    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
        });
    _rewardedAd = null;
  }
  Future downloadFrame(imageNames, int index) async {


    if(index%2==1){
      _showRewardedAd();

      print(widget.bannerModel.frameLocationName);
      print(widget.bannerModel.cloudReferenceName);
      String namePrefix = widget.bannerModel.cloudReferenceName +
          "%2F" +
          widget.bannerModel.frameLocationName;
      print("Location prefix name = " + namePrefix);
      setState(() {
        isDownloading[index] = true;
      });
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$namePrefix%2F${imageNames}');

      await FirebaseStorage.instance
          .ref(
          '${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
          .child(imageNames)
          .writeToFile(file);

      staticWallpapersDetails.removeAt(index);
      staticWallpapersDetails.insert(index,
          ImgDetails(path: file.path, category: "local", frameName: imageNames));

      setState(() {
        isDownloading[index] = false;
      });

    }

    else{
      print(widget.bannerModel.frameLocationName);
      print(widget.bannerModel.cloudReferenceName);
      String namePrefix = widget.bannerModel.cloudReferenceName +
          "%2F" +
          widget.bannerModel.frameLocationName;
      print("Location prefix name = " + namePrefix);
      setState(() {
        isDownloading[index] = true;
      });
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$namePrefix%2F${imageNames}');

      await FirebaseStorage.instance
          .ref(
          '${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
          .child(imageNames)
          .writeToFile(file);

      staticWallpapersDetails.removeAt(index);
      staticWallpapersDetails.insert(index,
          ImgDetails(path: file.path, category: "local", frameName: imageNames));

      setState(() {
        isDownloading[index] = false;
      });
    }

  }


  setLiveWallpaper(String path)async{
    String result;
    try {
      result = await AsyncWallpaper.setLiveWallpaper(
        // filePath: '/data/user/0/com.example.photo_frame_second/app_flutter/wal.mp4',
        filePath: path,
        goToHome: true,
      )
          ? 'Wallpaper set'
          : 'Failed to get wallpaper.';
    } on PlatformException {
      result = 'Failed to get wallpaper.';
    }
    print("Result = "+result);
  }


}
