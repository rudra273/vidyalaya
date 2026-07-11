import 'package:http/http.dart' as http;

// ─── Feedback → Google Form ─────────────────────────────────────

/// Submits in-app feedback straight to the linked Google Form
/// (responses land in its Google Sheet). Name/email are attached
/// silently from the signed-in user when available.
///
/// The `entry.*` IDs below come from the form's prefilled-link /
/// page source and must match its fields.
class FeedbackService {
  FeedbackService._();

  static const _formId =
      '1FAIpQLScBnxT4mASRBfrXbXiWosru2c-lMuasS705HasO_rWcBEh6rw';

  static const _responseUrl =
      'https://docs.google.com/forms/d/e/$_formId/formResponse';

  // Field IDs from the "Vidyalaya FeedBack" form.
  static const _messageEntry = 'entry.189015083'; // Feedback (paragraph)
  static const _nameEntry = 'entry.1844184014'; // Name (short answer)
  static const _emailEntry = 'entry.1201800793'; // Email (short answer)
  static const _ratingEntry = 'entry.97815554'; // Rate (1–5 stars)

  /// Sends [message] to the Google Form. Returns true on success.
  /// [rating] is 1–5 stars; pass null/0 to skip it.
  static Future<bool> submit({
    required String message,
    String? name,
    String? email,
    int? rating,
  }) async {
    final body = <String, String>{
      _messageEntry: message,
      if (name != null && name.isNotEmpty) _nameEntry: name,
      if (email != null && email.isNotEmpty) _emailEntry: email,
      if (rating != null && rating >= 1 && rating <= 5)
        _ratingEntry: '$rating',
    };
    try {
      final res = await http
          .post(Uri.parse(_responseUrl), body: body)
          .timeout(const Duration(seconds: 15));
      // Google returns 200 on success, 302 when it redirects to the
      // confirmation page — both mean the response was recorded.
      return res.statusCode == 200 || res.statusCode == 302;
    } catch (_) {
      return false;
    }
  }
}
