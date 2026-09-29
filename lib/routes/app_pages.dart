import 'package:get/get.dart';
import 'package:news_app/bindings/home_binding.dart';
import 'package:news_app/routes/app_routes.dart';
import 'package:news_app/views/auth/login_view.dart';
import 'package:news_app/views/main_shell_view.dart';
import 'package:news_app/views/news_detail_view.dart';
import 'package:news_app/views/splash_view.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;

  static final routes = [
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const MainShellView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.DETAIL,
      page: () => const NewsDetailView(),
    ),
  ];
}