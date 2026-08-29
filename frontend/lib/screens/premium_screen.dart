import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/services/purchase_service.dart';
import 'package:cleanpixel_ai/components/payment_checkout_sheet.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> with TickerProviderStateMixin {
  int _selectedPlan = 0;
  late AnimationController _auroraController;
  late AnimationController _enterController;
  bool _isRestoring = false;

  final List<Map<String, String>> _planDetails = [
    {
      'title': 'Annual Pro Pass',
      'price': '₹1,999 / year',
      'subtext': 'Save 60% (Just ₹166/month)',
      'type': 'yearly',
      'badge': 'BEST VALUE',
    },
    {
      'title': 'Monthly Pro Subscription',
      'price': '₹399 / month',
      'subtext': 'Cancel anytime in Play Store',
      'type': 'monthly',
      'badge': 'FLEXIBLE',
    },
    {
      'title': 'Lifetime Founder Pass',
      'price': '₹4,999',
      'subtext': 'One-time payment • Lifetime access',
      'type': 'lifetime',
      'badge': 'LIFETIME',
    },
  ];

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
    {'icon': Icons.all_inclusive_rounded, 'text': 'Unlimited 4K Neural Inpaints'},
    {'icon': Icons.videocam_rounded, 'text': 'Deep Diffusion Video Tracking'},
    {'icon': Icons.speed_rounded, 'text': 'Priority Ultra-Fast GPU Queue'},
    {'icon': Icons.hide_image_rounded, 'text': 'Zero Watermark on Master Exports'},
    {'icon': Icons.science_rounded, 'text': 'Early Access to New AI Models'},
  ];

  Future<void> _openCheckout() async {
    HapticFeedback.heavyImpact();
    final plan = _planDetails[_selectedPlan];
    final success = await PaymentCheckoutSheet.show(
      context,
      planTitle: plan['title']!,
      planPrice: plan['price']!,
      planType: plan['type']!,
    );

    if (success == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleRestore() async {
    HapticFeedback.mediumImpact();
    setState(() => _isRestoring = true);
    final restored = await PurchaseService.restorePurchases();
    setState(() => _isRestoring = false);

    if (mounted) {
      if (restored) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF10B981),
            content: Text('✅ CleanPixel PRO purchases restored successfully!'),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscriptions found for this account.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFE0F2FE)),
            ),
            child: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isRestoring ? null : _handleRestore,
            child: _isRestoring
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)))
                : const Text('Restore', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_auroraController, _enterController]),
        builder: (context, _) {
          return Stack(
            children: [
              // Aurora background glow
              Positioned(
                top: -80 + (_auroraController.value * 30),
                left: -40,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2563EB).withValues(alpha: isDark ? 0.18 : 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Header Pro Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B00), Color(0xFFEF4444)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'CLEANPIXEL PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Unleash Ultimate AI Power',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Unlimited 4K neural inpainting with zero wait times',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Feature List
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131C2E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        children: _features.map((f) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    f['icon'] as IconData,
                                    size: 16,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  f['text'] as String,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Plans Selector
                    ...List.generate(_planDetails.length, (idx) {
                      final plan = _planDetails[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPlanCard(
                          index: idx,
                          title: plan['title']!,
                          price: plan['price']!,
                          subtext: plan['subtext']!,
                          badge: plan['badge'],
                          isDark: isDark,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Subscribe CTA
                    SizedBox(
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
                              blurRadius: 18,
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
                          onPressed: _openCheckout,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Unlock PRO Access Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'UPI, Google Play, Credit Cards & Net Banking supported. Cancel anytime.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String subtext,
    String? badge,
    required bool isDark,
  }) {
    final isSelected = _selectedPlan == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF131C2E) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: isSelected ? 0.12 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white38 : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B00), Color(0xFFEF4444)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtext,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white : const Color(0xFF0F172A)),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
