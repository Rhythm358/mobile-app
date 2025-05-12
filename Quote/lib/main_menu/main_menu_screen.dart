import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animated_background/animated_background.dart';
import 'package:basic/main_menu/services/ad_service.dart';
import 'package:basic/main_menu/services/audio_manager.dart';
import 'package:basic/main_menu/services/background_service.dart';
import 'package:basic/main_menu/services/quote_favorite_service.dart';
import 'package:basic/main_menu/services/tts_service.dart';
import 'package:basic/main_menu/widgets/quote_swiper.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admob/AdaptiveBanner.dart';
import 'models/quote.dart';

class MainMenuScreen extends StatefulWidget {
  //const MainMenuScreen({Key? key}) : super(key: key);
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // 各種サービスのインスタンス
  late TtsService ttsService; // テキスト読み上げサービス
  late AudioManager audioManager; // BGM管理サービス
  late AdService adService; // 広告管理サービス
  late BackgroundService backgroundService; // 背景アニメーション管理サービス
  late QuoteFavoriteService favoriteService; // お気に入り管理サービス

  // 状態管理用の変数
  List<Quote> quotes = []; // 名言リスト
  List<Quote> favoriteQuotes = []; // お気に入り名言リスト
  bool isLoading = true; // データ読み込み中フラグ
  bool showingFavorites = false; // お気に入り表示中フラグ
  String currentLanguage = 'en'; // 現在の言語設定
  int? speakingIndex; // 現在読み上げ中の名言のインデックス

  // 自動読み上げ関連の変数
  bool isAutoPlaying = false; // 自動読み上げ中フラグ
  bool _wasInBackground = false; // バックグラウンド状態フラグ
  int currentIndex = 0; // 現在表示中の名言のインデックス
  Timer? autoPlayTimer; // 自動再生用タイマー
  SwiperController swiperController = SwiperController(); // スワイプコントローラー
  late StreamSubscription<FGBGType> _fgbgSubscription; // アプリの状態監視用

  // 背景アニメーション用の変数
  Behaviour? _currentBehaviour; // 現在のアニメーションエフェクト
  Color? _currentBackgroundColor; // 現在の背景色

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // アプリのライフサイクル監視を開始
    _initializeServices(); // 各種サービスの初期化
    _setupBackgroundForegroundDetection(); // バックグラウンド検知の設定
    _loadLanguagePreference(); // 言語設定の読み込み

