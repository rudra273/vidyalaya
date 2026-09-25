import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _googleServerClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

class AuthRepository {
  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleSignInInit;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw StateError('Google sign-in is not supported on this platform.');
    }

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Account data syncs separately through BackendAccountCache. Completing
    // authentication must not depend on the API or an unused photo update.
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _signOutFromGoogle()]);
  }

  Future<void> _signOutFromGoogle() async {
    await _ensureGoogleSignInInitialized();
    await _googleSignIn.signOut();
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInit ??= _googleSignIn.initialize(
      serverClientId: _googleServerClientId.isEmpty
          ? null
          : _googleServerClientId,
    );
  }
}
