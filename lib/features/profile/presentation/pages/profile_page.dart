import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_navigation.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        context.go('/auth');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to logout. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.displayName?.isNotEmpty == true
                          ? user!.displayName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(
                    user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email
                  Text(
                    user?.email ?? 'No email',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: AppColors.primary,
                    ),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/help-support');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      context.push('/privacy-policy');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // App Version
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentRoute: '/profile'),
    );
  }
}
