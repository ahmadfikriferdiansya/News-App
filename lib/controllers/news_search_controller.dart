import 'dart:async';
import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsSearchController extends GetxController {
  final NewsService _newsService = NewsService();
  static const _historyKey = 'search_history';
  static const _maxHistory = 10;

  final isLoading = false.obs;
  final results = <NewsArticle>[].obs;
  final error = ''.obs;
  final query = ''.obs;
  final history = <String>[].obs;
  final isSearching = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void onQueryChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      results.clear();
      isSearching.value = false;
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchNews(value.trim());
    });
  }

  Future<void> searchNow(String value) async {
    final q = value.trim();
    if (q.isEmpty) return;
    _debounce?.cancel();
    query.value = q;
    await _searchNews(q);
  }

  Future<void> searchFromHistory(String q) async {
    query.value = q;
    await _searchNews(q);
  }

  Future<void> removeHistory(String q) async {
    history.remove(q);
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    history.clear();
    await _saveHistory();
  }

  Future<void> _searchNews(String q) async {
    try {
      isLoading.value = true;
      isSearching.value = true;
      error.value = '';
      final response = await _newsService.searchNews(query: q);
      results.value = response.articles;
      if (response.articles.isNotEmpty) {
        await _addToHistory(q);
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Search failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _addToHistory(String q) async {
    history.remove(q);
    history.insert(0, q);
    if (history.length > _maxHistory) {
      history.removeRange(_maxHistory, history.length);
    }
    await _saveHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_historyKey) ?? [];
    history.value = saved;
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, history.toList());
  }
}