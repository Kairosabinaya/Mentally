import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../shared/widgets/custom_text_field.dart';
import '../shared/widgets/loading_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Login Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();

  // Register Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDateOfBirth;

  // Form Keys
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  // Selected values
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _loginEmailController.text.trim(),
            password: _loginPasswordController.text.trim(),
          );

      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          _showSnackBar(
            'Please verify your email before logging in. Check your inbox.',
            isError: true,
          );
          await FirebaseAuth.instance.signOut();
          return;
        }

        _showSnackBar('Login successful!');
        if (mounted) {
          context.go('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
        default:
          message = 'Login failed. Please try again.';
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred.', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      // Create user account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Send email verification
        await user.sendEmailVerification();

        // Update display name
        await user.updateDisplayName(_nameController.text.trim());

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'dateOfBirth':
              _selectedDateOfBirth != null
                  ? Timestamp.fromDate(_selectedDateOfBirth!)
                  : null,
          'age':
              _selectedDateOfBirth != null
                  ? DateTime.now().year - _selectedDateOfBirth!.year
                  : 0,
          'gender': _selectedGender ?? '',
          'photoUrl': null,
          'points': 0,
          'isFirstTimeUser': true,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _showSnackBar(
          'Registration successful! Please check your email for verification link.',
        );

        // Clear form
        _clearRegisterForm();

        // Switch to login tab
        _tabController.animateTo(0);

        // Start listening for email verification
        _startEmailVerificationListener(user);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        default:
          message = 'Registration failed. Please try again.';
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      _showSnackBar('An unexpected error occurred.', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  void _clearRegisterForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _dobController.clear();
    _selectedDateOfBirth = null;
    setState(() {
      _selectedGender = null;
    });
  }

  void _startEmailVerificationListener(User user) {
    // Poll for email verification every 3 seconds
    Stream.periodic(const Duration(seconds: 3)).listen((event) async {
      await user.reload();
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.emailVerified) {
        // Update user verification status in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
              'emailVerified': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        _showSnackBar('Email verified! Welcome to Mentally!');

        if (mounted) {
          // This will trigger the AuthWrapper to redirect to mood input for new users
          context.go('/');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF6366F1)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // App logo and title
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.psychology,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Welcome to Mentally',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Your mental health journey starts here',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                // Content area
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Tab bar
                        Container(
                          margin: const EdgeInsets.all(24),
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.primary,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: const EdgeInsets.all(4),
                            labelColor: Colors.white,
                            unselectedLabelColor: AppColors.textSecondary,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                            tabs: const [
                              Tab(text: 'Sign In'),
                              Tab(text: 'Sign Up'),
                            ],
                          ),
                        ),

                        // Tab content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [_buildLoginTab(), _buildRegisterTab()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            LoadingOverlay(isLoading: _isLoading, child: Container()),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Sign in to continue your mental health journey',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 32),

            // Email field
            CustomTextField(
              label: 'Email Address',
              hint: 'Enter your email',
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password field
            CustomTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _loginPasswordController,
              obscureText: !_isPasswordVisible,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Forgot password
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Join our community and start your wellness journey',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 32),

            // Name field
            CustomTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameController,
              prefixIcon: Icons.person_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email field
            CustomTextField(
              label: 'Email Address',
              hint: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Phone field
            CustomTextField(
              label: 'Phone Number',
              hint: 'Enter your phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Age and Gender row
            Row(
              children: [
                // Date of Birth field
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(
                          const Duration(days: 365 * 20),
                        ),
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365 * 100),
                        ),
                        lastDate: DateTime.now().subtract(
                          const Duration(days: 365 * 13),
                        ),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: AppColors.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateOfBirth = picked;
                          _dobController.text =
                              "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: CustomTextField(
                        label: 'Date of Birth',
                        hint: 'DD/MM/YYYY',
                        controller: _dobController,
                        prefixIcon: Icons.calendar_today_outlined,
                        validator: (value) {
                          if (_selectedDateOfBirth == null) {
                            return 'Date of birth is required';
                          }
                          final age =
                              DateTime.now().year - _selectedDateOfBirth!.year;
                          if (age < 13) {
                            return 'You must be at least 13 years old';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Gender dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gender',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          hintText: 'Select gender',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 16,
                          ),
                        ),
                        icon: Container(),
                        iconSize: 0,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        dropdownColor: Colors.white,
                        items:
                            _genderOptions.map((String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select gender';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Password field
            CustomTextField(
              label: 'Password',
              hint: 'Create a strong password',
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(
                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                ).hasMatch(value)) {
                  return 'Password must contain uppercase, lowercase, and number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Confirm password field
            CustomTextField(
              label: 'Confirm Password',
              hint: 'Confirm your password',
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              prefixIcon: Icons.lock_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Register button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Terms and privacy
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
