import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:news_app/controllers/favorites_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fav = Get.find<FavoritesController>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === GAMBAR KIRI (120x120) ===
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: article.urlToImage != null
                        ? CachedNetworkImage(
                            imageUrl: article.urlToImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDark
                                  ? const Color(0xFF22222C)
                                  : const Color(0xFFE5E7EB),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDark
                                  ? const Color(0xFF22222C)
                                  : const Color(0xFFE5E7EB),
                              child: const Icon(Icons.image_not_supported,
                                  size: 24),
                            ),
                          )
                        : Container(
                            color: isDark
                                ? const Color(0xFF22222C)
                                : const Color(0xFFE5E7EB),
                            child: const Icon(Icons.newspaper, size: 28),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // === KONTEN KANAN ===
                Expanded(
                  child: SizedBox(
                    height: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source + bookmark
                        Row(
                          children: [
                            if (article.source?.name != null)
                              Expanded(
                                child: Text(
                                  article.source!.name!.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Obx(() {
                              final isFav = fav.isFavorite(article);
                              return GestureDetector(
                                onTap: () => fav.toggle(article),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: isFav
                                      ? Colors.red
                                      : theme.textTheme.bodySmall?.color,
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Expanded(
                          child: Text(
                            article.title ?? 'No title',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.35,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Time
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article.publishedAt != null
                                  ? timeago.format(
                                      DateTime.parse(article.publishedAt!))
                                  : '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}