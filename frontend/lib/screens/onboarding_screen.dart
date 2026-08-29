import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleanpixel_ai/screens/workspace_screen.dart';

import 'package:cleanpixel_ai/screens/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _slideAnimController;
  late AnimationController _buttonShimmerController;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.auto_fix_high_rounded,
      'gradient': [Color(0xFF38BDF8), Color(0xFF2563EB)],
      'title': 'AI Watermark Remover',
      'subtitle': 'Brush over any text, copyright stamp or TikTok logo and watch it vanish in 1-tap.',
      'badge': 'NEURAL INPAINTING'
    },
    {
      'icon': Icons.person_remove_rounded,
      'gradient': [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      'title': 'Magic Object & People Eraser',
      'subtitle': 'Erase photobombers, wires, power lines, and clutter with zero blur and pure clarity.',
      'badge': 'DEEP DIFFUSION'
    },
    {
      'icon': Icons.hd_rounded,
      'gradient': [Color(0xFF10B981), Color(0xFF0284C7)],
      'title': 'Lossless 4K Ultra-HD Export',
      'subtitle': 'Save your cleaned photos in original pristine resolution without compression loss.',
      'badge': '4K MASTERWORK'
    },
  ];

  @override
  void initState() {
    super.initState();
    _slideAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _buttonShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _slideAnimController.dispose();
    _buttonShimmerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int idx) {
    setState(() => _currentPage = idx);
    _slideAnimController.reset();
    _slideAnimController.forward();
    HapticFeedback.selectionClick();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
                          ),
                        ),
                        child: const Icon(Icons.auto_fix_high_rounded, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CleanPixel AI',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // Main Carousel View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return AnimatedBuilder(
                    animation: _slideAnimController,
                    builder: (context, _) {
                      final iconScale = Tween<double>(begin: 0.3, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _slideAnimController,
                          curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
                        ),
                      ).value;
                      final iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _slideAnimController,
                          curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                        ),
                      ).value;
                      final badgeSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
                        CurvedAnimation(
                          parent: _slideAnimController,
                          curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
                        ),
                      ).value;
                      final titleSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
                        CurvedAnimation(
                          parent: _slideAnimController,
                          curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
                        ),
                      ).value;
                      final titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _slideAnimController,
                          curve: const Interval(0.35, 0.6, curve: Curves.easeOut),
                        ),
                      ).value;
                      final subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _slideAnimController,
                          curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
                        ),
                      ).value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Floating Particles behind icon
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ambient glow
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (slide['gradient'][0] as Color).withOpacity(0.25 * iconOpacity),
                                          blurRadius: 60,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Icon Circle
                                  Opacity(
                                    opacity: iconOpacity,
                                    child: Transform.scale(
                                      scale: iconScale,
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: slide['gradient'] as List<Color>,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (slide['gradient'][0] as Color).withOpacity(0.4),
                                              blurRadius: 32,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: Icon(slide['icon'] as IconData, size: 64, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Pill Badge - slides in from right
                            Transform.translate(
                              offset: Offset(badgeSlide, 0),
                              child: Opacity(
                                opacity: titleOpacity,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Text(
                                    slide['badge'],
                                    style: TextStyle(
                                      color: slide['gradient'][0] as Color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title - slides up
                            Transform.translate(
                              offset: Offset(0, titleSlide),
                              child: Opacity(
                                opacity: titleOpacity,
                                child: Text(
                                  slide['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Subtitle - fades in
                            Opacity(
                              opacity: subtitleOpacity,
                              child: Text(
                                slide['subtitle'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Pagination Dots & CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
              child: Column(
                children: [
                  // Animated Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (idx) {
                      final isActive = idx == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: isActive
                              ? LinearGradient(
                                  colors: _slides[_currentPage]['gradient'] as List<Color>,
                                )
                              : null,
                          color: isActive ? null : Colors.white.withOpacity(0.15),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Action Button with shimmer
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final isLast = _currentPage == _slides.length - 1;
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      child: AnimatedBuilder(
        animation: _buttonShimmerController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isLast
                    ? [const Color(0xFF10B981), const Color(0xFF0284C7)]
                    : [const Color(0xFF38BDF8), const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isLast ? const Color(0xFF10B981) : const Color(0xFF2563EB)).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (_currentPage < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLast ? "Get Started" : "Continue",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
