import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame_second/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame_second/global_items/our_ads.dart';
import 'package:photo_frame_second/global_items/global_items.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/views/single_category_frames.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';

class FramesCategories extends StatefulWidget {
  static const routeName = "/frameCategoriesPage";

  FramesCategories({Key? key}) : super(key: key);

  // NativeAd? nativeAd;
  @override
  State<FramesCategories> createState() => _FramesCategoriesState();
}

class _FramesCategoriesState extends State<FramesCategories> {
  final scrollController = ScrollController(initialScrollOffset: 0);

  List<NativeAd?> nativeAdList = [];
  List<bool> isAdLoadedList = [];

  double childAspectRatio = 1.5;
  bool isAdLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
    print("INSIDE FRAME CATEGORIES");
    super.initState();

    for (int i = 0; i < GlobalItems().framesBannerList.length; i++) {
      isAdLoadedList.add(false);
    }
  }

  NativeAd loadNativeAd(NativeAd? nativeAd, loading) {
    return NativeAd(
      adUnitId: AdMobService.nativeAdUnitId,
      // factory Id: "listTile",
      factoryId: "listTileMedium",
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          loading = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        // loadNativeAd2();
        nativeAd!.dispose();
      }),
      request: AdRequest(),
    );
    // nativeAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    return OurScaffold(
      appBarTitle: "Frame Categories",
      scaffoldBody: SingleChildScrollView(
        child: Column(
          children: [
            // isAdLoaded? AdCreation().showNativeAd(nativeAd1):CircularProgressIndicator(),
            ListView.builder(
              itemCount: GlobalItems().framesBannerList.length,
              itemBuilder: ((context, index) {
                return singleFrameCategory(
                    GlobalItems().framesBannerList[index], context, index);
              }),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              controller: scrollController,
              scrollDirection: Axis.vertical,

            ),
            // AdCreation().showNativeAd(nativeAd2),
          ],
        ),
      ),
    );
  }

  Widget singleFrameCategory(
      BannerModel bannerModel, BuildContext context, int index) {
    // isAdLoadedList[index] = false;
    NativeAd? nativeAd;
    // nativeAdList.add(loadNativeAd(nativeAd,isAdLoadedList[index]));

    nativeAdList.add(NativeAd(
      adUnitId: AdMobService.nativeAdUnitId,
      // factory Id: "listTile",
      factoryId: "listTileMedium",
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          isAdLoadedList[index] = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        // loadNativeAd2();
        nativeAd!.dispose();
      }),
      request: AdRequest(),
    ));

    nativeAdList[index]!.load();

    return Column(
      children: [
        index % 2 == 0 && index != 0
            ? isAdLoadedList[index]!
                ? AdCreation().showNativeAd(nativeAdList[index])
                : Container(
                    padding: EdgeInsets.all(8),
                    child: Text("Ad Loading..."),
                  )
            : IgnorePointer(),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[4],
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: InkWell(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleCategoryFrames(
              // bannerModel: bannerModel,)));

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SingleCategoryFrames(
                            bannerModel: bannerModel,
                          )));
              // Navigator.pushNamed(context, SingleCategoryFrames.routeName);
              // Navigator.pushNamed(context, SingleCategoryFrames.routeName);
            },
            highlightColor: Colors.yellow.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  child: Image.asset(bannerModel.bannerImagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 0.4),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bannerModel.bannerName,
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(bannerModel.bannerDescription)
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ImageIcon(
                              AssetImage(bannerModel.iconPath),
                              color: Colors.red,
                              size: 35,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
