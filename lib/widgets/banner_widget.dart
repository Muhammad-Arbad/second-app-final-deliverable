import 'package:flutter/material.dart';

class CustomBanner extends StatelessWidget {
  CustomBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      //padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: kElevationToShadow[4],
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
            child: Image.asset(
                "assets/photo_collage.jpg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.width*0.5
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        flex:2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Photo Collage",
                              style: TextStyle(
                                  color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5,),
                            Text("Collage your photos up to 8 beautiful frames")
                          ],
                        )),
                    const Expanded(
                        flex:1,
                        child:
                        ImageIcon(
                          AssetImage('assets/start_icon.png'),
                          color: Colors.green,
                        )
                    )
                  ],
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}