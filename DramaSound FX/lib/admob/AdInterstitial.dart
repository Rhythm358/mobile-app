import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class AdInterstitial {
  InterstitialAd? _interstitialAd;
  int num_of_attempt_load = 0;
  bool? ready;

  // create interstitial ads
  void createAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // 広告が正常にロードされたときに呼ばれます。
        onAdLoaded: (InterstitialAd ad) {
          print('add loaded');
          _interstitialAd = ad;
          num_of_attempt_load = 0;
          ready = true;
        },
        // 広告のロードが失敗した際に呼ばれます。
        onAdFailedToLoad: (LoadAdError error) {
          num_of_attempt_load++;
          _interstitialAd = null;
          if (num_of_attempt_load <= 2) {
            createAd();
          }
        },
      ),
    );
  }

  // show interstitial ads to user
  Future<void> showAd() async {
    ready = false;
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print("ad onAdshowedFullscreen");
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print("ad Disposed");
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError aderror) {
        print('$ad OnAdFailed $aderror');
        ad.dispose();
        createAd();
      },
    );

    // 広告の表示には.show()を使う
    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  // 広告IDをプラットフォームに合わせて取得
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1474069724283041/9339587404'; // Android
    } else {
      return 'ca-app-pub-1474069724283041/1287489956'; // iOS
    }
  }
}