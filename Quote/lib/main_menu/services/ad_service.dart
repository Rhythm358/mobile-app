import 'dart:async';

import '../../admob/AdInterstitial.dart';

/// 広告表示を管理するサービス
/// インタースティシャル広告の表示タイミングやセッション管理を行う
class AdService {
  /// インタースティシャル広告のインスタンス
  final AdInterstitial _adInterstitial = AdInterstitial();

  /// セッション時間をチェックするためのタイマー
  Timer? _sessionTimer;
  
  /// 広告の初期化が完了したかどうか
  bool _isInitialized = false;

  /// 広告サービスの初期化
  /// 広告の作成とセッションの開始を行う
  void initialize() {
    // セッションのみ即時開始
    _adInterstitial.startSession();
    
    // 広告の初期化を遅延させる
    // アプリの起動直後は他のリソース初期化と競合するため、少し遅らせる
    Future.delayed(Duration(seconds: 3), () {
      try {
        _adInterstitial.createAd();
        _isInitialized = true;
      } catch (e) {
        print('広告の初期化に失敗: $e');
        // エラー発生時は再度トライ
        Future.delayed(Duration(seconds: 5), () {
          try {
            _adInterstitial.createAd();
            _isInitialized = true;
          } catch (e) {
            print('広告の再初期化にも失敗: $e');
          }
        });
      }
    });

    // 1分ごとにセッション時間をチェック
    _sessionTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (_isInitialized) {
        _adInterstitial.checkSessionDuration();
      }
    });
  }

  /// 広告が準備できていれば表示する
  /// 広告表示後、次の広告をロードする
  Future<void> showAdIfReady() async {
    if (!_isInitialized) return;
    
    try {
      await _adInterstitial.showAd();
      // 広告表示後、次の広告のロードを少し遅延させる
      Future.delayed(Duration(milliseconds: 500), () {
        _adInterstitial.createAd();
      });
    } catch (e) {
      print('広告表示中にエラー: $e');
    }
  }

  /// リソースの解放
  /// タイマーをキャンセルする
  void dispose() {
    _sessionTimer?.cancel();
  }
}
