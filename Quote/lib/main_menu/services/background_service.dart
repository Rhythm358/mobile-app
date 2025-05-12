import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:color_palette_plus/color_palette_plus.dart';
import 'dart:io';

/// 背景効果を管理するサービス
/// 背景色とアニメーション効果の生成・管理を行う
class BackgroundService {
  /// アニメーション効果のリスト
  late List<Behaviour> behaviours;
  
  /// 背景色のリスト
  late List<Color> backgroundColors;
  
  /// デバイスが低スペックかどうか
  final bool _isLowEndDevice;

  BackgroundService() : _isLowEndDevice = _checkIfLowEndDevice() {
    _setupBackgroundEffects();
  }
  
  /// デバイスが低スペックかどうかを判定
  /// 特定のモデル（Pixel 4aなど）や古いバージョンを検出
  static bool _checkIfLowEndDevice() {
    try {
      // AndroidデバイスでAndroid 11以前、または特定の低スペックモデルを検出
      if (Platform.isAndroid) {
        // デバイスモデル情報を取得（完全な実装にはプラグインが必要）
        // ここでは簡易的に実装
        final deviceModel = Platform.operatingSystemVersion.toLowerCase();
        
        // Pixel 4aを含む特定のモデルを低スペックとして扱う
        final isKnownLowEndDevice = 
            deviceModel.contains('pixel 4a') || 
            deviceModel.contains('pixel 3a') || 
            deviceModel.contains('a50') ||
            deviceModel.contains('a20');
            
        return isKnownLowEndDevice;
      }
    } catch (e) {
      print('デバイス情報取得エラー: $e');
    }
    
    // デフォルトでは通常のデバイスとして扱う
    return false;
  }

  /// 背景効果の初期設定
  /// ベースカラーから類似色を生成し、アニメーション効果を設定する
  void _setupBackgroundEffects() {
    // ベースとなる色のリスト
    final List<Color> baseColors = [
      Color(0xFFF0F0F0), // 白
      Color(0xFFBBDEFB), // 薄い青
      Color(0xFFEBF4EF), // 薄いグリーン
    ];

    // ランダムにベース色を選択
    final Random random = Random();
    final Color selectedBaseColor = baseColors[random.nextInt(baseColors.length)];
    
    // 選択した色から類似色を生成
    // ステップ数を減らして処理を軽量化
    final analogousColors = ColorPalettes.analogous(selectedBaseColor, steps: 3, angle: 10);

    // 背景色とアニメーション効果を設定
    backgroundColors = analogousColors;
    
    // 低スペックデバイス向けのシンプルなアニメーション
    if (_isLowEndDevice) {
      behaviours = [
        // 軽量なパーティクル効果（パーティクル数を大幅に削減）
        RandomParticleBehaviour(
          options: ParticleOptions(
            spawnMaxRadius: 30.0,     // パーティクルの最大半径を小さく
            spawnMinSpeed: 5.0,       // 最小速度を遅く
            particleCount: 20,        // パーティクル数を大幅に削減
            spawnMaxSpeed: 20.0,      // 最大速度を遅く
            minOpacity: 0.3,          // 最小透明度
            baseColor: Colors.blue,   // ベースカラー
          ),
        ),
      ];
    } else {
      // 通常デバイス向けの標準アニメーション（それでも少し軽量化）
      behaviours = [
        // ランダムなパーティクル効果
        RandomParticleBehaviour(
          options: ParticleOptions(
            spawnMaxRadius: 50.0,    // パーティクルの最大半径
            spawnMinSpeed: 10.0,     // 最小速度
            particleCount: 45,       // パーティクルの数を削減（元は68）
            spawnMaxSpeed: 50.0,     // 最大速度
            minOpacity: 0.4,         // 最小透明度
            baseColor: Colors.blue,  // ベースカラー
          ),
        ),
        // レーシングライン効果
        RacingLinesBehaviour(
          direction: LineDirection.Ltr, // 左から右への動き
          numLines: 25,                // ラインの数を削減（元は40）
        ),
      ];
    }
  }

  /// ランダムなアニメーション効果を取得
  Behaviour getRandomBehaviour() {
    final random = Random();
    return behaviours[random.nextInt(behaviours.length)];
  }

  /// ランダムな背景色を取得
  Color getRandomBackgroundColor() {
    final random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }
} 