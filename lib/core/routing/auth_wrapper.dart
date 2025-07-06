import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../page/welcome.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mood/presentation/pages/mood_input_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Check if email is verified
          if (!user.emailVerified) {
            // Redirect to welcome page for unverified users
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/welcome-page');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Check if user is new and needs to input mood
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final isFirstTimeUser = userData['isFirstTimeUser'] ?? false;

                if (isFirstTimeUser) {
                  // Update user to mark as not first time and redirect to mood input
                  _markUserAsReturning(user.uid);
                  return const MoodInputPage();
                }
              }

              return const HomePage();
            },
          );
        }

        // Redirect to welcome page for unauthenticated users
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/welcome-page');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<void> _markUserAsReturning(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isFirstTimeUser': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error silently
    }
  }
}
