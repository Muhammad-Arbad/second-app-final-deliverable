import 'dart:convert';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_frame_second/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/models/image_detail_model.dart';
import 'package:photo_frame_second/views/single_static_wallpaper_view.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';

class StaticWallpaperPage extends StatefulWidget {

  BannerModel bannerModel;
  StaticWallpaperPage({Key? key, required this.bannerModel}) : super(key: key);

  @override
  State<StaticWallpaperPage> createState() => _StaticWallpaperPageState();
}

class _StaticWallpaperPageState extends State<StaticWallpaperPage> {


  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  final scrollController = ScrollController(initialScrollOffset: 0);
  late Future<ListResult> listOfStaticWallpapersFromClod;
  List<ImgDetails> staticWallpapersDetails = [];
  Map<int, bool> isDownloading = {};
  int localStaticWallpaperCount = 0;
  bool isInterstitialLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createRewardedAd();
    listOfStaticWallpapersFromClod = FirebaseStorage.instance
        .ref('${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
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
            isInterstitialLoaded = true;
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

  void loadStaticWallpapersFromAssets() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    log(json.decode(manifestContent).toString());
    final imagePaths = manifestMap.keys
        .where((String key) => key.contains(
        '${widget.bannerModel.assetsCompletePath}/${widget.bannerModel.frameLocationName}/'))
        .toList();
    for (int i = 0; i < imagePaths.length; i++) {
      staticWallpapersDetails.add(ImgDetails(
          path: imagePaths[i],
          category: 'assets',
          frameName: imagePaths[i].split(Platform.pathSeparator).last));
    }

    setState(() {});
    loadStaticWallpapersFromLocal();
  }

  void loadStaticWallpapersFromLocal() async {
    String namePrefix = widget.bannerModel.cloudReferenceName +"%2F"+ widget.bannerModel.frameLocationName;
    final String dir = (await getApplicationDocumentsDirectory()).path;
    io.Directory("$dir").listSync().forEach((element) {
      if (element.path.contains(namePrefix)) {
        print("foreash");
        print(element.path);
        staticWallpapersDetails.add(ImgDetails(
            path: element.path,
            category: 'local',
            frameName: element.path.split(Platform.pathSeparator).last));
      };
    });

    setState(() {});

    loadStaticWallpapersFromCloud();
  }

