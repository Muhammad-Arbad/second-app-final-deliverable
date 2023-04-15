import 'package:flutter/material.dart';
import 'package:photo_frame_second/widgets/custom_appbar.dart';

class OurScaffold extends StatelessWidget {
  String appBarTitle;
  Widget scaffoldBody;
  Widget? bottomNavigatorBar;
  Widget? bottomSheet;
  Widget? customDrawer;
  OurScaffold({Key? key,required this.appBarTitle,required this.scaffoldBody,this.bottomNavigatorBar,this.bottomSheet,this.customDrawer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        //centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(appBarTitle,style: TextStyle(fontSize: 20),),
        flexibleSpace: const Custom_AppBar(),
      ),
      body: scaffoldBody,
      bottomNavigationBar: bottomNavigatorBar,
      bottomSheet: bottomSheet,
      drawer: customDrawer,
    );
  }
}
