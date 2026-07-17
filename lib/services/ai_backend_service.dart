import 'package:cloud_functions/cloud_functions.dart';

/// Calls the `coachChat` Cloud Function (see /functions/index.js), which
/// proxies Gemini server-side so the API key never ships inside the app.
/// Requires the caller to be signed in (the function checks Firebase Auth).
///
/// Every method returns null on any failure — network error, function not
/// yet deployed, user signed out, quota exceeded — so callers can fall back
/// to [AiCoachService]'s offline templates rather than surfacing a raw error
/// for what's meant to be a delightful, always-available feature.
class AiBackendService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String?> chat({
    required String message,
    String? name,
    int? streak,
    double? happinessScore,
  }) async {
    try {
      final callable = _functions.httpsCallable('coachChat');
      final result = await callable
          .call<Map<String, dynamic>>({
            'message': message,
            'context': {
              'name': ?name,
              'streak': ?streak,
              'happinessScore': ?happinessScore,
            },
          })
          .timeout(const Duration(seconds: 20));
      final reply = result.data['reply'];
      return reply is String && reply.trim().isNotEmpty ? reply.trim() : null;
    } catch (_) {
      return null;
    }
  }
}
