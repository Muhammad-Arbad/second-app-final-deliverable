import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame_second/views/frame_categories.dart';
import 'package:photo_frame_second/views/free_hand_cropper.dart';
import 'package:photo_frame_second/views/greeting_categories.dart';
import 'package:photo_frame_second/views/home_page.dart';
import 'package:photo_frame_second/views/items_grid_view.dart';
import 'package:photo_frame_second/views/cropingTesting.dart';
import 'package:photo_frame_second/views/native_ads_screen.dart';
import 'package:photo_frame_second/views/pip_photo_page.dart';
import 'package:photo_frame_second/views/splash_screen.dart';
import 'package:photo_frame_second/views/test.dart';
import 'package:photo_frame_second/views/wallpapers_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  initializeFirabseStorage();

  runApp(const MyApp());
}

void initializeFirabseStorage() async {
  await Firebase.initializeApp();
  // WidgetsFlutterBinding.ensureInitialized();
// WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "12",
      ),
      routes: {
        // '/': (context) => NativeAds(),
        // '/': (context) => NativeTemplateExample(),
        '/': (context) => SplashScreen(),
        // '/': (context) => PipPhotoFrame(),
        // '/': (context) => Mag(),
        // '/': (context) => HomePage(),
        // '/': (context) => FreeHandCropper(),
        // FramesCategories.routeName : (context)=> FramesCategories(),
        // SingleCategoryFrames.routeName : (context)=> SingleCategoryFrames(),
        // SingleCategoryFrames.routeName : (context) =>SingleCategoryFrames(),
        GreetingCategories.routeName: (context) => GreetingCategories(),
        WallpapersPage.routeName: (context) => WallpapersPage(),
        // ImageCropping.routeName : (context) =>ImageCropping(),
      },
    );
  }
}
//All Rights Reserved 2023
//Code Highly Confidential
