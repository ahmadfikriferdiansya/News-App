import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/auth_controller.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/routes/app_routes.dart';
import 'package:news_app/services/connectivity_service.dart';
import 'package:news_app/widgets/category_chip.dart';
import 'package:news_app/widgets/loading_shimmer.dart';
import 'package:news_app/widgets/news_card.dart';

class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ==================== HEADER BARU ====================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Brand + Date
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.newspaper_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'News',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        ' App',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.5,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _todayDate(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Greeting dengan nama user
                  Text(
                    '${_greeting()},',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${auth.userName} 👋',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  GestureDetector(
                    onTap: () {
                      // Pindah ke tab Search (index 1)
                      // Kita pakai Get.find MainShell? Karena ini sibling,
                      // kita gunakan pendekatan sederhana: pindah ke halaman search
                      // melalui Get.offAllNamed? Tidak bisa. Solusi: kirim event.
                      // Untuk sekarang, tampilkan snackbar sebagai info.
                      Get.snackbar(
                        'Cari Berita',
                        'Gunakan tab Search di bawah',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF22222C)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cari berita...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ==================== OFFLINE BANNER ====================
            Obx(() {
              final conn = Get.find<ConnectivityService>();
              if (conn.isOnline.value) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mode Offline',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ==================== KATEGORI CHIP ====================
            Container(
              height: 56,
              margin: const EdgeInsets.only(top: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Obx(
                      () => CategoryChip(
                        label: _capitalize(category),
                        isSelected:
                            controller.selectedCategory.value == category,
                        onTap: () => controller.selectCategory(category),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ==================== LIST BERITA ====================
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const LoadingShimmer();
                if (controller.error.value.isNotEmpty) {
                  return _errorWidget(context);
                }
                if (controller.articles.isEmpty) return _emptyWidget(context);

                return RefreshIndicator(
                  onRefresh: controller.refreshNews,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: controller.articles.length,
                    itemBuilder: (context, index) {
                      final article = controller.articles[index];
                      return NewsCard(
                        article: article,
                        onTap: () => Get.toNamed(AppRoutes.DETAIL,
                            arguments: article),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _todayDate() {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _errorWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Terjadi kesalahan',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refreshNews,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper,
              size: 64, color: theme.textTheme.bodySmall?.color),
          const SizedBox(height: 16),
          Text('Tidak ada berita',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}