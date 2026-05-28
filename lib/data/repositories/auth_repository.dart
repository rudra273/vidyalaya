import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/backend_auth_service.dart';

const _googleServerClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

class AuthRepository {
  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required BackendAuthService backendAuthService,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _backendAuthService = backendAuthService;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final BackendAuthService _backendAuthService;
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

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    await userCredential.user?.updatePhotoURL(null);
    await _backendAuthService.me();
    return userCredential;
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
