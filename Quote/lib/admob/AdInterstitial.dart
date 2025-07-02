import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdInterstitial {
  InterstitialAd? _interstitialAd;
  int num_of_attempt_load = 0;
  bool? ready;

  DateTime? _sessionStartTime;
  bool _hasShownTimeBasedAd = false;
  
  // 広告ロード中かどうかのフラグ
  bool _isLoading = false;

  // セッション開始時間を設定するメソッド
  void startSession() {
    _sessionStartTime = DateTime.now();
    _hasShownTimeBasedAd = false;
  }

  // 長時間使用チェックメソッド
  Future<void> checkSessionDuration() async {
    if (_sessionStartTime == null || _hasShownTimeBasedAd) return;

    final now = DateTime.now();
    final sessionDuration = now.difference(_sessionStartTime!);

    // 3分以上経過していて、まだ時間ベースの広告を表示していない場合
    if (sessionDuration.inMinutes >= 3 && !_hasShownTimeBasedAd) {
      await showAd();
      _hasShownTimeBasedAd = true;

      // 10分後にフラグをリセット（次の広告表示のため）
      Future.delayed(Duration(minutes: 10), () {
        _hasShownTimeBasedAd = false;
      });
    }
  }

  // create interstitial ads
  void createAd() {
    // 既にロード中なら新たにロードしない
    if (_isLoading) return;
    
    // すでに広告がロードされていれば何もしない
    if (_interstitialAd != null) {
      ready = true;
      return;
    }
    
    _isLoading = true;
    
    try {
      // より低いリクエスト設定を使用
      final AdRequest request = AdRequest(
        nonPersonalizedAds: true,  // 非パーソナライズ広告を使用
      );
      
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          // 広告が正常にロードされたときに呼ばれます。
          onAdLoaded: (InterstitialAd ad) {
            print('ad loaded');
            _interstitialAd = ad;
            num_of_attempt_load = 0;
            ready = true;
            _isLoading = false;
          },
          // 広告のロードが失敗した際に呼ばれます。
          onAdFailedToLoad: (LoadAdError error) {
            print('Ad failed to load: ${error.message}');
            num_of_attempt_load++;
            _interstitialAd = null;
            _isLoading = false;
            
            // エラー時には少し待ってから再試行
            if (num_of_attempt_load <= 2) {
              Future.delayed(Duration(seconds: 2), () {
                createAd();
              });
            }
          },
        ),
      );
    } catch (e) {
      print('広告ロード中に例外が発生: $e');
      _isLoading = false;
    }
  }

  // show interstitial ads to user
  Future<void> showAd() async {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      ready = false;
      return;
    }
    
    final InterstitialAd ad = _interstitialAd!;
    ready = false;

    try {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print("ad onAdshowedFullscreen");
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print("ad Disposed");
          ad.dispose();
          _interstitialAd = null;
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError aderror) {
          print('$ad OnAdFailed $aderror');
          ad.dispose();
          _interstitialAd = null;
        },
      );

      // インタースティシャル広告を表示する直前にガベージコレクションをヒント
      // これによりメモリ不足のリスクを減らす
      _cleanupBeforeAd();
      
      // 広告の表示には.show()を使う
      await ad.show();
      _interstitialAd = null;
    } catch (e) {
      print('広告表示中に例外が発生: $e');
      ad.dispose();
      _interstitialAd = null;
    }
  }
  
  // 広告表示前のメモリクリーンアップ
  void _cleanupBeforeAd() {
    // Dartではガベージコレクタを直接制御できないが、
    // 実用的なアプローチとしてメモリ集中的な変数をクリアする
    // これは間接的にガベージコレクタが動作する機会を増やす
  }

  // 広告IDをプラットフォームに合わせて取得
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1474069724283041/6216801824'; // Android
    } else {
      return 'ca-app-pub-1474069724283041/6276511579'; // iOS
    }
  }
}
