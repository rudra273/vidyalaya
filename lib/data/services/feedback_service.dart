import 'package:http/http.dart' as http;

// ─── Feedback → Google Form ─────────────────────────────────────

/// Submits in-app feedback straight to the linked Google Form
/// (responses land in its Google Sheet). Only the student's own text and
/// rating are sent: no name, email or account id, since every student is
/// treated as under 18 and nothing on the screen says who is sending.
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
  static const _ratingEntry = 'entry.97815554'; // Rate (1–5 stars)

  /// Sends [message] to the Google Form. Returns true on success.
  /// [rating] is 1–5 stars; pass null/0 to skip it.
  static Future<bool> submit({
    required String message,
    int? rating,
  }) async {
    final body = <String, String>{
      _messageEntry: message,
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
