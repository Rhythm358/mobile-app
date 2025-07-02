import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager implements AppOpenAdLoadCallback {
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;

  void loadAd({required bool isPersonalized}) {
    final adRequest = AdRequest(
      nonPersonalizedAds: !isPersonalized, // パーソナライズ設定
    );

    AppOpenAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-1474069724283041/7213598425' // AndroidユニットID
          : 'ca-app-pub-1474069724283041/8559503527', // iOSユニットID
      request: adRequest,
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

  void showAdIfLoaded() async {
    if (_isAdLoaded) {
      _appOpenAd?.show();
    } else {
      // ATT許可状況に応じて広告をロード
      if (Platform.isIOS) {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.authorized) {
          loadAd(isPersonalized: true); // パーソナライズ広告をロード
        } else {
          loadAd(isPersonalized: false); // 非パーソナライズ広告をロード
        }
      } else {
        // Androidは非パーソナライズ広告をロード（必要なら条件分岐可能）
        loadAd(isPersonalized: false);
      }
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

  void onAppOpenAdClosed() async {
    _appOpenAd?.dispose();
    _isAdLoaded = false;
    // ATT許可状況に応じて広告をロード
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.authorized) {
        loadAd(isPersonalized: true); // パーソナライズ広告をロード
      } else {
        loadAd(isPersonalized: false); // 非パーソナライズ広告をロード
      }
    } else {
      // Androidは非パーソナライズ広告をロード（必要なら条件分岐可能）
      loadAd(isPersonalized: false);
    }
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
