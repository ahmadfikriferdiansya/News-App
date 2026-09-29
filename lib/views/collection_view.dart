import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/favorites_controller.dart';
import 'package:news_app/routes/app_routes.dart';
import 'package:news_app/services/connectivity_service.dart';
import 'package:news_app/widgets/news_card.dart';

class CollectionView extends StatelessWidget {
  const CollectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi Saya'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Obx(() {
            final connService = Get.find<ConnectivityService>();
            if (connService.isOnline.value) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.green.withValues(alpha: 0.9),
              child: Row(
                children: [
                  const Icon(Icons.offline_pin, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Berita tersimpan — Bisa dibaca offline',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.favorites.isEmpty) {
                return _emptyState(context, theme);
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: controller.favorites.length,
                itemBuilder: (context, index) {
                  final article = controller.favorites[index];
                  return NewsCard(
                    article: article,
                    onTap: () => Get.toNamed(
                      AppRoutes.DETAIL,
                      arguments: article,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Koleksi Kosong',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Simpan berita favorit untuk dibaca nanti',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}