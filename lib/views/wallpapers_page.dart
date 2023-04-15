import 'package:flutter/material.dart';
import 'package:photo_frame_second/global_items/global_items.dart';
import 'package:photo_frame_second/models/banner_model.dart';
import 'package:photo_frame_second/widgets/our_scaffold.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';


class WallpapersPage extends StatefulWidget {
  static const routeName = "/wallpapersPage";

  const WallpapersPage({Key? key}) : super(key: key);

  @override
  State<WallpapersPage> createState() => _WallpapersPageState();
}

class _WallpapersPageState extends State<WallpapersPage> {
  final scrollController = ScrollController(initialScrollOffset: 0);

  @override
  Widget build(BuildContext context) {
    return OurScaffold(
      appBarTitle: "Wallpapers",
      scaffoldBody: Container(
        child: StaggeredGridView.countBuilder(
          staggeredTileBuilder: (index)=>StaggeredTile.count(1,index.isEven?1.5:1),
          controller: scrollController,
          scrollDirection: Axis.vertical,
          crossAxisCount: 2,
          // mainAxisSpacing: 10,
          // childAspectRatio: 1.5,
          itemCount: GlobalItems().framesBannerList.length,
          itemBuilder: (context,index)=>singleWallpaperView(GlobalItems().framesBannerList[index], context,index),
        ),
      ),
    );
  }

  Widget singleWallpaperView(BannerModel bannerModel, BuildContext context,int index) {
    return Container(

      margin: EdgeInsets.all(8),
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
          // print("Pressed");
          //downloadFrame(imageNames,index);
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
                fit: BoxFit.cover,
              image: AssetImage(bannerModel.bannerImagePath)
            )

          ),
        ),
      ),

    );
  }
}
