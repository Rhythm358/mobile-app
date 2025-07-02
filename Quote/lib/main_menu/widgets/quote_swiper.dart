import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import '../models/quote.dart';
import 'quote_card.dart';

/// 名言をスワイプ表示するためのウィジェット
/// カード形式で名言を表示し、スワイプ操作で切り替えられる
class QuoteSwiper extends StatelessWidget {
  /// 表示する名言のリスト
  final List<Quote> quotes;
  
  /// データ読み込み中かどうか
  final bool isLoading;
  
  /// 自動再生モードかどうか
  final bool isAutoPlaying;
  
  /// 現在表示中の名言のインデックス
  final int currentIndex;
  
  /// スワイプで名言が切り替わった時のコールバック
  final Function(int) onIndexChanged;
  
  /// 名言の読み上げを開始する時のコールバック
  final Function(Quote, int) onSpeak;
  
  /// お気に入り状態を切り替える時のコールバック
  final Function(Quote) onFavorite;
  
  /// 名言を共有する時のコールバック
  final Function(Quote, GlobalKey) onShare;
  
  /// 現在読み上げ中の名言のインデックス
  final int? speakingIndex;
  
  /// スワイパーのコントローラー
  final SwiperController controller;

  const QuoteSwiper({
    Key? key,
    required this.quotes,
    required this.isLoading,
    required this.isAutoPlaying,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onSpeak,
    required this.onFavorite,
    required this.onShare,
    required this.speakingIndex,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 読み込み中はローディングインジケータを表示
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.white));
    }
    
    // 名言が空の場合はメッセージを表示
    if (quotes.isEmpty) {
      return Center(
        child: Text('No quotes found', style: TextStyle(color: Colors.white))
      );
    }

    // スワイパーで名言を表示
    return Swiper(
      controller: controller,  // スワイプの制御用コントローラー
      physics: const CustomScrollPhysics(),  // カスタムスクロール物理演算
      onIndexChanged: onIndexChanged,  // カードが切り替わった時のコールバック
      itemBuilder: (BuildContext context, int index) {
        return QuoteCard(
          quote: quotes[index],  // 表示する名言
          onSpeak: () => onSpeak(quotes[index], index),  // 読み上げボタンタップ時のコールバック
          onFavorite: () => onFavorite(quotes[index]),  // お気に入りボタンタップ時のコールバック
          onShare: (cardKey) => onShare(quotes[index], cardKey),  // 共有ボタンタップ時のコールバック
          isPlaying: isAutoPlaying && index == currentIndex,  // 自動再生中で現在のカードかどうか
          isFavorite: quotes[index].isFavorite,  // お気に入り登録済みかどうか
          isSpeaking: speakingIndex == index,  // 現在読み上げ中かどうか
        );
      },
      itemCount: quotes.length,  // 表示するカードの総数
      scrollDirection: Axis.vertical,  // 垂直方向のスワイプ
      layout: SwiperLayout.STACK,  // カードを重ねて表示するレイアウト
      itemWidth: MediaQuery.of(context).size.width * 0.85,  // カードの幅（画面幅の85%）
      itemHeight: MediaQuery.of(context).size.height * 0.6,  // カードの高さ（画面高さの60%）
      viewportFraction: 0.82,  // ビューポートの表示割合
      scale: 0.88,  // カードのスケール（縮小率）
    );
  }
}

/// スワイプ操作の物理演算をカスタマイズするクラス
/// スワイプの動きをより自然にするための設定
class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({super.parent});

  @override
  SpringDescription get spring => SpringDescription(
    mass: 0.5,      // 質量を軽くしてスムーズな動きに
    stiffness: 200, // 剛性を上げて反応を早く
    damping: 2,     // 減衰係数を調整して自然な減速に
  );
} 