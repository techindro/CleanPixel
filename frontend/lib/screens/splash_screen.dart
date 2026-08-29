import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanpixel_ai/screens/home_shell_screen.dart';
import 'package:cleanpixel_ai/screens/onboarding_screen.dart';
import 'package:cleanpixel_ai/screens/auth_screen.dart';
import 'package:cleanpixel_ai/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _ringController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowRadius;
  late Animation<double> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _ringExpand;

  @override
  void initState() {
    super.initState();

    // Main logo entrance
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.25, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.3, 0.55, curve: Curves.easeOutCubic)),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.3, 0.55, curve: Curves.easeOut)),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.45, 0.65, curve: Curves.easeOut)),
    );

    // Glow pulse loop
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowRadius = Tween<double>(begin: 20.0, end: 44.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Ring expand
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _ringExpand = Tween<double>(begin: 0.6, end: 1.8).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _logoController.forward();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
    final isLoggedIn = await AuthService.isLoggedIn();

    Widget target;
    if (!hasCompletedOnboarding) {
      target = const OnboardingScreen();
    } else if (isLoggedIn) {
      target = const HomeShellScreen();
    } else {
      target = const AuthScreen();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => target,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_logoController, _glowController, _ringController]),
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRing(scale: _ringExpand.value * 1.0, opacity: (1.0 - _ringController.value) * 0.08),
                      _buildRing(scale: _ringExpand.value * 0.8, opacity: (1.0 - _ringController.value) * 0.12),
                      _buildRing(scale: _ringExpand.value * 0.6, opacity: (1.0 - _ringController.value) * 0.18),

                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                              blurRadius: _glowRadius.value,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                              blurRadius: _glowRadius.value * 1.5,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),

                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: SizedBox(
                            width: 96,
                            height: 96,
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.auto_fix_high_rounded,
                                size: 64,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Transform.translate(
                  offset: Offset(0, _titleSlide.value),
                  child: Opacity(
                    opacity: _titleOpacity.value,
                    child: const Text(
                      'CleanPixel AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFF43F5E), Color(0xFFFB7185)],
                    ).createShader(bounds),
                    child: const Text(
                      'Neural Watermark & Object Remover',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRing({required double scale, required double opacity}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: opacity.clamp(0.0, 1.0)),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
