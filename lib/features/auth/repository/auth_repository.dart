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
  Future<UserModel> updateUserProfile(
    String userId,
    String gender,
    DateTime dateOfBirth,
    String phone,
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
      print('🔍 AuthRepository: Getting current user...');
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        print('❌ AuthRepository: No current user in Firebase Auth');
        return null;
      }

      print('✅ AuthRepository: Current user found, ID: ${user.uid}');
      print('📧 AuthRepository: User email: ${user.email}');

      // Use timeout to prevent hanging
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      print(
        '📄 AuthRepository: Document exists in getCurrentUser: ${doc.exists}',
      );

      if (doc.exists) {
        print('✅ AuthRepository: User document found, returning UserModel');
        final userData = doc.data();
        print('📊 AuthRepository: User data in getCurrentUser: $userData');
        return UserModel.fromFirestore(doc);
      } else {
        print('❌ AuthRepository: User document not found in getCurrentUser');
        // Create a basic user model if document doesn't exist
        return UserModel(
          id: user.uid,
          email: user.email ?? 'user@example.com',
          name: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          points: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          achievements: [],
          preferences: {},
          isActive: true,
        );
      }
    } catch (e) {
      print('❌ AuthRepository: Error in getCurrentUser: $e');

      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print(
          '🔄 AuthRepository: Detected PigeonUserDetails error in getCurrentUser, using fallback',
        );

        // Try to get current user as a fallback
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          print(
            '✅ AuthRepository: getCurrentUser fallback successful, user found: ${user.uid}',
          );
          return UserModel(
            id: user.uid,
            email: user.email ?? 'user@example.com',
            name: user.displayName ?? 'User',
            photoUrl: user.photoURL,
            points: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            achievements: [],
            preferences: {},
            isActive: true,
          );
        }
      }

      // Return null instead of throwing exception to avoid crashes
      return null;
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('🔐 AuthRepository: Attempting to sign in with email: $email');

      // Perform authentication but don't use the credential response directly
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Wait a moment for Firebase Auth to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Get current user directly to avoid PigeonUserDetails bug
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Login failed: No user found after authentication');
      }

      print('✅ AuthRepository: Firebase Auth successful, user ID: ${user.uid}');
      print('📧 AuthRepository: User email: ${user.email}');

      // Try to get user document with timeout
      try {
        print('🔍 AuthRepository: Checking Firestore for user document...');
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        print('📄 AuthRepository: Firestore document exists: ${doc.exists}');

        if (doc.exists) {
          print('📄 AuthRepository: User document found in Firestore');
          final userData = doc.data();
          print('📊 AuthRepository: User data: $userData');
          return UserModel.fromFirestore(doc);
        } else {
          print(
            '📝 AuthRepository: User document not found, creating basic user profile',
          );
          // Create a basic user model for existing Firebase Auth users
          return UserModel(
            id: user.uid,
            email: user.email ?? email,
            name: user.displayName ?? 'User',
            photoUrl: user.photoURL,
            points: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            achievements: [],
            preferences: {},
            isActive: true,
          );
        }
      } catch (firestoreError) {
        print(
          '❌ AuthRepository: Firestore error during login: $firestoreError',
        );
        // Return basic user model if Firestore fails
        return UserModel(
          id: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          points: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          achievements: [],
          preferences: {},
          isActive: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      print(
        '❌ AuthRepository: FirebaseAuthException: ${e.code} - ${e.message}',
      );
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('❌ AuthRepository: General exception during sign in: $e');
      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print(
          '🔄 AuthRepository: Detected PigeonUserDetails error, using currentUser workaround',
        );

        // Try to get current user as a workaround
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          print(
            '✅ AuthRepository: Workaround successful, user found: ${user.uid}',
          );
          return UserModel(
            id: user.uid,
            email: user.email ?? email,
            name: user.displayName ?? 'User',
            photoUrl: user.photoURL,
            points: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            achievements: [],
            preferences: {},
            isActive: true,
          );
        }
      }
      throw Exception('Login failed. Please try again.');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      print('📝 AuthRepository: Attempting to register with email: $email');

      // Perform registration but don't use the credential response directly
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Wait a moment for Firebase Auth to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Get current user directly to avoid PigeonUserDetails bug
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception(
          'Registration failed: No user found after registration',
        );
      }

      print(
        '✅ AuthRepository: Firebase Auth registration successful, user ID: ${user.uid}',
      );

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
        preferences: {'isFirstTimeUser': true},
        isActive: true,
      );

      print('💾 AuthRepository: Saving user profile to Firestore...');
      print('📊 AuthRepository: User model data: ${userModel.toFirestore()}');

      try {
        // Save to Firestore with timeout
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore())
            .timeout(const Duration(seconds: 10));

        print('✅ AuthRepository: User profile successfully saved to Firestore');
        return userModel;
      } catch (firestoreError) {
        print('❌ AuthRepository: Error saving to Firestore: $firestoreError');
        print('🔄 AuthRepository: Returning user model without Firestore save');
        // Return user model even if Firestore save fails
        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      print(
        '❌ AuthRepository: FirebaseAuthException during registration: ${e.code} - ${e.message}',
      );
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('❌ AuthRepository: General exception during registration: $e');
      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print(
          '🔄 AuthRepository: Detected PigeonUserDetails error, using currentUser workaround',
        );

        // Try to get current user as a workaround
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          print(
            '✅ AuthRepository: Workaround successful, user found: ${user.uid}',
          );
          final userModel = UserModel(
            id: user.uid,
            email: user.email ?? email,
            name: user.displayName ?? name,
            photoUrl: user.photoURL,
            points: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            achievements: [],
            preferences: {'isFirstTimeUser': true},
            isActive: true,
          );

          // Try to save to Firestore
          try {
            await _firestore
                .collection(AppConstants.usersCollection)
                .doc(user.uid)
                .set(userModel.toFirestore())
                .timeout(const Duration(seconds: 5));
            print(
              '✅ AuthRepository: Workaround: User profile saved to Firestore',
            );
          } catch (firestoreError) {
            print(
              '⚠️ AuthRepository: Workaround: Could not save to Firestore: $firestoreError',
            );
          }

          return userModel;
        }
      }
      throw Exception('Registration failed. Please try again.');
    }
  }

  @override
  Future<UserModel> updateUserProfile(
    String userId,
    String gender,
    DateTime dateOfBirth,
    String phone,
  ) async {
    try {
      print('🔄 AuthRepository: Updating user profile for $userId');

      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Calculate age from date of birth
      final now = DateTime.now();
      int age = now.year - dateOfBirth.year;
      if (now.month < dateOfBirth.month ||
          (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
        age--;
      }

      // Get existing user data first
      UserModel? existingUser;
      try {
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .get()
            .timeout(const Duration(seconds: 10));

        if (doc.exists) {
          existingUser = UserModel.fromFirestore(doc);
          print('✅ AuthRepository: Found existing user data');
        }
      } catch (e) {
        print('⚠️ AuthRepository: Could not get existing user data: $e');
      }

      // Create updated user model with all required fields
      final updatedUser = UserModel(
        id: userId,
        email: existingUser?.email ?? user.email ?? '',
        name: existingUser?.name ?? user.displayName ?? '',
        photoUrl: existingUser?.photoUrl ?? user.photoURL,
        points: existingUser?.points ?? 0,
        createdAt: existingUser?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        achievements: existingUser?.achievements ?? [],
        preferences: existingUser?.preferences ?? {'isFirstTimeUser': true},
        isActive: existingUser?.isActive ?? true,
        gender: gender,
        dateOfBirth: dateOfBirth,
        phone: phone,
        age: age,
        totalPointsEarned: existingUser?.totalPointsEarned ?? 0,
        favoriteTrackIds: existingUser?.favoriteTrackIds ?? [],
        emailVerified: existingUser?.emailVerified ?? user.emailVerified,
        uid: userId,
      );

      print('💾 AuthRepository: Saving updated user profile to Firestore...');
      print(
        '📊 AuthRepository: Updated user data: ${updatedUser.toFirestore()}',
      );

      try {
        // Save complete updated profile to Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .set(updatedUser.toFirestore())
            .timeout(const Duration(seconds: 10));

        print(
          '✅ AuthRepository: User profile successfully updated in Firestore',
        );
        return updatedUser;
      } catch (firestoreError) {
        print(
          '❌ AuthRepository: Error saving updated user profile to Firestore: $firestoreError',
        );
        print('🔄 AuthRepository: Returning user model without Firestore save');
        // Return user model even if Firestore save fails
        return updatedUser;
      }
    } on FirebaseAuthException catch (e) {
      print(
        '❌ AuthRepository: FirebaseAuthException during update: ${e.code} - ${e.message}',
      );
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('❌ AuthRepository: General exception during update: $e');
      throw Exception('User profile update failed. Please try again.');
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

      // Perform authentication but don't use the credential response directly
      await _firebaseAuth.signInWithCredential(credential);

      // Wait a moment for Firebase Auth to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Get current user directly to avoid PigeonUserDetails bug
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Google sign in failed: No user found');

      // Check if user exists in Firestore
      final doc = await _firestore
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
          preferences: {'isFirstTimeUser': true}, // Set first time user flag
          isActive: true,
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toFirestore());

        return userModel;
      }
    } catch (e) {
      // Check if this is the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print(
          '🔄 AuthRepository: Detected PigeonUserDetails error in Google Sign In, using currentUser workaround',
        );

        // Try to get current user as a workaround
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          print(
            '✅ AuthRepository: Google Sign In workaround successful, user found: ${user.uid}',
          );

          // Check if user exists in Firestore
          try {
            final doc = await _firestore
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
                preferences: {'isFirstTimeUser': true},
                isActive: true,
              );

              await _firestore
                  .collection(AppConstants.usersCollection)
                  .doc(user.uid)
                  .set(userModel.toFirestore());

              return userModel;
            }
          } catch (firestoreError) {
            print(
              '⚠️ AuthRepository: Workaround: Could not access Firestore: $firestoreError',
            );
            // Return basic user model
            return UserModel(
              id: user.uid,
              email: user.email ?? '',
              name: user.displayName ?? '',
              photoUrl: user.photoURL,
              points: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              achievements: [],
              preferences: {'isFirstTimeUser': true},
              isActive: true,
            );
          }
        }
      }
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
