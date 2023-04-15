


import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame_second/global_items/our_ads.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/views/bg_change_items_grid.dart';
import 'package:photo_frame_second/views/items_grid_view.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';


class SingleCategoryGreetings extends StatelessWidget {
  BannerModel bannerModel;
  SingleCategoryGreetings({Key? key,required this.bannerModel}) : super(key: key);
  BannerAd? bannerAd = AdCreation().createBannerAd();

  @override
  Widget build(BuildContext context) {
    return OurScaffold(
        appBarTitle: bannerModel.bannerName,
        scaffoldBody: BgChangeItemsGridView(
          bannerModel: bannerModel,
        ),
      bottomSheet: AdCreation().showBannerAd(bannerAd),
    );
  }
}
