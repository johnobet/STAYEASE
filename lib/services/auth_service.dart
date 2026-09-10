import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Friendly wrapper so screens never talk to FirebaseAuth/Firestore
/// directly. Screens call this, get either a result or a plain-English
/// [AuthException], and stay dumb.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Fires on login, logout, and app start with a cached session.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  /// Creates the Auth account, then the matching Firestore profile
  /// (spec section 30: users/{userId}). If the Firestore write fails,
  /// the just-created Auth account is deleted so we don't leave an
  /// orphaned login with no profile/role.
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_readableAuthError(e));
    }

    final uid = credential.user!.uid;
    final model = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: role,
    );

    try {
      await _users.doc(uid).set(model.toMap());
      await credential.user!.updateDisplayName(name.trim());
    } catch (e) {
      await credential.user?.delete();
      throw AuthException('Could not finish creating your account. Please try again.');
    }

    return model;
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_readableAuthError(e));
    }
  }

  /// Signs in with Google. If this is the person's first time (no
  /// matching Firestore profile yet), creates one with a default role
  /// of [UserRole.tenant] — Google doesn't give us a phone number or a
  /// role choice, so a profile-completion screen can prompt them to
  /// fill those in later if needed.
  ///
  /// Returns null if the person cancelled the Google account picker —
  /// that's not an error, just "didn't finish."
  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // person cancelled the picker

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential;
    try {
      userCredential = await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_readableAuthError(e));
    }

    final user = userCredential.user!;
    final existing = await fetchUserProfile(user.uid);
    if (existing != null) return existing;

    // First-time Google sign-in — create the matching Firestore profile.
    final model = UserModel(
      uid: user.uid,
      name: user.displayName ?? googleUser.displayName ?? 'StayEase user',
      email: user.email ?? googleUser.email,
      phone: user.phoneNumber ?? '',
      role: UserRole.tenant,
    );

    try {
      await _users.doc(user.uid).set(model.toMap());
    } catch (e) {
      throw AuthException('Signed in, but could not finish setting up your profile.');
    }

    return model;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// One-shot fetch — use when you just need the profile once.
  Future<UserModel?> fetchUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  /// Live stream — use for role-based navigation so a role change or
  /// profile edit reflects immediately without a manual refresh.
  Stream<UserModel?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(uid, doc.data()!);
    });
  }

  String _readableAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'That email address doesn\'t look right.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}