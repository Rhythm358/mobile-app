import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager implements AppOpenAdLoadCallback {
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;

  void loadAd() {
    AppOpenAd.load(
      // 広告ユニットID
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-1474069724283041/6599846170' // Android test ad unit ID
          : 'ca-app-pub-1474069724283041/5166479037', // iOS test ad unit ID
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoaded = true;
          _appOpenAd?.show();
        },
        onAdFailedToLoad: (error) {
          print('App open ad failed to load: $error');
        },
      ),
    );
  }

  void showAdIfLoaded() {
    if (_isAdLoaded) {
      _appOpenAd?.show();
    } else {
      loadAd();
    }
  }

  void onAppOpenAdLoaded(AppOpenAd ad) {
    _appOpenAd = ad;
    _isAdLoaded = true;
    showAdIfLoaded();
  }

  void onAppOpenAdFailedToLoad(LoadAdError error) {
    print('App open ad failed to load: $error');
  }

  void onAppOpenAdClosed() {
    _appOpenAd?.dispose();
    _isAdLoaded = false;
    loadAd();
  }

  void dispose() {
    _appOpenAd?.dispose();
  }

  @override
  // implement onAdFailedToLoad
  FullScreenAdLoadErrorCallback get onAdFailedToLoad =>
      throw UnimplementedError();

  @override
  // implement onAdLoaded
  GenericAdEventCallback<AppOpenAd> get onAdLoaded =>
      throw UnimplementedError();
}
