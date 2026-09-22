import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;

/// Thin wrapper around [FirebaseAuth].
///
/// Google sign-in is platform-split: on Flutter Web, `google_sign_in` v7
/// requires either its own rendered button or a FedCM prompt — it can't be
/// triggered from an arbitrary custom button press. FirebaseAuth's own
/// `signInWithPopup(GoogleAuthProvider())` does that job on web and keeps
/// the app's pill-outline "Continue with Google" button intact. On mobile,
/// where a popup isn't available, we fall back to the `google_sign_in`
/// package's native flow and hand its token to FirebaseAuth.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (fullName.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(fullName.trim());
      await credential.user?.reload();
    }
    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      // signInWithPopup only resolves/rejects once the popup posts a
      // message back. If the popup's target is unreachable (e.g. pointed
      // at an emulator that isn't running) it just sits there — there's no
      // built-in timeout, so the caller would hang forever with no error.
      // Bound it explicitly so the UI can always recover.
      return _auth
          .signInWithPopup(GoogleAuthProvider())
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw FirebaseAuthException(
              code: 'popup-timeout',
              message:
                  'The Google sign-in window did not respond. If you are '
                  'developing locally, make sure either the Firebase '
                  'emulators are running or firebase_options.dart points '
                  'at a real project.',
            ),
          );
    }

    final googleSignIn = google_sign_in.GoogleSignIn.instance;
    await googleSignIn.initialize();
    final account = await googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await google_sign_in.GoogleSignIn.instance.signOut();
    }
  }
}
