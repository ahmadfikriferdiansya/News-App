import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/favorites_service.dart';

class FavoritesController extends GetxController {
  final FavoritesService _service = FavoritesService();

  // Observable list untuk UI
  final favorites = <NewsArticle>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    favorites.value = _service.getAll();
  }

  bool isFavorite(NewsArticle article) {
    return favorites.any((a) => a.url == article.url);
  }

  Future<void> toggle(NewsArticle article) async {
    if (isFavorite(article)) {
      await _service.remove(article);
      favorites.removeWhere((a) => a.url == article.url);
      Get.snackbar(
        'Dihapus',
        'Berita dihapus dari Favorites',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      await _service.add(article);
      favorites.insert(0, article);
      Get.snackbar(
        'Disimpan',
        'Berita ditambahkan ke Favorites',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }
}