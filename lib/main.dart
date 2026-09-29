import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:news_app/bindings/app_bindings.dart';
import 'package:news_app/controllers/auth_controller.dart';
import 'package:news_app/controllers/profile_controller.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/services/auth_service.dart';
import 'package:news_app/services/connectivity_service.dart';
import 'package:news_app/services/favorites_service.dart';
import 'package:news_app/services/profile_service.dart';
import 'package:news_app/services/tts_service.dart';
import 'package:news_app/utils/app_theme.dart';
import 'package:news_app/utils/theme_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  await FavoritesService.init();
  await AuthService.init();                        // ⭐ Auth Hive box
  await ProfileService.init();                     // ⭐ Profile Hive box
  Get.put(ConnectivityService(), permanent: true);
  Get.put(TtsService(), permanent: true);
  Get.put(AuthController(), permanent: true);      // ⭐ Auth controller
  Get.put(ProfileController(), permanent: true);   // ⭐ Profile controller
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, mode, _) {
        return GetMaterialApp(
          title: 'News App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          initialBinding: AppBindings(),
        );
      },
    );
  }
}