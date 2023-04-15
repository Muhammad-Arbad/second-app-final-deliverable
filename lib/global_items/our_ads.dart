import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame_second/ad_mobs_service/ad_mob_service.dart';

class AdCreation {
  BannerAd createBannerAd() {
    return BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId.toString(),
        listener: AdMobService.bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  Container showBannerAd(BannerAd? bannerAd) {
    return bannerAd == null
        ? Container()
        : Container(
            decoration: BoxDecoration(
              border: Border.all(
                  width: 2,
                  color: bannerAd != null ? Colors.black : Colors.transparent),
            ),
            //margin: const EdgeInsets.only(bottom: 12),
            height: 60,
            child: Stack(
              children: [
                const Center(
                  child: Text("Ad Loading..."),
                ),
                AdWidget(ad: bannerAd!),
              ],
            ),
          );
  }

  NativeAd loadNativeAd(NativeAd? nativeAd) {
    return NativeAd(
      adUnitId: AdMobService.nativeAdUnitId,
      // factory Id: "listTile",
      factoryId: "listTileMedium",
      listener: NativeAdListener(onAdLoaded: (ad) {
        // setState(() {
        //   isNativeAdLoaded = true;
        // });
      }, onAdFailedToLoad: (ad, error) {
        // loadNativeAd2();
        nativeAd!.dispose();
      }),
      request: AdRequest(),
    );
    // nativeAd!.load();
  }

  Widget showNativeAd(NativeAd? nativeAd) {
    return nativeAd != null
        // isNativeAdLoaded
        ? Container(
            padding: EdgeInsets.all(10),
            height: 300,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              boxShadow: kElevationToShadow[4],
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                // Center(child: Text("Ad Loading..."),),
                AdWidget(
                  ad: nativeAd,
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
