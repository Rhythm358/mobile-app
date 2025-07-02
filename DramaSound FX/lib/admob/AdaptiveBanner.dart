import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdaptiveBanner extends StatefulWidget {
  const AdaptiveBanner({Key? key}) : super(key: key);

  @override
  _AdaptiveBannerState createState() => _AdaptiveBannerState();
}

class _AdaptiveBannerState extends State<AdaptiveBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _bannerAd = BannerAd(
      // サイズ
      size: size,
      // 広告ユニットID
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-1474069724283041/6181763950' // Android test ad unit ID
          : 'ca-app-pub-1474069724283041/2511331852', // iOS test ad unit ID
      // イベントのコールバック
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
      ),
      // リクエストはデフォルトを使う
      request: const AdRequest(),
    );

    return _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //+++++++++++++++++++++++++++++++++++
    // スクリーンショット撮影用に広告を非表示にする
    //   何も表示せずスペースも占有しない
    return SizedBox.shrink();
    //+++++++++++++++++++++++++++++++++++

    if (_bannerAd != null && _isLoaded) {
      return Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // 広告がロードされていない場合は、スペースを確保するためのプレースホルダーを返す
    // return Container(
    //   height: 50, // プレースホルダーの高さ
    //   child: Center(child: Text('Ad is loading...')),
    // );
    // 広告を表示しない場合、何も表示せずスペースも占有しない
    return SizedBox.shrink();
  }
}
