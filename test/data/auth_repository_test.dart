import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vidyalaya/data/repositories/auth_repository.dart';

class _GoogleAccount extends Fake implements GoogleSignInAccount {
  @override
  GoogleSignInAuthentication get authentication =>
      const GoogleSignInAuthentication(idToken: 'google-token');
}

class _GoogleSignIn extends Fake implements GoogleSignIn {
  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {}

  @override
  bool supportsAuthenticate() => true;

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const [],
  }) async => _GoogleAccount();
}

// Unexpected calls (including a post-login profile write) fail the test.
class _User extends Fake implements User {}

class _Credential extends Fake implements UserCredential {
  @override
  User get user => _User();
}

class _Auth extends Fake implements FirebaseAuth {
  final result = Completer<UserCredential>();
  AuthCredential? receivedCredential;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    receivedCredential = credential;
    return result.future;
  }
}

void main() {
  test(
    'sign-in finishes with Firebase without post-login network work',
    () async {
      final auth = _Auth();
      final repository = AuthRepository(
        firebaseAuth: auth,
        googleSignIn: _GoogleSignIn(),
      );
      var completed = false;
      final signingIn = repository.signInWithGoogle().then((value) {
        completed = true;
        return value;
      });
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);
      expect(auth.receivedCredential?.providerId, 'google.com');

      final credential = _Credential();
      auth.result.complete(credential);
      expect(await signingIn, same(credential));
      expect(completed, isTrue);
    },
  );

  test('Firebase sign-in errors still reach the caller', () async {
    final auth = _Auth();
    final repository = AuthRepository(
      firebaseAuth: auth,
      googleSignIn: _GoogleSignIn(),
    );
    final signingIn = repository.signInWithGoogle();
    final error = FirebaseAuthException(code: 'network-request-failed');
    final assertion = expectLater(signingIn, throwsA(same(error)));
    await Future<void>.delayed(Duration.zero);
    auth.result.completeError(error);
    await assertion;
  });
}
