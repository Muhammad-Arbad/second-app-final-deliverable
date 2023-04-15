import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:photo_frame_second/global_items/our_ads.dart';
import 'package:photo_frame_second/views/single_view_my_stuff.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';


class MyStuff extends StatefulWidget {

  MyStuff();
  @override
  State<MyStuff> createState() => _MyStuffState();
}

class _MyStuffState extends State<MyStuff> {
  List<String> imageNames = [];
  BannerAd? bannerAd;

  @override
  void initState() {
    loadFrames();
    // _createBannerAd();

    bannerAd = AdCreation().createBannerAd();
    log(bannerAd!.responseInfo.toString());
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }





  void loadFrames() async {

    imageNames = [];
    final String dir = (await getApplicationDocumentsDirectory()).path;

    io.Directory("$dir").listSync().forEach((element) {

      if (element.path.contains('jpg') && !element.path.contains('wallpapers') && !element.path.contains('greetings')) {
        // print(element.path);
        imageNames.add(element.path);
      };

      // imageNames.add(element.path);
    });

    setState(() {});

  }

  @override
  Widget build(BuildContext context) {

    return OurScaffold(
        appBarTitle: "My Creation",
        scaffoldBody:
        imageNames.length !=0 ?
        Column(
          children: [

            AdCreation().showBannerAd(bannerAd),


            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: GridView.count(
                  // controller: scrollController,
                  scrollDirection: Axis.vertical,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                  children: List.generate(
                    imageNames.length,
                        (index) => myImages(context, imageNames[index], index,() {
                          loadFrames();
                        }),
                  ),
                  // ),
                ),
              ),
            ),
          ],
        ):
            const Center(
              child: Text("No Creations Yet"),
            ),

      // bottomNavigatorBar: bannerAd == null
      //     ? null
      //     : Container(
      //   //margin: const EdgeInsets.only(bottom: 12),
      //   height:60,
      //   child: AdWidget(ad: bannerAd!),
      // ),
    );
  }



  myImages(BuildContext context, String imageNam, int index, Function loadAgain) {

    return Container(
      child: InkWell(
        borderRadius: BorderRadius.only(
          bottomLeft:
          index % 2 == 1 ? Radius.circular(6) : Radius.circular(6),
          bottomRight:
          index % 2 == 0 ? Radius.circular(6) : Radius.circular(6),
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        highlightColor: Colors.orangeAccent.withOpacity(0.3),
        splashColor: Colors.orangeAccent.withOpacity(0.3),
        onTap: () {
          
          Navigator.push(context,MaterialPageRoute(builder: (context)=>SingleViewMyStuff(imageNames: imageNam))).then((value) => loadAgain());

        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: index % 2 == 1
                  ? Radius.circular(6)
                  : Radius.circular(6),
              bottomRight: index % 2 == 0
                  ? Radius.circular(6)
                  : Radius.circular(6),
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            image: DecorationImage(
              image: FileImage(File(imageNames[index])),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
