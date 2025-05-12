import 'dart:io';
import 'dart:ui';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/quote.dart';

class TtsService {
  final FlutterTts flutterTts = FlutterTts(); // Flutter TTSインスタンスを初期化
  String currentLanguage = 'en'; // 現在の言語設定

  TtsService() {
    _initialize(); // 初期化メソッドを呼び出し
  }

  // 初期化メソッド
  Future<void> _initialize() async {
    // 音量、スピーチレート、ピッチを設定（基本設定）
    await flutterTts.setVolume(1.0); // 音量を最大に設定
    await flutterTts.setSpeechRate(0.5); // 話す速度を標準的な値に設定
    await flutterTts.setPitch(1.0); // 声の高さを標準的な値に設定

    // iOS専用オーディオカテゴリ設定（スピーカーから音声を再生するため）
    if (Platform.isIOS) {
      await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          // スピーカーから再生
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          // Bluetooth対応
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          // 高品質Bluetooth対応
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          // 他の音声と混在可能
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }

    printAvailableVoices(); // デバッグ用：利用可能な音声リストを表示
  }

  // 言語設定メソッド
  Future<void> setLanguage(String languageCode) async {
    currentLanguage = languageCode; // 現在の言語を更新
    await flutterTts.stop(); // 現在の読み上げを停止

    if (languageCode == 'en') {
      await flutterTts.setLanguage("en-US"); // 英語設定
    } else {
      await flutterTts.setLanguage("ja-JP"); // 日本語設定
    }
  }

  // 利用可能な音声リストを取得して表示（デバッグ用）
  Future<void> printAvailableVoices() async {
    var voices = await flutterTts.getVoices;
    if (voices is List) {
      for (var voice in voices) {
        print(
            "Voice: ${voice['name']}, Locale: ${voice['locale']}"); // 利用可能な音声情報を出力
      }
    }
  }

  // 音声変更メソッド
  Future<void> setVoice(String voiceName) async {
    try {
      var voices = await flutterTts.getVoices;
      if (voices is List) {
        for (var voice in voices) {
          if (voice is Map && voice['name'] == voiceName) {
            // 明示的にString型にキャスト
            await flutterTts.setVoice({
              "name": voice['name'] as String,
              "locale": voice['locale'] as String,
            });
            print("Voice set to: ${voice['name']}"); // 設定された音声名を出力
            return;
          }
        }
      }
      print("Voice not found: $voiceName"); // 指定した音声が見つからない場合
    } catch (e) {
      print("Error setting voice: $e"); // エラー発生時のログ出力
    }
  }

  // 読み上げメソッド
  Future<void> speak(Quote quote) async {
    // 言語が一致しない場合は再設定（動的に言語変更）
    if ((quote.language == 'en' && currentLanguage != 'en') ||
        (quote.language == 'ja' && currentLanguage != 'ja')) {
      await setLanguage(quote.language);
    }

    await flutterTts.speak(quote.text); // テキストを読み上げる
  }

  // 読み上げ完了時のハンドラー設定（自動再生などで利用）
  void setCompletionHandler(VoidCallback handler) {
    flutterTts.setCompletionHandler(handler);
  }

  // 読み上げ停止メソッド
  Future<void> stop() async {
    await flutterTts.stop(); // 現在の読み上げを停止
  }

  // リソース解放メソッド（アプリ終了時など）
  void dispose() {
    flutterTts.stop(); // 読み上げ停止してリソース解放
  }
}
