import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame_second/views/home_page.dart';

class AppOpenAdManager {
  BuildContext context;

  AppOpenAdManager(this.context);

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  static String get openAppAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3398262524144530/6358812600';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  /// Load an AppOpenAd.
  AppOpenAd? loadAd() {
    AppOpenAd.load(
      adUnitId: openAppAdUnitId,
      request: AdRequest(),
      orientation: AppOpenAd.orientationPortrait,
      adLoadCallback: AppOpenAdLoadCallback(onAdLoaded: (ad) {
        //  _appOpenLoadTime = DateTime.now();
        _appOpenAd = ad;
        print("Ad Loaded $_appOpenAd");
        _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
          // onAdShowedFullScreenContent: (ad) {
          //   _isShowingAd = true;
          //   print("$ad onAdShowedFullScreenContent");
          // },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print("$ad onAdFailedToShowFullScreenContent : $error");
            _isShowingAd = false;
            ad.dispose();
            _appOpenAd = null;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()));
          },
          onAdDismissedFullScreenContent: (ad) async {
            print('$ad onAdDismissedFullScreenContent');
            _isShowingAd = false;
            ad.dispose();
            _appOpenAd = null;
            // await Future.delayed(Duration(milliseconds: 1500));
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()));

            // loadAd();
          },
        );
        _appOpenAd!.show();
        _appOpenAd = null;
      }, onAdFailedToLoad: (error) async {
        await Future.delayed(Duration(milliseconds: 1000));

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomePage()));
        print("AppOpeAd Failed to Load : $error");
      }),
    );
    return _appOpenAd;

    // We will implement this below.
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      print("Tried to show ad when not available.");
      loadAd();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    // if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
    //   print('Maximum cache duration exceeded. Loading another ad.');
    //   _appOpenAd!.dispose();
    //   _appOpenAd = null;
    //   loadAd();
    //   return;
    // }
    // Set the fullScreenContentCallback and show the ad.
  }
}

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    if (appState == AppState.foreground) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}
