import 'package:get/get.dart';
import 'package:news_app/controllers/favorites_controller.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/controllers/news_search_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<NewsController>(NewsController());
    Get.put<NewsSearchController>(NewsSearchController());
    Get.put<FavoritesController>(FavoritesController());
  }
}