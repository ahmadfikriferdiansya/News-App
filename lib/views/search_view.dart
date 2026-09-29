import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_search_controller.dart';
import 'package:news_app/routes/app_routes.dart';
import 'package:news_app/services/connectivity_service.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/widgets/loading_shimmer.dart';
import 'package:news_app/widgets/news_card.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsSearchController>();
    final theme = Theme.of(context);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Offline banner
          Obx(() {
            final connService = Get.find<ConnectivityService>();
            if (connService.isOnline.value) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.withValues(alpha: 0.9),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pencarian membutuhkan internet',
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

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: textController,
              onChanged: controller.onQueryChanged,
              onSubmitted: (value) {
                controller.searchNow(value);
                textController.text = value;
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari berita...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Obx(() {
                  if (controller.query.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      textController.clear();
                      controller.onQueryChanged('');
                    },
                  );
                }),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingShimmer();
              if (controller.error.value.isNotEmpty) return _errorWidget(context);
              if (!controller.isSearching.value) {
                return _historySection(context, controller);
              }
              if (controller.results.isEmpty) return _emptyWidget(context);
              return _resultsList(controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _historySection(BuildContext context, NewsSearchController controller) {
    final theme = Theme.of(context);
    const trending = [
      'flutter',
      'artificial intelligence',
      'crypto',
      'election',
      'climate',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.history.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pencarian Terakhir',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearHistory,
                      child: const Text('Hapus Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...controller.history.map(
                  (q) => _historyItem(context, controller, q),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
          Text(
            'Trending',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trending
                .map((q) => _trendingChip(context, controller, q))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _historyItem(
    BuildContext context,
    NewsSearchController controller,
    String q,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.history_rounded, color: theme.textTheme.bodySmall?.color),
      title: Text(q),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () => controller.removeHistory(q),
      ),
      onTap: () => controller.searchFromHistory(q),
    );
  }

  Widget _trendingChip(
    BuildContext context,
    NewsSearchController controller,
    String label,
  ) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label),
      onPressed: () => controller.searchNow(label),
      backgroundColor: theme.cardColor,
      side: BorderSide(color: theme.dividerColor),
    );
  }

  Widget _resultsList(NewsSearchController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.results.length,
      itemBuilder: (context, index) {
        final article = controller.results[index];
        return NewsCard(
          article: article,
          onTap: () => Get.toNamed(AppRoutes.DETAIL, arguments: article),
        );
      },
    );
  }

  Widget _errorWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Pencarian Gagal',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Silakan coba lagi', style: theme.textTheme.bodyMedium),
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
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Hasil',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Coba kata kunci lain', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}