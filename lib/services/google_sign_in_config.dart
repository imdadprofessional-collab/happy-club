/// The OAuth 2.0 **Web client ID** for this Firebase project (not the
/// Android client ID). Firebase needs the Google ID token to be issued for
/// this specific audience to verify it server-side during
/// `signInWithCredential`.
///
/// Find it at:
///   Firebase Console → Project settings → General → "Web client ID" under
///   the app's Google Sign-In config, OR
///   Google Cloud Console → APIs & Services → Credentials → OAuth 2.0
///   Client IDs → the one named "Web client (auto created by Google Service)".
///
/// Leave empty to disable the server-side ID-token audience check (Google
/// Sign-In will still work for account selection, but
/// [GoogleSignIn.initialize] is called without a serverClientId).
const String googleSignInServerClientId = '';
