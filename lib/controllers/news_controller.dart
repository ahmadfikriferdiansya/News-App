import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  final NewsService _newsService = NewsService();

  // ✅ OBSERVABLE PUBLIC — bisa diakses langsung
  final isLoading = false.obs;
  final articles = <NewsArticle>[].obs;
  final selectedCategory = 'general'.obs;
  final error = ''.obs;

  // Kategori statis (tidak perlu observable karena tidak berubah)
  List<String> get categories => Constants.categories;

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();
  }

  Future<void> fetchTopHeadlines({String? category}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _newsService.getTopHeadlines(
        category: category ?? selectedCategory.value,
      );

      articles.value = response.articles;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load news: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  void selectCategory(String category) {
    if (selectedCategory.value != category) {
      selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  Future<void> searchNews(String query) async {
    if (query.isEmpty) return;

    try {
      isLoading.value = true;
      error.value = '';

      final response = await _newsService.searchNews(query: query);
      articles.value = response.articles;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to search news: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}