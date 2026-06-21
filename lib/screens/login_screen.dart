import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password tidak boleh kosong.'),
          backgroundColor: AppColors.accentOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final creds = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (creds != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Gagal masuk. Silakan coba kembali.';
        if (e is FirebaseAuthException) {
          errorMsg = e.message ?? e.toString();
        } else {
          errorMsg = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.accentOrange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                color: AppColors.sageMedium.withOpacity(0.4),
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
                color: AppColors.sageDark.withOpacity(0.2),
              ),
            ),
          ),

          // Star decorations
          _buildStar(50, 220, 16),
          _buildStar(MediaQuery.of(context).size.width - 50, 280, 12),
          _buildStar(30, 350, 10),

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
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Header with brain mascot
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back! 👋',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Sign In to Your\nPeaceful Mind',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CustomPaint(
                              painter: MiniMascotPainter(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Login card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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

                            const SizedBox(height: 20),

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
                              hint: 'Enter your password',
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

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.sageDark,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Login button
                            GestureDetector(
                              onTap: _isLoading ? null : _handleLogin,
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
                                    'Sign In',
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

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.textDark.withOpacity(0.15),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.textDark.withOpacity(0.15),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Social login buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => _isLoading = true);
                                final creds = await _authService.signInWithGoogle();
                                setState(() => _isLoading = false);
                                if (creds != null && mounted) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              },
                              child: _buildSocialButton(
                                label: 'Google',
                                emoji: '🔵',
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => _isLoading = true);
                                final creds = await _authService.signInWithApple();
                                setState(() => _isLoading = false);
                                if (creds != null && mounted) {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              },
                              child: _buildSocialButton(
                                label: 'Apple',
                                emoji: '🍎',
                                color: AppColors.darkButton,
                                textColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Sign up link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/signup'),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
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
        color: AppColors.backgroundGreen.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sageMedium.withOpacity(0.5),
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

  Widget _buildSocialButton({
    required String label,
    required String emoji,
    required Color color,
    Color textColor = AppColors.textDark,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: color == Colors.white
            ? Border.all(
          color: AppColors.sageMedium.withOpacity(0.5),
          width: 1.5,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStar(double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: CustomPaint(
        painter: _StarPainter(color: Colors.white.withOpacity(0.7)),
        size: Size(size, size),
      ),
    );
  }
}

class MiniMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Body
    final bodyPaint = Paint()..color = const Color(0xFFD4A0A0);
    canvas.drawCircle(Offset(cx, cy), 32, bodyPaint);

    // Bumps
    final bumpPaint = Paint()..color = const Color(0xFFC49090);
    canvas.drawCircle(Offset(cx - 14, cy - 18), 14, bumpPaint);
    canvas.drawCircle(Offset(cx + 14, cy - 18), 14, bumpPaint);
    canvas.drawCircle(Offset(cx, cy), 30, bodyPaint);

    // Blush
    final blushPaint = Paint()..color = const Color(0xFFE87878).withOpacity(0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 14, cy + 8), width: 12, height: 7),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 14, cy + 8), width: 12, height: 7),
      blushPaint,
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 9, cy - 4), width: 12, height: 14),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 9, cy - 4), width: 12, height: 14),
      eyePaint,
    );
    final pupilPaint = Paint()..color = const Color(0xFF5A3060);
    canvas.drawCircle(Offset(cx - 9, cy - 3), 5, pupilPaint);
    canvas.drawCircle(Offset(cx + 9, cy - 3), 5, pupilPaint);
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx - 7, cy - 5), 2, shinePaint);
    canvas.drawCircle(Offset(cx + 11, cy - 5), 2, shinePaint);

    // Smile
    final smilePaint = Paint()
      ..color = const Color(0xFFE85858)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(cx - 8, cy + 10);
    path.quadraticBezierTo(cx, cy + 16, cx + 8, cy + 10);
    canvas.drawPath(path, smilePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;
      final radius = i % 2 == 0 ? r : r * 0.4;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
