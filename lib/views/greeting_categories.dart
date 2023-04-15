import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame_second/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame_second/global_items/global_items.dart';
import 'package:photo_frame_second/global_items/our_ads.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/views/single_greeting_category.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';

class GreetingCategories extends StatefulWidget {
  static const routeName = "/greetingCategoriesPage";

  const GreetingCategories({Key? key}) : super(key: key);

  @override
  State<GreetingCategories> createState() => _GreetingCategoriesState();
}

class _GreetingCategoriesState extends State<GreetingCategories> {
  final scrollController = ScrollController(initialScrollOffset: 0);

  List<NativeAd?> nativeAdList = [];
  List<bool> isAdLoadedList = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   

    for(int i=0;i<GlobalItems().greetingBannerList.length;i++){
      isAdLoadedList.add(false);

    }
  }

  @override
  Widget build(BuildContext context) {
    return OurScaffold(
      appBarTitle: "Greeting Categories",
      scaffoldBody: Container(
        child: ListView.builder(
          itemCount: GlobalItems().greetingBannerList.length,
          itemBuilder: ((context, index) {

            return singleGreetingCategory(GlobalItems().greetingBannerList[index], context,index);
          }),
          controller: scrollController,
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }

  Widget singleGreetingCategory(BannerModel bannerModel, BuildContext context,int index) {



    NativeAd? nativeAd;


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
      request:  AdRequest(),
    ));




    nativeAdList[index]!.load();

    return Column(
      children: [
        index % 2 == 0
            ? isAdLoadedList[index]!? AdCreation().showNativeAd(nativeAdList[index]):Container(padding:EdgeInsets.all(8), child: Text("Ad Loading..."),)
            : IgnorePointer(),

        Container(
          //height: MediaQuery.of(context).size.width*0.5,
          margin: EdgeInsets.all(10),
          //padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            boxShadow: kElevationToShadow[4],
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: InkWell(
            onTap: (){
              // Navigator.pushNamed(context, SingleCategoryFrames.routeName);
              // Navigator.pushNamed(context, SingleCategoryFrames.routeName);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>SingleCategoryGreetings(
                bannerModel: bannerModel,)));

              print(bannerModel.frameLocationName);
              print(bannerModel.assetsCompletePath);
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
                    //crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontWeight: FontWeight.bold,
                                  fontSize: 23),
                                ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                // Text(bannerModel.bannerDescription)
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ImageIcon(
                              AssetImage(bannerModel.iconPath),
                              color: Colors.red,
                              size: 30,
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
          //),
        ),
      ],
    );
  }
}
