import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Semua kolom wajib diisi.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Password dan konfirmasi password tidak cocok.');
      return;
    }

    if (password.length < 6) {
      _showError('Password minimal harus 6 karakter.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final creds = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      if (creds != null && mounted) {
        // Pendaftaran berhasil, langsung masuk ke Home
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Gagal mendaftar. Silakan coba kembali.';
        if (e is FirebaseAuthException) {
          errorMsg = e.message ?? e.toString();
        } else {
          errorMsg = e.toString();
        }
        _showError(errorMsg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.accentOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: Stack(
        children: [
          // Background decorative shapes
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sageMedium.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sageDark.withValues(alpha: 0.2),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Create Account ✨',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Mulai perjalanan damaimu bersama kami',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Sign Up card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name field
                            const Text(
                              'Full Name',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _nameController,
                              hint: 'Enter your name',
                              icon: Icons.person_outline_rounded,
                            ),

                            const SizedBox(height: 18),

                            // Email field
                            const Text(
                              'Email Address',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'your@email.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 18),

                            // Password field
                            const Text(
                              'Password',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Min. 6 characters',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textGrey,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Confirm Password field
                            const Text(
                              'Confirm Password',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textGrey,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hint: 'Re-enter your password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscureConfirmPassword,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                                child: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textGrey,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Sign Up button
                            GestureDetector(
                              onTap: _isLoading ? null : _handleSignUp,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.darkButton,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontFamily: 'Fredoka',
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Link back to Login
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.sageDeep,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.sageDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sageMedium.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 15,
            color: AppColors.textLight,
          ),
          prefixIcon: Icon(icon, color: AppColors.sageDark, size: 20),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
