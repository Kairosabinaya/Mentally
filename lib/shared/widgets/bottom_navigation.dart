import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavigation({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, 'Home', '/home', context),
              _buildBottomNavItem(
                Icons.people_outline,
                'Community',
                '/community',
                context,
              ),
              _buildBottomNavItem(
                Icons.person_outline,
                'Profile',
                '/profile',
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    String route,
    BuildContext context,
  ) {
    final isSelected = currentRoute == route;

    return InkWell(
      onTap: () {
        // Force navigation even if on same route
        context.go(route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
