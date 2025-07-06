import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/models.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  );
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Login failed');

      final doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        throw Exception('User data not found');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Registration failed');

      // Create user profile
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        photoUrl: user.photoURL,
        points: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        achievements: [],
        preferences: {},
        isActive: true,
      );

      // Save to Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) throw Exception('Google sign in failed');

      // Check if user exists in Firestore
      final doc =
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        // Create new user profile
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          photoUrl: user.photoURL,
          points: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          achievements: [],
          preferences: {},
          isActive: true,
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore());

        return userModel;
      }
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'User account has been disabled';
      case 'requires-recent-login':
        return 'Please log in again to perform this action';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