  void loadStaticWallpapersFromCloud() async {
    print("Cloud reference name = " +widget.bannerModel.cloudReferenceName);
    print("Frame location name = " +widget.bannerModel.frameLocationName);
    localStaticWallpaperCount = staticWallpapersDetails.length;

    final _firestorage = FirebaseStorage.instance;
    final refs = await _firestorage
        .ref('${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
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
        staticWallpapersDetails
            .add(ImgDetails(path: url, category: 'cloud', frameName: ref.name));
        setState(() {});
      }
    }
  }

  // @override
  @override
  Widget build(BuildContext context) {
    return
      OurScaffold(
      appBarTitle: widget.bannerModel.bannerName,
      scaffoldBody:
      StaggeredGridView.countBuilder(
        staggeredTileBuilder: (index)=>StaggeredTile.count(1,index.isEven?1.5:1),
        controller: scrollController,
        scrollDirection: Axis.vertical,
        crossAxisCount: 2,

        itemCount: staticWallpapersDetails.length,
        itemBuilder: (context,index)=>singleCategory(context, staticWallpapersDetails[index], index),
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

  singleCategory(BuildContext context, ImgDetails staticWallpaperDetail, int index) {

    if(isDownloading[index] == null){
      isDownloading[index] = false;
    }

    // print("in build method = "+isDownloading[index].toString());
    return isDownloading[index]!? const Center(child: CircularProgressIndicator(color: Colors.orange)):Container(
      padding: EdgeInsets.all(5),
      child: staticWallpaperDetail.category != 'cloud'
          ? InkWell(
        borderRadius: BorderRadius.only(
          bottomLeft:
          index % 2 == 1 ? Radius.circular(6) : Radius.circular(6),
          bottomRight:
          index % 2 == 0 ? Radius.circular(6) : Radius.circular(6),
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        highlightColor: Colors.orangeAccent.withOpacity(0.3),
        splashColor: Colors.orangeAccent.withOpacity(0.3),
        onTap: () {

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SingleStaticWallpaperView(
                    wallpaperDetail: staticWallpaperDetail,
                  )));

          log(staticWallpaperDetail.frameName);
          log(staticWallpaperDetail.category);
          log(staticWallpaperDetail.path);

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
            image: staticWallpaperDetail.category == 'assets'
                ? DecorationImage(
              image: AssetImage(staticWallpaperDetail.path),
              fit: BoxFit.cover,
            )
                : DecorationImage(
              image: FileImage(File(staticWallpaperDetail.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
      )
          : Stack(children: [
        InkWell(
          borderRadius: BorderRadius.only(
            bottomLeft:
            index % 2 == 1 ? Radius.circular(6) : Radius.circular(6),
            bottomRight:
            index % 2 == 0 ? Radius.circular(6) : Radius.circular(6),
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          highlightColor: Colors.orangeAccent.withOpacity(0.3),
          splashColor: Colors.orangeAccent.withOpacity(0.3),
          onTap: () {
            downloadFrame(staticWallpaperDetail.frameName, index);
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
                image:NetworkImage(staticWallpaperDetail.path),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // CachedNetworkImage(
          //   imageUrl: staticWallpaperDetail.path,
          //   progressIndicatorBuilder: (context, url, downloadProgress) =>
          //       Center(child: CircularProgressIndicator(color: Colors.orange,value: downloadProgress.progress)),
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
  // void _showRewardedAd() {
  //   if (_rewardedAd == null) {
  //     print('Warning: attempt to show rewarded before loaded.');
  //     return;
  //   }
  //   _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
  //
  //     onAdShowedFullScreenContent: (RewardedAd ad) {
  //       print('ad onAdShowedFullScreenContent.');
  //       log("1");
  //     },
  //
  //     onAdDismissedFullScreenContent: (RewardedAd ad) {
  //       print('$ad onAdDismissedFullScreenContent.');
  //       ad.dispose();
  //       _createRewardedAd();
  //       log("2");
  //     },
  //
  //     onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
  //       print('$ad onAdFailedToShowFullScreenContent: $error');
  //       ad.dispose();
  //       _createRewardedAd();
  //       log("3");
  //     },
  //
  //   );
  //
  //   _rewardedAd!.setImmersiveMode(true);
  //   _rewardedAd!.show(
  //       onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //         print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
  //       });
  //   _rewardedAd = null;
  // }

  Future<bool> _showRewardedAd() async {
    if (_rewardedAd == null) {
      // print('Warning: attempt to show rewarded before loaded.');
      return false;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {

        },
        onAdDismissedFullScreenContent: (RewardedAd ad) {

          ad.dispose();
          _createRewardedAd();

        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {

          ad.dispose();

        },
        onAdImpression: (RewardedAd ad) => {

        });


    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {

    });

    return true;
  }

  Future downloadFrame(imageNames, int index) async {

    if(index%2==1){

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 220,
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
                        "Would you like to unlock wallpaper ? ",
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


                            if(isInterstitialLoaded == true){
                              if (await _showRewardedAd()){
                                log("INSIDE IF CONDITION");
                                print(widget.bannerModel.frameLocationName);
                                print(widget.bannerModel.cloudReferenceName);
                                String namePrefix =  widget.bannerModel.cloudReferenceName+"%2F"+widget.bannerModel.frameLocationName;
                                print("Location prefix name = "+namePrefix);
                                setState(() {isDownloading[index] = true;});
                                final dir = await getApplicationDocumentsDirectory();
                                final file = File('${dir.path}/$namePrefix%2F${imageNames}');

                                await FirebaseStorage.instance
                                    .ref('${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
                                    .child(imageNames)
                                    .writeToFile(file);

                                staticWallpapersDetails.removeAt(index);
                                staticWallpapersDetails.insert(index,
                                    ImgDetails(path: file.path, category: "local", frameName: imageNames));
                                isInterstitialLoaded = false;
                                setState(() {isDownloading[index] = false;});
                              }
                            }
                            else{

                              log("INSIDE ELSE CONDITION");
                              String namePrefix =  widget.bannerModel.cloudReferenceName+"%2F"+widget.bannerModel.frameLocationName;
                              setState(() {isDownloading[index] = true;});
                              final dir = await getApplicationDocumentsDirectory();
                              final file = File('${dir.path}/$namePrefix%2F${imageNames}');
                              await FirebaseStorage.instance
                                  .ref('${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
                                  .child(imageNames)
                                  .writeToFile(file);
                              staticWallpapersDetails.removeAt(index);
                              staticWallpapersDetails.insert(index,
                                  ImgDetails(path: file.path, category: "local", frameName: imageNames));
                              setState(() {isDownloading[index] = false;});
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





    }
    else{

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 220,
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
                        "Would you like to Download wallpaper ? ",
                        style: TextStyle(fontSize: 18),
                        textAlign:  TextAlign.center,
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
                            print(widget.bannerModel.frameLocationName);
                            print(widget.bannerModel.cloudReferenceName);
                            String namePrefix =  widget.bannerModel.cloudReferenceName+"%2F"+widget.bannerModel.frameLocationName;
                            print("Location prefix name = "+namePrefix);
                            setState(() {isDownloading[index] = true;});
                            final dir = await getApplicationDocumentsDirectory();
                            final file = File('${dir.path}/$namePrefix%2F${imageNames}');

                            await FirebaseStorage.instance
                                .ref('${widget.bannerModel.cloudReferenceName}/${widget.bannerModel.frameLocationName}')
                                .child(imageNames)
                                .writeToFile(file);

                            staticWallpapersDetails.removeAt(index);
                            staticWallpapersDetails.insert(index,
                                ImgDetails(path: file.path, category: "local", frameName: imageNames));

                            setState(() {isDownloading[index] = false;});

                          },
                          child: Text(
                            "Download",),

                          // Text("Watch Ad")

                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });



    }



  }
}
