import 'dart:ui'; // ぼかし効果に必要
import 'package:flutter/material.dart';

import '../models/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback onSpeak;
  final VoidCallback onFavorite; // お気に入りボタン
  final Function(GlobalKey) onShare; // 共有ボタン
  final bool isPlaying;
  final bool isFavorite;
  final bool isSpeaking;
  final GlobalKey cardKey = GlobalKey(); // カード用GlobalKey

  QuoteCard({
    required this.quote,
    required this.onSpeak,
    required this.onFavorite,
    required this.onShare,
    this.isPlaying = false,
    this.isFavorite = false,
    this.isSpeaking = false,
  });

  @override
  Widget build(BuildContext context) {
    // デバイスサイズに基づいて調整
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.height < 700; // 小さな画面用

    return RepaintBoundary(
      key: cardKey,
      child: Center(
        child: Container(
          width: screenSize.width * 0.85, // カード幅を画面幅の85%に設定
          height: screenSize.height * 0.6, // カード高さを画面高さの60%に設定
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withValues(alpha: 0.2), // 背景色に透明度追加（透過）
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1), // 軽い影で立体感を保持
                blurRadius: 10,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 背景ぼかし効果
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 15 : 25), // パディング調整
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.3),
                      Colors.grey.shade100.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 必要最小限のスペース使用
                  mainAxisAlignment: MainAxisAlignment.center, // 垂直方向で中央揃え
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: isSmallScreen ? 40 : 50, // アイコンサイズ調整
                      color: Color(0xFF6A11CB)
                          .withValues(alpha: 0.5), // 薄い紫色（薄めのトーン）
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 15),

                    // 名言テキスト
                    Text(
                      quote.text,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22,
                        // フォントサイズ調整
                        height: 1.5,
                        letterSpacing: 0.5,
                        color: Colors.black87,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2, // 滲みを防ぐため影を軽く設定
                            color: Colors.black
                                .withValues(alpha: 0.2), // 軽い影で可読性向上
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isSmallScreen ? 10 : 15),

                    // 著者名テキスト
                    Text(
                      '- ${quote.author}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18, // フォントサイズ調整（小さめ）
                        fontStyle: FontStyle.italic, // 著者名はイタリックスタイル適用
                        color: Colors.grey.shade700, // 元のグレー色で控えめな印象に
                      ),
                      textAlign: TextAlign.center, // 中央揃えでレイアウト統一感を出す
                      overflow: TextOverflow.ellipsis, // 長い名前の場合は省略表示する処理
                    ),

                    SizedBox(height: isSmallScreen ? 10 : 15),

                    // ボタン行（音声再生、お気に入り、共有）
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // ボタンを中央揃え
                      children: [
                        _buildIconButton(
                          context,
                          isSpeaking ? Icons.stop : Icons.volume_up,
                          onSpeak,
                          isSpeaking ? 'Stop reading' : 'Read aloud',
                          Color(0xFF6A11CB).withValues(alpha: 0.5), // 薄い紫色アイコン
                          isSmallScreen,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 15),
                        _buildIconButton(
                          context,
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          onFavorite,
                          'Add to favorites',
                          Color(0xFF6A11CB).withValues(alpha: 0.5),
                          isSmallScreen,
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 15),
                        _buildIconButton(
                          context,
                          Icons.share, // シェアアイコン
                          () => onShare(cardKey),
                          'Share',
                          Color(0xFF6A11CB).withValues(alpha: 0.5),
                          // 薄い紫色アイコン（共有）
                          isSmallScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon,
      VoidCallback onPressed, String tooltip,
      [Color? iconColor, bool isSmallScreen = false]) {
    return Container(
      decoration: BoxDecoration(
        color: iconColor?.withValues(alpha: 0.1) ??
            Colors.black.withValues(alpha: 0.05),
        // ボタン背景透明度追加
        borderRadius: BorderRadius.circular(12), // ボタン背景も角丸で統一感を持たせる
      ),
      child: IconButton(
        iconSize: isSmallScreen ? 24 : 28, // アイコンサイズも画面サイズによって調整可能
        icon:
            Icon(icon, color: iconColor ?? Colors.black87), // アイコンカラー設定（薄い紫など）
        onPressed: onPressed, // ボタンが押された時の動作（外部から渡されるコールバック）
        tooltip: tooltip, // ツールチップ表示（例：'Add to favorites'など説明文）
      ),
    );
  }

  GlobalKey getCardKey() {
    return cardKey;
  }
}