    // 初期の背景効果を設定
    _setRandomBackgroundEffects();
  }

  // ランダムな背景効果を設定
  void _setRandomBackgroundEffects() {
    _currentBehaviour = backgroundService.getRandomBehaviour();
    _currentBackgroundColor = backgroundService.getRandomBackgroundColor();
  }

  // アプリのライフサイクル状態が変更された時の処理
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // アプリが完全に終了した時
      _stopAllServices();
    } else if (state == AppLifecycleState.resumed) {
      // フォアグラウンドに戻ったときにメモリを解放
      _disposeUnusedResources();
    }
  }

  // 未使用リソースの解放
  void _disposeUnusedResources() {
    // いくつかのリソースをクリア
    imageCache.clear();
    imageCache.clearLiveImages();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  // 各種サービスの初期化
  void _initializeServices() {
    audioManager = AudioManager();
    audioManager.configureAudioSession(); // オーディオセッションの設定

    ttsService = TtsService();
    ttsService.setCompletionHandler(() {
      // 読み上げ完了時のコールバック設定
      if (isAutoPlaying && mounted) {
        _moveToNextQuote();
      }
    });

    favoriteService = QuoteFavoriteService(onFavoritesChanged: () {
      if (mounted) setState(() {});
    });

    backgroundService = BackgroundService();

    // 広告サービスの初期化は少し遅延させる
    Future.delayed(Duration(milliseconds: 1500), () {
      adService = AdService();
      adService.initialize();
    });
  }

  // バックグラウンド/フォアグラウンド検知の設定
  void _setupBackgroundForegroundDetection() {
    _fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      if (event == FGBGType.background) {
        _wasInBackground = true;
      } else if (event == FGBGType.foreground && _wasInBackground) {
        _wasInBackground = false;
        // フォアグラウンドに戻ってきた時にリソースを解放
        _disposeUnusedResources();

        // 広告表示は遅延させる
        Future.delayed(Duration(seconds: 1), () {
          adService.showAdIfReady();
        });
      }
    });
  }

  // リソースの解放
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAllServices();
    ttsService.dispose();
    audioManager.dispose();
    swiperController.dispose();
    adService.dispose();
    _fgbgSubscription.cancel();
    super.dispose();
  }

  // すべてのサービスを停止
  void _stopAllServices() {
    ttsService.stop();
    audioManager.stopMusic();
    autoPlayTimer?.cancel();
    isAutoPlaying = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayQuotes = favoriteService.showingFavorites
        ? favoriteService.favoriteQuotes
        : quotes;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Container(color: _currentBackgroundColor ?? Colors.white),
          AnimatedBackground(
            behaviour: _currentBehaviour ?? EmptyBehaviour(),
            vsync: this,
            child: Container(),
          ),
          QuoteSwiper(
            quotes: displayQuotes,
            isLoading: isLoading,
            isAutoPlaying: isAutoPlaying,
            currentIndex: currentIndex,
            onIndexChanged: _handleIndexChanged,
            onSpeak: _speakQuote,
            onFavorite: (quote) =>
                favoriteService.toggleFavorite(quote, quotes),
            onShare: _shareQuote,
            speakingIndex: speakingIndex,
            controller: swiperController,
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdaptiveBanner(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      leading: IconButton(
        icon: Icon(Icons.settings, color: Colors.white),
        onPressed: () => GoRouter.of(context).push('/settings'),
      ),
      actions: [
        _buildFavoriteButton(),
        _buildAutoPlayButton(),
        _buildLanguageButton(),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      icon: Icon(
        favoriteService.showingFavorites
            ? Icons.favorite
            : Icons.favorite_border,
        color: favoriteService.showingFavorites ? Colors.red : Colors.white,
      ),
      onPressed: () => _toggleFavorites(),
    );
  }

  Widget _buildAutoPlayButton() {
    return Container(
      margin: EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isAutoPlaying
                ? Colors.red.withOpacity(0.9)
                : Theme.of(context).primaryColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(50),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: isLoading || quotes.isEmpty ? null : _toggleAutoPlay,
            child: _buildAutoPlayIcon(),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoPlayIcon() {
    return Container(
      padding: EdgeInsets.all(10),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 150),
        child: isAutoPlaying
            ? Icon(
                Icons.pause_circle_outline,
                color: Colors.white,
                size: 28,
                key: ValueKey('pause'),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                key: ValueKey('play'),
                children: [
                  Icon(Icons.headphones, color: Colors.white, size: 28),
                  Icon(Icons.play_arrow, color: Colors.white, size: 16),
                ],
              ),
      ),
    );
  }

  Widget _buildLanguageButton() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: ElevatedButton.icon(
        icon: Icon(Icons.language, color: Colors.white),
        label: Text(
          currentLanguage == 'en' ? 'EN' : 'JP',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: _changeLanguage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white, width: 1),
          ),
        ),
      ),
    );
  }

  void _handleIndexChanged(int index) {
    if (index >= 0 && index < quotes.length) {
      setState(() {
        currentIndex = index;
      });
      if (!isAutoPlaying) {
        ttsService.stop();
      }
    }
  }

  Future<void> _toggleFavorites() async {
    bool success = await favoriteService.toggleFavoritesView(quotes);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No favorites yet')),
      );
    } else {
      setState(() {
        currentIndex = 0;
        if (isAutoPlaying) {
          _toggleAutoPlay(); // 自動再生を停止
        }
      });
      swiperController.move(0);
    }
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLanguage = prefs.getString('language') ?? 'en';
    });
    _loadQuotes();
    ttsService.setLanguage(currentLanguage == 'en' ? "en-US" : "ja-JP");
  }

  Future<void> _loadQuotes() async {
    try {
      final String response =
          await rootBundle.loadString('assets/quotes_${currentLanguage}.json');
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      final List<Quote> loadedQuotes = data
          .map((item) => Quote.fromJson(item as Map<String, dynamic>))
          .toList();

      loadedQuotes.shuffle();
      setState(() {
        quotes = loadedQuotes;
        isLoading = false;
        currentIndex = 0;
      });

      await favoriteService.loadFavorites(quotes);
    } catch (e) {
      print('Error loading quotes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 名言の読み上げ処理
  Future<void> _speakQuote(Quote quote, int index) async {
    if (speakingIndex == index) {
      // 同じ名言を再度タップした場合
      ttsService.stop();
      setState(() {
        speakingIndex = null;
      });
    } else {
      if (speakingIndex != null) {
        ttsService.stop();
      }
      await ttsService.speak(quote);
      setState(() {
        speakingIndex = index;
      });

      if (!isAutoPlaying) {
        ttsService.setCompletionHandler(() {
          if (mounted) {
            setState(() {
              if (speakingIndex == index) {
                speakingIndex = null;
              }
            });
          }
        });
      }
    }
  }

  // 自動再生の切り替え
  void _toggleAutoPlay() {
    setState(() {
      isAutoPlaying = !isAutoPlaying;
    });

    if (isAutoPlaying) {
      audioManager.playRandomMusic(); // BGMの再生開始
      ttsService.setCompletionHandler(() {
        if (mounted) {
          _moveToNextQuote();
        }
      });

      final displayQuotes = favoriteService.showingFavorites
          ? favoriteService.favoriteQuotes
          : quotes;

      if (currentIndex >= displayQuotes.length) {
        currentIndex = 0;
      }

      if (displayQuotes.isNotEmpty) {
        _speakQuote(displayQuotes[currentIndex], currentIndex);
      }
    } else {
      audioManager.stopMusic();
      ttsService.stop();
      autoPlayTimer?.cancel();
    }
  }

  // 次の名言に移動
  void _moveToNextQuote() {
    final displayQuotes = favoriteService.showingFavorites
        ? favoriteService.favoriteQuotes
        : quotes;

    if (displayQuotes.isEmpty) {
      setState(() {
        isAutoPlaying = false;
      });
      return;
    }

    setState(() {
      currentIndex =
          currentIndex < displayQuotes.length - 1 ? currentIndex + 1 : 0;
    });

    swiperController.move(currentIndex);

    autoPlayTimer = Timer(Duration(milliseconds: 1000), () {
      if (isAutoPlaying && mounted) {
        _speakQuote(displayQuotes[currentIndex], currentIndex);
      }
    });
  }

  Future<void> _shareQuote(Quote quote, GlobalKey cardKey) async {
    // 広告表示の前にリソースを解放
    _disposeUnusedResources();

    // 少し遅延させてから広告表示を試みる
    Future.delayed(Duration(milliseconds: 300), () async {
      await adService.showAdIfReady();
    });

    try {
      final RenderRepaintBoundary? boundary =
          cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('RenderRepaintBoundary not found.');
      }

      // 画像品質を落として処理を軽くする
      final double pixelRatio = Platform.isAndroid ? 2.0 : 3.0;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/quote_card.png';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(byteData.buffer.asUint8List());

        final String shareText = '"${quote.text}" - ${quote.author}';
        final Size screenSize = MediaQuery.of(context).size;
        final RenderBox box =
            cardKey.currentContext!.findRenderObject() as RenderBox;

        final Rect adjustedRect = Rect.fromCenter(
          center: Offset(screenSize.width / 2, screenSize.height / 2),
          width: box.size.width.clamp(0.0, 300.0),
          height: box.size.height.clamp(0.0, 200.0),
        );

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: shareText,
          sharePositionOrigin: Platform.isIOS
              ? adjustedRect
              : box.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share('"${quote.text}" - ${quote.author}');
      }
    } catch (e) {
      await Share.share('"${quote.text}" - ${quote.author}');
    }
  }

  Future<void> _changeLanguage() async {
    if (isAutoPlaying) {
      _toggleAutoPlay(); // 1回目
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLanguage = currentLanguage == 'en' ? 'ja' : 'en';
      prefs.setString('language', currentLanguage);
      isLoading = true;
    });
    _loadQuotes();
    ttsService.setLanguage(currentLanguage == 'en' ? "en-US" : "ja-JP");
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({super.parent});

  @override
  SpringDescription get spring => SpringDescription(
        mass: 0.5, // 質量を軽く
        stiffness: 200, // 剛性を上げる
        damping: 2, // 減衰係数を調整
      );
}
