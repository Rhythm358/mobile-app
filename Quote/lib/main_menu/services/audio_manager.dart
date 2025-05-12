import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AudioManager {
  // シングルトンパターンの実装
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    audioPlayer = AudioPlayer();
  }

  late AudioPlayer audioPlayer;

  // 音楽ファイルのリスト
  final List<String> musicFiles = [
    'assets/sfx/ChasingTheSun.mp3',
    'assets/sfx/RiseAndShine.mp3',
    'assets/sfx/StepIntoTheLight.mp3',
    'assets/sfx/BreakingFree.mp3',
  ];

  // オーディオセッションの設定
  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
    ));
  }

  // ランダムな音楽を再生
  Future<void> playRandomMusic() async {
    final randomMusic = (musicFiles..shuffle()).first;
    try {
      await audioPlayer.setAudioSource(
        AudioSource.asset(
          randomMusic,
          tag: MediaItem(
            id: randomMusic,
            album: "Background Music",
            title: "Relaxing Track",
            artUri: null,
          ),
        ),
      );
      audioPlayer.setLoopMode(LoopMode.one); // BGMをループ再生
      audioPlayer.setVolume(0.2); // 20%の音量に設定
      audioPlayer.play();
    } catch (e) {
      print('Error playing music: $e');
    }
  }

  // 音楽停止
  Future<void> stopMusic() async {
    await audioPlayer.stop();
  }

  // リソース解放
  void dispose() {
    audioPlayer.dispose();
  }
}
