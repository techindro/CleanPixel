import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      'gradient': const [Color(0xFF38BDF8), Color(0xFF2563EB)],
      'title': 'AI Watermark Remover',
      'subtitle': 'Brush over any text, copyright stamp or TikTok logo and watch it vanish in 1-tap.',
      'badge': 'NEURAL INPAINTING'
    },
    {
      'icon': Icons.person_remove_rounded,
      'gradient': const [Color(0xFF0284C7), Color(0xFF0EA5E9)],
      'title': 'Magic Object & People Eraser',
      'subtitle': 'Erase photobombers, wires, power lines, and clutter with zero blur and pure clarity.',
      'badge': 'DEEP DIFFUSION'
    },
    {
      'icon': Icons.hd_rounded,
      'gradient': const [Color(0xFF10B981), Color(0xFF059669)],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
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
                      Image.asset(
                        'assets/logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.auto_fix_high_rounded,
                          color: Color(0xFF38BDF8),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CleanPixel AI',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final List<Color> gradColors = slide['gradient'] as List<Color>;

                  return AnimatedBuilder(
                    animation: _slideAnimController,
                    builder: (context, _) {
                      final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
                        CurvedAnimation(parent: _slideAnimController, curve: Curves.easeOutCubic),
                      ).value;
                      final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(parent: _slideAnimController, curve: Curves.easeOut),
                      ).value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  width: 170,
                                  height: 170,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: gradColors,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gradColors.first.withValues(alpha: 0.35),
                                        blurRadius: 36,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    slide['icon'] as IconData,
                                    size: 72,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                slide['badge'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            Text(
                              slide['title'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              slide['subtitle'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 14,
                                height: 1.5,
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

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (idx) {
                final isSelected = _currentPage == idx;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _slides.length - 1 ? 'Get Started Free' : 'Continue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
