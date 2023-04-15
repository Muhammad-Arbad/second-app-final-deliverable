import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame_second/ad_mobs_service/open_app_adService.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // late final bgImage;
  // late AppLifecycleReactor _appLifecycleReactor;
  AppOpenAd? _appOpenAd;

  @override
  void initState() {
    // TODO: implement initState
    // AppOpenAdManager().loadAd();

    super.initState();
    // bgImage = AssetImage("assets/background/bgg3.jpg");
    _appOpenAd = AppOpenAdManager(context).loadAd();

    goToHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return



      Scaffold(
      backgroundColor: Colors.grey,
      body: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(""),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                        image: AssetImage('assets/logo/logo.png')),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Text(
                  "Imikimi Photo Frames and Wallpapers",
                  style: TextStyle(color: Colors.black),
                )
              ],
            ),
          )),
    );
  }

  void goToHomeScreen() async {
    // await Future.delayed(Duration(milliseconds: 1000));
    // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>HomePage()));
  }
}
