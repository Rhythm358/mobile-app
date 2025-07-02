import 'dart:io';
import 'dart:math';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admob/AdAppOpen.dart';
import '../admob/AdaptiveBanner.dart';
import '../admob/ReviewManager.dart';
import '../style/palette.dart';
import 'sound.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  // ===== 変数定義 =====
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isRepeat = false;
  bool _isShuffle = false; // ランダム再生の状態を管理する変数
  String? _currentAudioPath;
  int? _selectedIndex;
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late final AppLifecycleListener _listener;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // ===== ライフサイクルメソッド =====

  /// 初期化処理
  @override
  void initState() {
    super.initState();
    //+++++++++++++++++++++++++++++++++++
    // アプリ起動時広告
    //+++++++++++++++++++++++++++++++++++
    if (Platform.isIOS) {
      // iOSの場合、ATTの許可を求める
      AppTrackingTransparency.requestTrackingAuthorization().then((_) async {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.authorized) {
          // 許可が得られた場合、広告をロード
          appOpenAdManager.loadAd();
        }
      });
      // アプリがフォアグラウンドに戻ったときも同様の処理
      _listener = AppLifecycleListener(
        onShow: () async {
          final status =
              await AppTrackingTransparency.trackingAuthorizationStatus;
          if (status == TrackingStatus.authorized) {
            appOpenAdManager.loadAd();
          }
        },
      );
    } else {
      // Androidの場合、常に広告をロード
      appOpenAdManager.loadAd();
      // アプリがフォアグラウンドに戻ったときも同様
      _listener = AppLifecycleListener(
        onShow: () => appOpenAdManager.loadAd(),
      );
    }
    //+++++++++++++++++++++++++++++++++++
    _setupAudioSession();
    _incrementAppLaunchCount();

    // リスナーを一度だけ設定
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isShuffle && _isPlaying) {
        _playAudio(_currentAudioPath!);
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
  }

  /// リソース解放処理
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // ===== 初期化関連メソッド =====

  /// アプリ起動回数をインクリメントする
  Future<void> _incrementAppLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    int appLaunchCount = prefs.getInt(ReviewManager.keyAppLaunchCount) ?? 0;
    await prefs.setInt(ReviewManager.keyAppLaunchCount, appLaunchCount + 1);
  }

  /// オーディオセッションの設定
  Future<void> _setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  // ===== 音声再生制御メソッド =====

  /// 音声再生/停止を切り替える
  void _togglePlayStop() {
    if (_isPlaying) {
      _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else if (_currentAudioPath != null) {
      _playAudio(_currentAudioPath!);
    } else {
      // 初めて再生する場合、現在のタブのカテゴリから音を選択
      final tabController = DefaultTabController.maybeOf(context);
      int currentTabIndex = 0;
      if (tabController != null) {
        currentTabIndex = tabController.index;
      }

      String currentCategory =
          categorizedSoundList.keys.elementAt(currentTabIndex);

      if (_isShuffle) {
        // ランダム再生が有効なら現在のカテゴリ内でランダムな音を再生
        final sounds = categorizedSoundList[currentCategory]!;
        final random = Random();
        final randomSound = sounds[random.nextInt(sounds.length)];
        _playAudio(randomSound['audio']!);
      } else {
        // ランダム再生が無効なら、カテゴリの最初の音を再生
        if (categorizedSoundList[currentCategory]!.isNotEmpty) {
          _playAudio(categorizedSoundList[currentCategory]!.first['audio']!);
        }
      }
    }
  }

  /// リピート再生を切り替える
  void _toggleRepeat() {
    setState(() => _isRepeat = !_isRepeat);
    _audioPlayer
        .setReleaseMode(_isRepeat ? ReleaseMode.loop : ReleaseMode.release);
  }

  /// ランダム再生のON/OFFを切り替える
  void _toggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  /// 音声を再生する
  void _playAudio(String audioPath) async {
    await _audioPlayer.stop();

    // ------------レビューを表示------------
    await _incrementSoundPlayCount();
    await ReviewManager.requestReview(context);
    // ------------------------------------

    // 現在のカテゴリと音源のインデックスを特定
    String currentCategory = '';
    int soundIndex = -1;

    for (var entry in categorizedSoundList.entries) {
      soundIndex =
          entry.value.indexWhere((sound) => sound['audio'] == audioPath);
      if (soundIndex != -1) {
        currentCategory = entry.key;
        break;
      }
    }

    // ランダム再生が有効な場合
    if (_isShuffle) {
      final sounds = categorizedSoundList[currentCategory]!;
      final random = Random();
      final randomSound = sounds[random.nextInt(sounds.length)];
      audioPath = randomSound['audio']!;
      soundIndex = sounds.indexWhere((sound) => sound['audio'] == audioPath);
    }

    await _audioPlayer.play(AssetSource(audioPath));
    setState(() {
      _isPlaying = true;
      _currentAudioPath = audioPath;
      _selectedIndex = soundIndex;

      // タブを切り替える
      final tabController = DefaultTabController.maybeOf(context);
      if (tabController != null) {
        int tabIndex =
            categorizedSoundList.keys.toList().indexOf(currentCategory);
        if (tabIndex != -1) {
          tabController.animateTo(tabIndex);
        }
      }
    });
  }

  /// 音声再生回数をインクリメントする
  Future<void> _incrementSoundPlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    int soundPlayCount = prefs.getInt(ReviewManager.keySoundPlayCount) ?? 0;
    await prefs.setInt(ReviewManager.keySoundPlayCount, soundPlayCount + 1);
  }

  // ===== UI構築メソッド =====

  /// メインのビルドメソッド
  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Palette>(context);
    return DefaultTabController(
      length: categorizedSoundList.length,
      child: Scaffold(
        appBar: _buildAppBar(context, palette),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: categorizedSoundList.entries.map((entry) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildSoundGrid(
                          context, entry.value, palette, constraints);
                    },
                  );
                }).toList(),
              ),
            ),
            _buildBottomAppBar(palette),
            const AdaptiveBanner(),
          ],
        ),
      ),
    );
  }

  /// アプリバーを構築する
  AppBar _buildAppBar(BuildContext context, Palette palette) {
    return AppBar(
      centerTitle: true,
      title: Text(
        AppLocalizations.of(context)!.appTitle,
        style: TextStyle(color: palette.inkFullOpacity),
      ),
      backgroundColor: palette.backgroundLevelSelection,
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: palette.inkFullOpacity),
          onPressed: () => GoRouter.of(context).push('/settings'),
        ),
      ],
      bottom: TabBar(
        isScrollable: true,
        tabs: categorizedSoundList.keys.map((String category) {
          return Tab(text: category);
        }).toList(),
        labelColor: palette.inkFullOpacity,
        unselectedLabelColor: palette.inkFullOpacity.withOpacity(0.5),
      ),
    );
  }

  /// 下部のコントロールバーを構築する
  Widget _buildBottomAppBar(Palette palette) {
    return BottomAppBar(
      color: palette.backgroundPlaySession,
      height: 70, // 高さを固定して一貫性を持たせる
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // 再生/一時停止ボタン（主要アクション）
            _buildAnimatedButton(
              icon: _isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: _togglePlayStop,
              isActive: _isPlaying,
              label: _isPlaying ? 'Pause' : 'Play',
            ),
            const SizedBox(width: 8),
            // プログレスバー
            Expanded(
              child: ProgressBar(
                progress: _position,
                total: _duration,
                buffered: _duration,
                onSeek: (duration) {
                  _audioPlayer.seek(duration);
                },
                thumbColor: palette.inkFullOpacity,
                progressBarColor: palette.inkFullOpacity,
                baseBarColor: palette.inkFullOpacity.withOpacity(0.3),
                bufferedBarColor: palette.inkFullOpacity.withOpacity(0.5),
                barHeight: 4,
                thumbRadius: 8,
                timeLabelTextStyle: TextStyle(
                  color: palette.inkFullOpacity,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                timeLabelPadding: 8,
                timeLabelLocation: TimeLabelLocation.above,
              ),
            ),
            const SizedBox(width: 8),
            // 補助的なコントロール
            _buildAnimatedButton(
              icon: _isRepeat ? Icons.repeat_one : Icons.repeat,
              onPressed: _toggleRepeat,
              isActive: _isRepeat,
              label: 'Repeat',
            ),
            _buildAnimatedButton(
              icon: Icons.shuffle,
              onPressed: _toggleShuffle,
              isActive: _isShuffle,
              label: 'Shuffle',
            ),
          ],
        ),
      ),
    );
  }

  /// アニメーション付きのボタンを構築する
  Widget _buildAnimatedButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
    required String label,
  }) {
    final palette = Provider.of<Palette>(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isActive
            ? palette.backgroundPlaySession.withOpacity(0.8)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isActive ? palette.inkFullOpacity : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            onPressed();
            HapticFeedback.lightImpact();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 24,
              color: isActive
                  ? palette.inkFullOpacity
                  : palette.inkFullOpacity.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  /// サウンドグリッドを構築する
  Widget _buildSoundGrid(
    BuildContext context,
    List<Map<String, String>> sounds,
    Palette palette,
    BoxConstraints constraints,
  ) {
    final double itemWidth =
        constraints.maxWidth / (constraints.maxWidth > 600 ? 5 : 3);
    final int crossAxisCount = (constraints.maxWidth / itemWidth).floor();

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        return _buildSoundButton(context, sounds[index], palette, index);
      },
    );
  }

  /// サウンドボタンを構築する
  Widget _buildSoundButton(
    BuildContext context,
    Map<String, String> sound,
    Palette palette,
    int index,
  ) {
    // 現在のカテゴリを取得
    final tabController = DefaultTabController.maybeOf(context);
    int currentTabIndex = tabController?.index ?? 0;
    String currentCategory =
        categorizedSoundList.keys.elementAt(currentTabIndex);

    // 現在再生中の音声のパスと一致するかチェック
    final isSelected = _currentAudioPath == sound['audio'];

    return GestureDetector(
      onTap: () {
        _playAudio(sound['audio']!);
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: palette.backgroundPlaySession,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? palette.inkFullOpacity : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sound['icon']!,
                style: TextStyle(
                  fontSize: 32,
                  color: palette.inkFullOpacity,
                ),
              ),
              SizedBox(height: 8),
              Text(
                sound['label']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: palette.inkFullOpacity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
