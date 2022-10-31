import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late final BannerAd? myBanner ;
  final AdSize adSize = AdSize(height: 100, width: 400);
  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );

  InterstitialAd? interstitialAd;
  RewardedAd? _rewardedAd;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      myBanner= BannerAd(
        adUnitId: Platform.isAndroid==true?'ca-app-pub-3940256099942544/6300978111':"ca-app-pub-3940256099942544/2934735716",
        size: adSize,
        request: AdRequest(),
        listener: listener,
      );
      myBanner!.load();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'This is banner ad',
            ),
            myBanner!=null?Container(
              alignment: Alignment.center,
              child:  AdWidget(ad: myBanner!),
              width: double.infinity,
              height: 100,
            ):Container(),
            SizedBox(height:100),
            ElevatedButton(onPressed: (){
              setState(() {
                InterstitialAd.load(
                    adUnitId:Platform.isAndroid==true?'ca-app-pub-3940256099942544/1033173712':"ca-app-pub-3940256099942544/4411468910",
                    request: AdRequest(),
                    adLoadCallback: InterstitialAdLoadCallback(
                      onAdLoaded: (InterstitialAd ad) {
                        // Keep a reference to the ad so you can show it later.
                        this.interstitialAd = ad;
                        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
                          onAdShowedFullScreenContent: (InterstitialAd ad) =>
                              print('%ad onAdShowedFullScreenContent.'),
                          onAdDismissedFullScreenContent: (InterstitialAd ad) {
                            print('$ad onAdDismissedFullScreenContent.');
                            ad.dispose();
                          },
                          onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                            print('$ad onAdFailedToShowFullScreenContent: $error');
                            ad.dispose();
                          },
                          onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
                        );
                        interstitialAd!.show();
                      },
                      onAdFailedToLoad: (LoadAdError error) {
                        print('InterstitialAd failed to load: $error');
                      },
                    ));

              });
            }, child: Text("Show InterstitialAd ")),
            ElevatedButton(onPressed: (){

              RewardedAd.load(
                  adUnitId: Platform.isAndroid==true?"ca-app-pub-3940256099942544/5224354917":"ca-app-pub-3940256099942544/1712485313",
                  rewardedAdLoadCallback: RewardedAdLoadCallback(
                    onAdLoaded: (RewardedAd ad) {
                      print('$ad loaded.');
                      // Keep a reference to the ad so you can show it later.
                      setState(() {
                        this._rewardedAd = ad;
                        _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
                          // Reward the user for watching an ad.
                        });
                      });
                    },
                    onAdFailedToLoad: (LoadAdError error) {
                      print('RewardedAd failed to load: $error');
                    },
                  ), request:  AdRequest());




            }, child: Text("Rewarded Ad"))
          ],
        ),
      ),
    );
  }
}
