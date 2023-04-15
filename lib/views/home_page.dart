import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_frame_second/global_items/our_ads.dart';
import 'package:photo_frame_second/global_items/global_items.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/views/frame_categories.dart';
import 'package:photo_frame_second/views/greeting_categories.dart';
import 'package:photo_frame_second/views/my_stuff.dart';
import 'package:photo_frame_second/views/select_wallpaper_type.dart';
import 'package:photo_frame_second/views/single_category_frames.dart';
import 'package:photo_frame_second/views/single_greeting_category.dart';
import 'package:photo_frame_second/widgets/icon_with_name.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? selectedImage;
  // RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  // int _numRewardedLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  // final nativeAdController = NativeAdmobController();
  NativeAd? nativeAd, nativeAd1;
  // bool isNativeAdLoaded = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    nativeAd = AdCreation().loadNativeAd(nativeAd);
    nativeAd!.load();
    nativeAd1 = AdCreation().loadNativeAd(nativeAd1);
    nativeAd1!.load();
  }


  @override
  Widget build(BuildContext context) {
    return OurScaffold(
        customDrawer: customDrawer(),
        appBarTitle: "",
        // appBar: AppBar(
        //   title: Text(""),
        // ),
        scaffoldBody: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Imikimi Frames and Effects",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  // ElevatedButton(
                  //     onPressed: () {
                  //       showModal(context);
                  //       print("Show BottomSheet");
                  //     },
                  //     child: Text("Show BottomSheet")),
                  Expanded(
                    child: iconNameBlock(
                        rightBottom: true,
                        icon: const Icon(Icons.image_outlined, size: 30),
                        nameOfIcon: "Frames",
                        bgColor: Colors.blue.shade100,
                        inkwellOnTap: () {
                          // Navigator.pushNamed(
                          //     context, FramesCategories.routeName);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FramesCategories()));
                        }),
                  ),
                  Expanded(
                    child: iconNameBlock(
                        leftBottom: true,
                        icon: const Icon(
                          Icons.card_giftcard,
                          size: 30,
                        ),
                        nameOfIcon: "Greetings",
                        bgColor: Colors.amber.shade200,
                        inkwellOnTap: () {
                          Navigator.pushNamed(
                              context, GreetingCategories.routeName);
                        }),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: iconNameBlock(
                        rightTop: true,
                        icon: const Icon(Icons.wallpaper, size: 30),
                        nameOfIcon: "Wallpapers",
                        bgColor: Colors.indigo.shade100,
                        inkwellOnTap: () {
                          // Navigator.pushNamed(
                          //     context, WallpapersPage.routeName);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WallpaperTypes()));
                        }),
                  ),
                  Expanded(
                    child: iconNameBlock(
                        leftTop: true,
                        icon: const Icon(Icons.work_outline_rounded, size: 30),
                        nameOfIcon: "Creations",
                        bgColor: Colors.red.shade100,
                        inkwellOnTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyStuff()));


                        }),
                  ),

                ],
              ),
              const SizedBox(
                height: 20,
              ),

              const Text("Background Effects",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // controller: scrollController,
                scrollDirection: Axis.vertical,
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
                children: List.generate(
                  GlobalItems().homePageBannerList.length,
                  (index) => homePageBanner(
                      context, GlobalItems().homePageBannerList[index], () {

                    if (GlobalItems().homePageBannerList[index].bannerName ==
                        "Background Change") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SingleCategoryGreetings(
                                bannerModel:
                                GlobalItems().homePageBannerList[index],
                              )));
                    }

                    if (GlobalItems().homePageBannerList[index].bannerName ==
                        "Echo photos") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SingleCategoryGreetings(
                                    bannerModel:
                                        GlobalItems().homePageBannerList[index],
                                  )));
                    }

                    if (GlobalItems().homePageBannerList[index].bannerName ==
                        "Frame Collage") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SingleCategoryFrames(
                                    bannerModel:
                                        GlobalItems().homePageBannerList[index],
                                  )));
                    }

                    if (GlobalItems().homePageBannerList[index].bannerName ==
                        "Pip Photo") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SingleCategoryFrames(
                                    bannerModel:
                                        GlobalItems().homePageBannerList[index],
                                  )));
                    }
                  }),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              AdCreation().showNativeAd(nativeAd),


              const SizedBox(
                height: 20,
              ),

              const Text("More Frames",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                // controller: scrollController,
                scrollDirection: Axis.vertical,
                crossAxisCount: 1,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
                children: List.generate(
                  GlobalItems().homeScreenFrames.length,
                  (index) => homePageBanner(
                      context, GlobalItems().homeScreenFrames[index], () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SingleCategoryFrames(
                                  bannerModel:
                                      GlobalItems().homeScreenFrames[index],
                                )));
                  }),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              AdCreation().showNativeAd(nativeAd1),
            ],
          ),
        ));
  }



  Container customDrawer() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              image: const DecorationImage(
                  image: AssetImage('assets/logo/logo.png')),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Frames and Wallpapers",
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(
            height: 40,
          ),
          icon_text_row(
              btnText: "Home",
              icon: Icons.home_outlined,
              btnPress: () {
                Navigator.pop(context);
              }),
          icon_text_row(
              btnText: "Frames",
              icon: Icons.image_outlined,
              btnPress: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FramesCategories()));
              }),
          icon_text_row(
              btnText: "Greeting",
              icon: Icons.card_giftcard,
              btnPress: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, GreetingCategories.routeName);
              }),
          icon_text_row(
              btnText: "Wallpaper",
              icon: Icons.wallpaper,
              btnPress: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WallpaperTypes()));
              }),
          icon_text_row(
              btnText: "Creations",
              icon: Icons.work_outline_rounded,
              btnPress: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyStuff()));
              }),
        ],
      ),
    );
  }

  Container homePageBanner(
      BuildContext context, BannerModel bannerModel, Function() onTap) {
    return Container(
      margin: EdgeInsets.all(10),
      //padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[4],
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6.0)),
              child: Image.asset(bannerModel.bannerImagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.5),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
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
                          )),
                      Expanded(
                        flex: 1,
                        child: ImageIcon(
                          AssetImage(bannerModel.iconPath),
                          color: Colors.red,
                          size: 35,
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class icon_text_row extends StatelessWidget {
  String btnText;
  IconData icon;
  Function() btnPress;
  icon_text_row(
      {Key? key,
      required this.icon,
      required this.btnText,
      required this.btnPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        TextButton(
          onPressed: btnPress,
          child: Row(
            children: [
              Icon(icon, size: 30),
              const SizedBox(
                width: 10,
              ),
              Text(btnText, style: TextStyle(fontSize: 18)),
            ],
          ),
        ),

        // SizedBox(height: 10,),
        const Divider(
          height: 2,
          color: Colors.deepOrange,
        ),
      ],
    );
  }
}
