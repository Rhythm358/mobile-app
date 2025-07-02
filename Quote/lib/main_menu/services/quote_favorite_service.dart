import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quote.dart';

class QuoteFavoriteService {
  List<Quote> favoriteQuotes = [];
  bool showingFavorites = false;

  // コールバック関数
  final VoidCallback onFavoritesChanged;

  QuoteFavoriteService({required this.onFavoritesChanged});

  // お気に入り表示切り替え処理
  Future<bool> toggleFavoritesView(List<Quote> quotes) async {
    showingFavorites = !showingFavorites;

    if (showingFavorites && favoriteQuotes.isEmpty) {
      // お気に入りが空の場合、元に戻す
      showingFavorites = false;
      return false; // メッセージ表示のためにfalseを返す
    }

    onFavoritesChanged();
    return true;
  }

  // お気に入り切り替え処理
  Future<void> toggleFavorite(Quote quote, List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorites') ?? [];

    quote.isFavorite = !quote.isFavorite;

    if (quote.isFavorite) {
      favorites.add(quote.id);
    } else {
      favorites.remove(quote.id);
    }

    await prefs.setStringList('favorites', favorites);
    updateFavoritesList(quotes);
  }

  // お気に入りリスト更新処理
  void updateFavoritesList(List<Quote> quotes) {
    favoriteQuotes = quotes.where((q) => q.isFavorite).toList();

    // お気に入りが空の場合、通常画面に戻す
    if (showingFavorites && favoriteQuotes.isEmpty) {
      showingFavorites = false;
    }

    onFavoritesChanged();
  }

  // お気に入りの読み込み
  Future<void> loadFavorites(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favorites = prefs.getStringList('favorites') ?? [];

    // 各名言のお気に入り状態を設定
    for (var quote in quotes) {
      quote.isFavorite = favorites.contains(quote.id);
    }

    updateFavoritesList(quotes);
  }
}
