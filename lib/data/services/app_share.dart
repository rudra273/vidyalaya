import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── App sharing & Play Store links ─────────────────────────────

/// Small static helper for "share the app" and "rate / feedback"
/// actions. No state — safe to call from anywhere.
class AppShare {
  AppShare._();

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.vidyalaya.ai';

  static const shareMessage =
      'Study smarter with Vidyālaya — free SCERT Odisha books and an AI tutor, '
      'right on your phone!\n$playStoreUrl';

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
