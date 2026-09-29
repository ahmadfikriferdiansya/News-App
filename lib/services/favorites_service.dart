import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/models/news_article.dart';

class FavoritesService {
  static const String _boxName = 'favorites';
  static const String _articlesKey = 'articles';

  /// Init Hive — panggil sekali di main.dart
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  /// Ambil semua artikel favorites dari storage
  List<NewsArticle> getAll() {
    final raw = _box.get(_articlesKey, defaultValue: <dynamic>[]) as List;
    return raw
        .map((e) => NewsArticle.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Simpan seluruh list favorites (overwrite)
  Future<void> saveAll(List<NewsArticle> articles) async {
    final data = articles.map((a) => a.toJson()).toList();
    await _box.put(_articlesKey, data);
  }

  /// Tambah 1 artikel
  Future<void> add(NewsArticle article) async {
    final current = getAll();
    if (!current.any((a) => a.url == article.url)) {
      current.insert(0, article);
      await saveAll(current);
    }
  }

  /// Hapus 1 artikel berdasarkan URL
  Future<void> remove(NewsArticle article) async {
    final current = getAll();
    current.removeWhere((a) => a.url == article.url);
    await saveAll(current);
  }

  /// Cek apakah artikel sudah di-bookmark
  bool isFavorite(NewsArticle article) {
    return getAll().any((a) => a.url == article.url);
  }
}