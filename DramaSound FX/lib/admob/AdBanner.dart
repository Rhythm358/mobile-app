import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdBanner extends StatelessWidget {
  const AdBanner({
    required this.size,// サイズは利用時に指定
  });
  final AdSize size;
  @override
  Widget build(BuildContext context) {
    // AndroidかiOSを前提とする
    final banner = BannerAd(
      // サイズ
        size: size,
        // 広告ユニットID
        // テスト用iOSバナー : ca-app-pub-3940256099942544/2934735716
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-1474069724283041/4582084749' // Android
            : 'ca-app-pub-1474069724283041/6769264385',// iOS
        // イベントのコールバック
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) => print('Ad loaded.'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('Ad failed to load: $error');
          },
          onAdOpened: (Ad ad) => print('Ad opened.'),
          onAdClosed: (Ad ad) => print('Ad closed.'),
        ),
        // リクエストはデフォルトを使う
        request: const AdRequest())
    // 表示を行うloadをつける
      ..load();
    // 戻り値はSizedBoxで包んで返す
    return SizedBox(
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner));
  }
}