import 'dart:io';
import 'dart:math'; // Random クラスをインポート

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:audio_session/audio_session.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isRepeat = false;
  bool _isShuffle = false; // ランダム再生の状態を管理する変数
  String? _currentAudioPath;
  int? _selectedIndex;
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    //+++++++++++++++++++++++++++++++++++
    // アプリ起動時広告
    //+++++++++++++++++++++++++++++++++++
    // AppTrackingTransparency.requestTrackingAuthorization().then((_) async {
    //   final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    //   if (status == TrackingStatus.authorized) {
    //     // 許可が得られた場合、広告をロード
    //     appOpenAdManager.loadAd();
    //   }
    // });
    // _listener = AppLifecycleListener(
    //   onShow: () => appOpenAdManager.loadAd(),
    // );
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
    super.initState();
    _setupAudioSession();
    _incrementAppLaunchCount();
  }

  void _incrementAppLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    int appLaunchCount = prefs.getInt(ReviewManager.keyAppLaunchCount) ?? 0;
    await prefs.setInt(ReviewManager.keyAppLaunchCount, appLaunchCount + 1);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
  }

  // ランダム再生のON/OFFを切り替えるメソッド
  void _toggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

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
            //--------レビュー状態表示ボタン---------------
            // ElevatedButton(
            //   onPressed: () async {
            //     await ReviewManager.showStatusDialog(context);
            //   },
            //   child: Text('Show Review Status'),
            // ),
            //----------------------------------------
            _buildBottomAppBar(palette),
            const AdaptiveBanner(),
          ],
        ),
      ),
    );
  }

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

  Widget _buildBottomAppBar(Palette palette) {
    return BottomAppBar(
      color: palette.backgroundPlaySession,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAnimatedButton(
              icon: _isRepeat ? Icons.repeat_one : Icons.repeat,
              onPressed: _toggleRepeat,
              isActive: _isRepeat,
              label: 'Repeat',
            ),
            _buildAnimatedButton(
              icon: _isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: _togglePlayStop,
              isActive: _isPlaying,
              label: _isPlaying ? 'Pause' : 'Play',
            ),
            // ランダム再生ボタンを追加
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? palette.inkFullOpacity : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            onPressed();
            HapticFeedback.lightImpact();
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              icon,
              size: 32,
              color: isActive
                  ? palette.inkFullOpacity
                  : palette.inkFullOpacity.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildSoundButton(BuildContext context, Map<String, String> sound,
      Palette palette, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _playAudio(sound['audio']!);
        });
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

  void _togglePlayStop() {
    if (_isPlaying) {
      _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else if (_currentAudioPath != null) {
      _playAudio(_currentAudioPath!);
    } else {
      // 初めて再生する場合、ランダム再生が有効ならランダムな音を再生
      if (_isShuffle) {
        List<Map<String, String>> allSounds = [];
        categorizedSoundList.forEach((key, value) {
          allSounds.addAll(value);
        });
        final random = Random();
        final randomSound = allSounds[random.nextInt(allSounds.length)];
        _playAudio(randomSound['audio']!);
      } else {
        // ランダム再生が無効なら、最初の音を再生
        if (categorizedSoundList.isNotEmpty) {
          String firstCategory = categorizedSoundList.keys.first;
          if (categorizedSoundList[firstCategory]!.isNotEmpty) {
            _playAudio(categorizedSoundList[firstCategory]!.first['audio']!);
          }
        }
      }
    }
  }

  void _toggleRepeat() {
    setState(() => _isRepeat = !_isRepeat);
    _audioPlayer
        .setReleaseMode(_isRepeat ? ReleaseMode.loop : ReleaseMode.release);
  }

  void _playAudio(String audioPath) async {
    await _audioPlayer.stop();

    // ------------レビューを表示------------
    await _incrementSoundPlayCount();
    await ReviewManager.requestReview(context);
    // ------------------------------------

    // ランダム再生が有効な場合
    if (_isShuffle) {
      // ランダムな効果音を選択
      List<Map<String, String>> allSounds = [];
      categorizedSoundList.forEach((key, value) {
        allSounds.addAll(value);
      });
      final random = Random();
      final randomSound = allSounds[random.nextInt(allSounds.length)];
      audioPath = randomSound['audio']!;
    }

    await _audioPlayer.play(AssetSource(audioPath));
    setState(() {
      _isPlaying = true;
      _currentAudioPath = audioPath;
    });

    // 再生終了時に次の音を再生 (ランダム再生が有効な場合のみ)
    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isShuffle && _isPlaying) {
        _playAudio(_currentAudioPath!); // 再帰的に呼び出す
      }
    });
  }

  Future<void> _incrementSoundPlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    int soundPlayCount = prefs.getInt(ReviewManager.keySoundPlayCount) ?? 0;
    await prefs.setInt(ReviewManager.keySoundPlayCount, soundPlayCount + 1);
  }
}
