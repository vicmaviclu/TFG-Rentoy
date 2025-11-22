import 'package:google_sign_in/google_sign_in.dart';

/// Signs in with Google on mobile platforms and returns a map with tokens.
Future<Map<String, String>?> signInWithGoogleNative() async {
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null;
  final googleAuth = await googleUser.authentication;
  return {
    'accessToken': googleAuth.accessToken ?? '',
    'idToken': googleAuth.idToken ?? '',
  };
}
