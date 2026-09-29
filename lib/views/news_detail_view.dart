import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/controllers/favorites_controller.dart';
import 'package:news_app/utils/share_helper.dart';
import 'package:news_app/services/tts_service.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  NewsArticle get article => Get.arguments as NewsArticle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) Get.find<TtsService>().stop();
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (article.urlToImage != null)
                      CachedNetworkImage(
                        imageUrl: article.urlToImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: theme.cardColor,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.cardColor,
                          child: const Icon(Icons.image_not_supported, size: 50),
                        ),
                      )
                    else
                      Container(color: theme.cardColor),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Bookmark
                Obx(() {
                  final fav = Get.find<FavoritesController>();
                  final isFav = fav.isFavorite(article);
                  return IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    color: isFav ? Colors.red : Colors.white,
                    onPressed: () => fav.toggle(article),
                  );
                }),
                // TTS
                Obx(() {
                  final tts = Get.find<TtsService>();
                  final isPlaying = tts.isPlaying.value;
                  return IconButton(
                    icon: Icon(isPlaying ? Icons.volume_up : Icons.volume_off),
                    color: isPlaying ? Colors.orange : Colors.white,
                    onPressed: () {
                      if (isPlaying) {
                        tts.stop();
                      } else {
                        final text = [
                          article.title ?? '',
                          article.description ?? '',
                          article.content ?? '',
                        ].where((s) => s.isNotEmpty).join('. ');
                        tts.speak(text);
                      }
                    },
                  );
                }),
                // Share
                IconButton(
                  icon: const Icon(Icons.share),
                  color: Colors.white,
                  onPressed: () => ShareHelper.shareArticle(article),
                ),
                // Menu
                PopupMenuButton<String>(
                  iconColor: Colors.white,
                  onSelected: (value) {
                    switch (value) {
                      case 'copy':
                        if (article.url != null) {
                          Clipboard.setData(ClipboardData(text: article.url!));
                          Get.snackbar('Success', 'Link copied',
                              snackPosition: SnackPosition.BOTTOM);
                        }
                        break;
                      case 'browser':
                        if (article.url != null) {
                          launchUrl(Uri.parse(article.url!),
                              mode: LaunchMode.externalApplication);
                        }
                        break;
                      case 'wa':
                        ShareHelper.shareToWhatsApp(article);
                        break;
                      case 'tw':
                        ShareHelper.shareToTwitter(article);
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'copy', child: Text('Copy Link')),
                    PopupMenuItem(value: 'browser', child: Text('Open in Browser')),
                    PopupMenuItem(value: 'wa', child: Text('Share to WhatsApp')),
                    PopupMenuItem(value: 'tw', child: Text('Share to X')),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (article.source?.name != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: theme.brightness == Brightness.dark
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                      ],
                                    ),
                              color: theme.brightness == Brightness.dark
                                  ? theme.colorScheme.primary
                                  : null,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              article.source!.name!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        if (article.publishedAt != null)
                          Text(
                            timeago.format(
                                DateTime.parse(article.publishedAt!)),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (article.title != null)
                      Text(
                        article.title!,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          letterSpacing: -0.5,
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (article.description != null)
                      Text(
                        article.description!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.8),
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (article.content != null) ...[
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Text(
                        article.content!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (article.url != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => launchUrl(
                            Uri.parse(article.url!),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Baca Artikel Lengkap'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}