import 'package:flutter/material.dart';
import 'package:todo/ui/todo_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/theme_mode.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


//*********************************************************
//  リリース時にやること
//    todo_screen.dart
//    FacebookAudienceNetwork.init testingId をコメントアウト
//    todo_screen.dart memo_screen.dart
//    _showBannerAd コメント切り替え
//  facebookアプリを確認用実機にインストールする必要がある。(gkccアカウントでログイン)
//*********************************************************

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Bindingを初期化
  MobileAds.instance.initialize();  // Admob 初期化
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final themeModeNotifier = ThemeModeNotifier(pref);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModeNotifier>(
          create: (context) => themeModeNotifier,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeNotifier>(
      builder: (context, mode, child) => MaterialApp(
        title: 'Todo Planning',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: mode.mode,
        debugShowCheckedModeBanner: false,
        home: const TodoScreen(),
      ),
    );
  }
}
