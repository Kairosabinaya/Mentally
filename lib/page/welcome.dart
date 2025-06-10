import 'package:flutter/material.dart';
import 'package:mentally/page/auth.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Enhanced color palette matching home page
  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _lightBackground = Color(0xFFFAFBFF);
  static const Color _surfaceWhite = Colors.white;
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _softPink = Color(0xFFFDF2F8);

  void navigateToLogin(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Logo/Icon - using brain image
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: _softPink,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Image(
                    image: AssetImage('images/icon.png'),
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // App Title
              Text(
                'Mentally',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Your mental wellness companion',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _textGray,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Take care of your mental health with guided meditation, mood tracking, and AI-powered support',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: _textGray, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryPurple, _primaryBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => navigateToLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _surfaceWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
