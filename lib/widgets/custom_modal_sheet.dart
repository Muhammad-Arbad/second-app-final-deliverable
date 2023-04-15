import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Future<dynamic> showModal(BuildContext context, bool isAdLoaded,
    {InterstitialAd? adObj}) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setState) {
          return Container(
            height: 310,
            child: Container(
              padding: EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width * 0.90,
              child: Column(
                children: [
                  const Text(
                    "Choose Your Option",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          width: MediaQuery.of(context).size.width * .39,
                          height: MediaQuery.of(context).size.height * .21,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * .85,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 110,
                                ),
                              ),
                              const Text(
                                "May be Later",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          adObj!.fullScreenContentCallback =
                              FullScreenContentCallback(
                            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                                print('%ad onAdShowedFullScreenContent.'),
                            onAdDismissedFullScreenContent:
                                (InterstitialAd ad) {

                              print('$ad onAdDismissedFullScreenContent.');

                              ad.dispose();
                              
                            },
                            onAdFailedToShowFullScreenContent:
                                (InterstitialAd ad, AdError error) {
                              print(
                                  '$ad onAdFailedToShowFullScreenContent: $error');
                              ad.dispose();
                            },
                            onAdImpression: (InterstitialAd ad) =>
                                print('$ad impression occurred.'),
                          );
                          adObj.show();
                          
                          //Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10)),
                          width: MediaQuery.of(context).size.width * .39,
                          height: MediaQuery.of(context).size.height * .21,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * .85,
                                child: Icon(
                                  isAdLoaded == true
                                      ? FontAwesomeIcons.award
                                      : Icons.download,
                                  color: Colors.white,
                                  size: 110,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Flexible(
                                child: isAdLoaded == true
                                    ? const Text(
                                        "Watch Ad",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18),
                                      )
                                    : const Text(
                                        "Download Frame",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }));
      });
}
