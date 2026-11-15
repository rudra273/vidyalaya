import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../seed/seed_data.dart' show boards, scertOdisha;

// ─── App sharing & Play Store links ─────────────────────────────

/// Small static helper for "share the app" and "rate / feedback"
/// actions. No state — safe to call from anywhere.
class AppShare {
  AppShare._();

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.vidyalaya.ai';

  /// The AI tutor covers every supported board, but only SCERT Odisha books
  /// are hosted in the app, so the free-books claim names that board alone.
  static String get shareMessage =>
      'Study smarter with Vidyakalp — an AI tutor for '
      '${_joinNames(boards.map((board) => board.name))} textbooks, plus free '
      '${scertOdisha.name} books, right on your phone!\n$playStoreUrl';

  /// "A", "A and B", "A, B and C".
  static String _joinNames(Iterable<String> names) {
    final list = names.toList();
    if (list.length <= 1) return list.join();
    return '${list.sublist(0, list.length - 1).join(', ')} and ${list.last}';
  }

  /// Opens WhatsApp with the share message pre-filled.
  /// Falls back to the generic share sheet if WhatsApp can't be opened.
  static Future<void> shareViaWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(shareMessage)}',
    );
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) await shareApp();
  }

  /// Opens the system share sheet with the app link.
  static Future<void> shareApp() async {
    await SharePlus.instance.share(ShareParams(text: shareMessage));
  }

  /// Opens the app's Play Store listing (for ratings / feedback).
  /// Tries the Play Store app first, then falls back to the browser.
  static Future<void> openPlayStore() async {
    final market = Uri.parse('market://details?id=com.vidyalaya.ai');
    var opened = false;
    try {
      opened = await launchUrl(market, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      await launchUrl(
        Uri.parse(playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
