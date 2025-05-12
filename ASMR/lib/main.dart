import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'app_lifecycle/app_lifecycle.dart';
import 'router.dart';
import 'settings/settings.dart';
import 'style/palette.dart';

void main() async {
  //-----------------------------------------
  // runApp()の前に実行される必要がある処理
  //-----------------------------------------
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.yourcompany.yourapp.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // システム設定関連（フルスクリーン、画面向き）
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // デバイスの画面向きを縦向き（ポートレート）のみに制限
  // - portraitUp: 通常の縦向き
  // - portraitDown: デバイスを上下逆にした縦向き
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Google Mobile Adsの初期化
  MobileAds.instance.initialize();

  // Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(MyApp());

  //-----------------------------------------
  // runApp()の後で実行される処理
  //-----------------------------------------
  // ATT対応（iOS/iPadOSのみ）
  if (Platform.isIOS) {
    await initPlugin();
  }
}

// ATT対応
Future<void> initPlugin() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await Future.delayed(const Duration(seconds: 2)); //2秒の遅延を設定
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        // アプリ全体で利用可能なオブジェクトをここで提供
        // 各ウィジェットは `context.watch()` または `context.read()` でアクセス可能
        providers: [
          // アプリの設定を管理するコントローラー
          Provider(create: (context) => SettingsController()),
          // アプリのカラーパレットを提供
          Provider(create: (context) => Palette()),
        ],
        child: Builder(builder: (context) {
          // Paletteの変更を監視し、変更時に再ビルド
          final palette = context.watch<Palette>();

          return MaterialApp.router(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''), // 英語
              Locale('ja', ''), // 日本語
              // 他の言語を追加
            ],
            debugShowCheckedModeBanner: false,
            // エミュレータの右上に"DEBUG"を非表示
            title: 'My Flutter Game',
            theme: ThemeData.from(
              colorScheme: ColorScheme.fromSeed(
                seedColor: palette.darkPen,
                surface: palette.backgroundMain,
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(color: palette.ink),
              ),
              useMaterial3: true,
            ).copyWith(
              // ボタンのスタイルをカスタマイズ
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            routerConfig: router,
          );
        }),
      ),
    );
  }
}
