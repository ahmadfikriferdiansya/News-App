import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  /// Share artikel via native sheet (WhatsApp, Telegram, Email, dll.)
  static Future<void> shareArticle(NewsArticle article) async {
    if (article.url == null) {
      Get.snackbar(
        'Error',
        'Artikel ini tidak memiliki link',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final title = article.title ?? 'Berita Menarik';
    final source = article.source?.name ?? 'News App';
    final url = article.url!;

    final text = '📰 $title\n\n'
        '🔗 Sumber: $source\n'
        '$url\n\n'
        '— Dibagikan via News App';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: title,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membagikan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Share via WhatsApp — pakai native sheet saja
  /// (deep link wa.me tidak selalu bekerja di semua platform)
  static Future<void> shareToWhatsApp(NewsArticle article) async {
    if (article.url == null) return;

    final title = article.title ?? 'Berita';
    final text = '📰 $title\n\n${article.url!}\n\n— via News App';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: title,
        ),
      );
    } catch (e) {
      await shareArticle(article);
    }
  }

  /// Share via Twitter/X — pakai native sheet juga
  static Future<void> shareToTwitter(NewsArticle article) async {
    if (article.url == null) return;

    final title = article.title ?? 'Berita';
    final text = '$title\n\n${article.url!}';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: title,
        ),
      );
    } catch (e) {
      await shareArticle(article);
    }
  }
}