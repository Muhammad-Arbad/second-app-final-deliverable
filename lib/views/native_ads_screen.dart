
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'constants.dart';

/// This example demonstrates native templates.
class NativeTemplateExample extends StatefulWidget {
  @override
  _NativeTemplateExampleExampleState createState() =>
      _NativeTemplateExampleExampleState();
}

class _NativeTemplateExampleExampleState extends State<NativeTemplateExample> {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('Native templates example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.separated(
            itemCount: 10,
            separatorBuilder: (BuildContext context, int index) {
              return Container(
                height: 40,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              if (index == 5 && _nativeAd != null && _nativeAdIsLoaded) {
                return Container(
                    width: 250, height: 600, child: AdWidget(ad: _nativeAd!));
              }
              return const Text(
                // Constants.placeholderText,
                "Ad Loading",
                style: TextStyle(fontSize: 24),
              );
            },
          ),
        ),
      ));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Create the ad objects and load ads.
    _nativeAd = NativeAd(
      adUnitId:
      // '/6499/example/native',
      Platform.isAndroid
          ? 'ca-app-pub-3398262524144530/1535055249'
          : 'ca-app-pub-3398262524144530/1535055249',
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('$NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
      ),

      factoryId: '',
    )..load();
  }

  @override
  void dispose() {
    super.dispose();
    _nativeAd?.dispose();
  }
}

