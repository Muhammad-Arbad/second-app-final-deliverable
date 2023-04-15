import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame_second/global_items/our_ads.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/views/live_wallpapers_page.dart';
import 'package:photo_frame_second/views/static_wallpapers_page.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'package:video_player/video_player.dart';

class WallpaperTypes extends StatefulWidget {
  const WallpaperTypes({Key? key}) : super(key: key);

  @override
  State<WallpaperTypes> createState() => _WallpaperTypesState();
}

class _WallpaperTypesState extends State<WallpaperTypes> {
  late VideoPlayerController videoPlayerController;
  BannerAd? bannerAd;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bannerAd = AdCreation().createBannerAd();
    videoPlayerController = VideoPlayerController.asset(
        "assets/categories/wallpapers/wallpaperVideos/wal.mp4")
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) => videoPlayerController.play());
    // ..initialize().then((_) => videoPlayerController.play());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    videoPlayerController.dispose();
    bannerAd?.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return OurScaffold(
      appBarTitle: "Select Wallpaper",
      scaffoldBody: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AdCreation().showBannerAd(bannerAd),
          const SizedBox(height: 20,),
          const Text("Set amazing wallpapers",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20,),
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              boxShadow: kElevationToShadow[4],
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: InkWell(
              onTap: () {


                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveWallpapersPage(
                      bannerModel: BannerModel(
                          cloudReferenceName: "wallpapers",
                          assetsCompletePath: "assets/categories/wallpapers",
                          bannerImagePath: "",
                          iconPath: "assets/categories/icons/livewallpaper.png",
                          bannerDescription: "",
                          frameLocationName: "wallpaperVideos",
                          bannerName: "Wallpapers"),
                    ),
                  ),
                );

              },
              highlightColor: Colors.yellow.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    child: videoPlayerController != null &&
                            videoPlayerController.value.isInitialized
                        ? SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.width * 0.4,
                            child: FittedBox(
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              child: SizedBox(
                                height: videoPlayerController.value.size.height,
                                width: videoPlayerController.value.size.width,
                                child: VideoPlayer(
                                  videoPlayerController,
                                ),
                              ),
                            ),
                          )
                        : Image.asset('assets/photo_collage.jpg',
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
                                children: const [
                                  Text(
                                    "Set Live Wallpapers",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: ImageIcon(
                                AssetImage('assets/categories/icons/livewallpaper.png'),
                                color: Colors.orange,
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
          ),
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              boxShadow: kElevationToShadow[4],
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: InkWell(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=>WallpapersPage()));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaticWallpaperPage(
                      bannerModel: BannerModel(
                          cloudReferenceName: "wallpapers",
                          assetsCompletePath: "assets/categories/wallpapers",
                          bannerImagePath: "",
                          bannerDescription: "",
                          iconPath: "assets/categories/icons/wallpaper.png",
                          frameLocationName: "wallpaperImages",
                          bannerName: "Wallpapers"),
                    ),
                  ),
                );
              },
              highlightColor: Colors.yellow.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    child: Image.asset("assets/categories/bannerImages/wallpaper.jpg",
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
                                children: const [
                                  Text(
                                    "Set Static Wallpapers",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: ImageIcon(
                                AssetImage('assets/categories/icons/wallpaper.png'),
                                color: Colors.orange,
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
          ),


        ],
      ),
      bottomSheet: AdCreation().showBannerAd(bannerAd),
    );
  }
}
