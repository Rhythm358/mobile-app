// ナビゲーションとルーターの基本
// 1. ナビゲーション: アプリ内の画面間の移動
// 2. ルーター: 画面とパス（URL）を関連付け、画面遷移を管理する
// 3. 基本的な構造:
//    - 各画面（route）にパスを割り当てる
//    - ネストされたルートで階層構造を表現する
//    - パラメータを使用して動的なルートを作成する
// 4. 画面遷移: context.go('/path') で指定したパスの画面に移動

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main_menu/main_menu_screen.dart';
import 'settings/settings_screen.dart';

/// ゲームのナビゲーション階層を定義するルーター
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      // メイン画面のパス
      builder: (context, state) => const MainMenuScreen(),
      // quotes パラメータを追加
      routes: [
        GoRoute(
          path: 'settings', // 設定画面のパス
          //builder: (context, state) => const SettingsScreen(),
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            fullscreenDialog: true, // モーダルスタイルで遷移
          ),
        ),
      ],
    ),
  ],
);
