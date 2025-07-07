import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../page/welcome.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mood/presentation/pages/mood_input_page.dart';
import '../../core/constants/app_constants.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<DocumentSnapshot?> _getUserWithRetry(
    String uid, {
    int maxRetries = 3,
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        print('🔄 AuthWrapper: Attempt ${i + 1} to get user document');
        final doc = await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 10));

        if (doc.exists) {
          print('✅ AuthWrapper: User document found on attempt ${i + 1}');
          return doc;
        } else {
          print('❌ AuthWrapper: User document not found on attempt ${i + 1}');
          if (i < maxRetries - 1) {
            print('⏳ AuthWrapper: Waiting 1 second before retry...');
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      } catch (e) {
        print('❌ AuthWrapper: Error on attempt ${i + 1}: $e');
        if (i < maxRetries - 1) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('🔄 AuthWrapper: Connection state = ${snapshot.connectionState}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ AuthWrapper: Waiting for auth state...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          print('✅ AuthWrapper: User authenticated, ID = ${user.uid}');

          // Use FutureBuilder with retry mechanism
          return FutureBuilder<DocumentSnapshot?>(
            future: _getUserWithRetry(user.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userDoc = userSnapshot.data!;
                final userData = userDoc.data() as Map<String, dynamic>?;

                print('✅ AuthWrapper: User data retrieved successfully');

                // Check if user is first time user
                final isFirstTimeUser =
                    userData?['preferences']?['isFirstTimeUser'] ?? true;

                if (isFirstTimeUser) {
                  print(
                    '🔄 AuthWrapper: First time user, redirecting to mood input',
                  );
                  // Mark user as returning user
                  _markUserAsReturning(user.uid);
                  return const MoodInputPage();
                } else {
                  print('🔄 AuthWrapper: Returning user, redirecting to home');
                  return const HomePage();
                }
              } else {
                print('❌ AuthWrapper: User document not found after retries');
                // If user document doesn't exist, treat as first time user
                return const MoodInputPage();
              }
            },
          );
        }

        print('❌ AuthWrapper: User not authenticated, redirecting to welcome');
        // Redirect to welcome page for unauthenticated users
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/welcome-page');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Future<void> _markUserAsReturning(String uid) async {
    try {
      print('🔄 AuthWrapper: Marking user as returning...');
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
            'preferences.isFirstTimeUser': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      print('✅ AuthWrapper: User marked as returning');
    } catch (e) {
      print('❌ AuthWrapper: Error marking user as returning: $e');
      // Handle error silently
    }
  }
}
