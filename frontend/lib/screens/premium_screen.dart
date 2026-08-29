import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> with TickerProviderStateMixin {
  int _selectedPlan = 0;
  late AnimationController _auroraController;
  late AnimationController _enterController;

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.all_inclusive_rounded, 'text': 'Unlimited 4K Inpaints'},
    {'icon': Icons.videocam_rounded, 'text': 'Deep Diffusion Video Mode'},
    {'icon': Icons.speed_rounded, 'text': 'Priority GPU Queue'},
    {'icon': Icons.hide_image_rounded, 'text': 'No Watermark on Exports'},
    {'icon': Icons.science_rounded, 'text': 'Early Access to New Models'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_auroraController, _enterController]),
        builder: (context, _) {
          return Stack(
            children: [
              // Aurora background glow
              Positioned(
                top: -100 + (_auroraController.value * 30),
                left: -60,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50 - (_auroraController.value * 20),
                right: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFEC4899).withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100 + (_auroraController.value * 40),
                left: 40,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFF59E0B).withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    // Crown with glow halo
                    _buildAnimatedElement(0.0, 0.3, child: _buildCrownIcon()),
                    const SizedBox(height: 20),

                    // Title
                    _buildAnimatedElement(0.1, 0.4, child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFBBF24), Color(0xFFF472B6), Color(0xFFA78BFA)],
                      ).createShader(bounds),
                      child: const Text(
                        'Unlock CleanPixel PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                    )),
                    const SizedBox(height: 8),

                    _buildAnimatedElement(0.15, 0.45, child: const Text(
                      'Unlimited power for professional creators',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    )),
                    const SizedBox(height: 28),

                    // Feature list
                    ...List.generate(_features.length, (i) {
                      final f = _features[i];
                      return _buildAnimatedElement(
                        0.2 + (i * 0.06),
                        0.5 + (i * 0.06),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(f['icon'] as IconData, color: const Color(0xFF38BDF8), size: 18),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                f['text'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Plan Cards
                    _buildAnimatedElement(0.5, 0.8, child: Column(
                      children: [
                        _buildPlanCard(
                          index: 0,
                          title: 'Annual Pro',
                          price: '\$4.99/mo',
                          billing: 'Billed annually (\$59.88/yr)',
                          savings: 'SAVE 50%',
                        ),
                        const SizedBox(height: 12),
                        _buildPlanCard(
                          index: 1,
                          title: 'Monthly Creator',
                          price: '\$9.99/mo',
                          billing: 'Billed monthly, cancel anytime',
                        ),
                      ],
                    )),

                    const SizedBox(height: 28),

                    // CTA Button
                    _buildAnimatedElement(0.6, 0.9, child: _buildCtaButton()),

                    const SizedBox(height: 12),
                    const Text(
                      '7-day free trial • Cancel anytime',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedElement(double begin, double end, {required Widget child}) {
    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Interval(begin, end, curve: Curves.easeOut)),
    ).value;
    final slide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _enterController, curve: Interval(begin, end, curve: Curves.easeOutCubic)),
    ).value;

    return Transform.translate(
      offset: Offset(0, slide),
      child: Opacity(opacity: opacity, child: child),
    );
  }

  Widget _buildCrownIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.35),
            blurRadius: 32,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.2),
            blurRadius: 48,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Icon(Icons.workspace_premium_rounded, size: 40, color: Colors.white),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String billing,
    String? savings,
  }) {
    final isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withOpacity(0.06),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.15), blurRadius: 20, spreadRadius: 2)]
              : [],
        ),
        child: Row(
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF64748B),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF38BDF8) : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (savings != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF0284C7)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            savings,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(billing, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                content: const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Welcome to CleanPixel PRO!', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
            Navigator.pop(context);
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Start 7-Day Free Trial',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
