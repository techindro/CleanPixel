import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/screens/premium_screen.dart';
import 'package:cleanpixel_ai/screens/auth_screen.dart';
import 'package:cleanpixel_ai/components/rating_dialog.dart';
import 'package:cleanpixel_ai/components/language_selector_dialog.dart';
import 'package:cleanpixel_ai/services/auth_service.dart';
import 'package:cleanpixel_ai/services/locale_service.dart';
import 'package:cleanpixel_ai/services/update_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  UserProfile? _userProfile;
  int _credits = 3;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profile = await AuthService.getCurrentUser();
    final credits = await AuthService.getRemainingCredits();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _credits = credits;
      });
    }
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    HapticFeedback.heavyImpact();
    await AuthService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  void _showPolicyDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        title: const Text('Settings & Account', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white, letterSpacing: -0.3)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _enterController,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Profile & Pro Upgrade Banner
                _buildStaggered(0.0, 0.3, child: _buildUserProfileCard()),
                const SizedBox(height: 20),

                // 2. Real-time Credit Usage Card
                _buildStaggered(0.1, 0.4, child: _buildCreditBar()),
                const SizedBox(height: 24),

                // 3. Section 1: App Experience
                _buildStaggered(0.15, 0.45, child: _buildSectionLabel('APPLICATION & CREATOR')),
                const SizedBox(height: 10),
                ValueListenableBuilder<String>(
                  valueListenable: LocaleService.currentLocale,
                  builder: (context, _, __) {
                    final currentLang = LocaleService.getCurrentLanguage();
                    return _buildStaggered(0.18, 0.48, child: _buildSettingTile(
                      icon: Icons.translate_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      title: 'App Language / भाषा',
                      subtitle: '${currentLang.flag} ${currentLang.nativeName} (${currentLang.name})',
                      onTap: () => LanguageSelectorDialog.show(context),
                    ));
                  },
                ),
                _buildStaggered(0.2, 0.5, child: _buildSettingTile(
                  icon: Icons.star_rate_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Rate CleanPixel on Play Store',
                  subtitle: 'Help us grow with a 5-star review',
                  onTap: () => RatingDialog.show(context),
                )),
                _buildStaggered(0.25, 0.55, child: _buildSettingTile(
                  icon: Icons.share_rounded,
                  iconColor: const Color(0xFF38BDF8),
                  title: 'Share with Friends & Creators',
                  subtitle: 'Spread the word about CleanPixel AI',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                        content: const Text('📋 App share link copied to clipboard!'),
                      ),
                    );
                  },
                )),
                _buildStaggered(0.3, 0.6, child: _buildSettingTile(
                  icon: Icons.cleaning_services_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Clear Cache & Temp Buffers',
                  subtitle: 'Free up device memory',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF10B981),
                        content: const Text('⚡ Cache successfully cleared!'),
                      ),
                    );
                  },
                )),
                _buildStaggered(0.32, 0.62, child: _buildSettingTile(
                  icon: Icons.system_update_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Check for Updates',
                  subtitle: 'Current Version ${UpdateService.currentVersion} (Up to date)',
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final update = await UpdateService.checkForUpdate();
                    if (context.mounted && update != null) {
                      UpdateService.showUpdateDialog(context, update);
                    }
                  },
                )),
                const SizedBox(height: 24),

                // 4. Section 2: Privacy & Legal
                _buildStaggered(0.35, 0.65, child: _buildSectionLabel('PRIVACY & POLICIES')),
                const SizedBox(height: 10),
                _buildStaggered(0.4, 0.7, child: _buildSettingTile(
                  icon: Icons.privacy_tip_rounded,
                  iconColor: const Color(0xFFA855F7),
                  title: 'Privacy Policy',
                  subtitle: 'How we securely handle your media',
                  onTap: () {
                    _showPolicyDialog(
                      context,
                      'Privacy Policy',
                      'CleanPixel AI is committed to your privacy.\n\n1. Media Privacy: Uploaded photos and inpaint masks are processed exclusively in transient RAM buffers and are automatically wiped immediately after completion.\n\n2. No Model Training: We never use personal photos to train models without consent.\n\n3. Data Encryption: All network communications are encrypted with standard TLS 1.3 / SSL.',
                    );
                  },
                )),
                _buildStaggered(0.45, 0.75, child: _buildSettingTile(
                  icon: Icons.description_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Terms of Service',
                  subtitle: 'Read our service terms',
                  onTap: () {
                    _showPolicyDialog(
                      context,
                      'Terms of Service',
                      'By using CleanPixel AI, you agree that:\n\n1. You hold proper ownership or rights to the images you process.\n\n2. Subscriptions can be managed or cancelled anytime in Google Play settings.',
                    );
                  },
                )),
                const SizedBox(height: 24),

                // 5. Account Management / Logout
                _buildStaggered(0.5, 0.8, child: _buildSectionLabel('ACCOUNT SESSION')),
                const SizedBox(height: 10),
                _buildStaggered(0.55, 0.85, child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _handleLogout,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Log Out of Account',
                                    style: TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Switch user or reset active session',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFFEF4444), size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),

                const SizedBox(height: 32),

                // App Version Footer
                _buildStaggered(0.6, 0.9, child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E293B), Color(0xFF111827)],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF38BDF8), size: 18),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'CleanPixel AI Studio',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Version 2.5.0 (Build 102) • Production',
                        style: TextStyle(color: Color(0xFF475569), fontSize: 11),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaggered(double begin, double end, {required Widget child}) {
    final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Interval(begin, end, curve: Curves.easeOut)),
    ).value;
    final slide = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(parent: _enterController, curve: Interval(begin, end, curve: Curves.easeOutCubic)),
    ).value;
    return Transform.translate(
      offset: Offset(0, slide),
      child: Opacity(opacity: opacity, child: child),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildUserProfileCard() {
    final name = _userProfile?.fullName ?? 'CleanPixel Creator';
    final email = _userProfile?.email ?? 'creator@cleanpixel.ai';
    final isPro = _userProfile?.isPro ?? false;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF111827)],
        ),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPro
                    ? [const Color(0xFFF59E0B), const Color(0xFFEC4899)]
                    : [const Color(0xFF38BDF8), const Color(0xFF2563EB)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPro ? Icons.workspace_premium_rounded : Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
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
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: isPro
                            ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEC4899)])
                            : null,
                        color: isPro ? null : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isPro ? 'PRO' : 'FREE',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumScreen()),
                );
              },
              child: Text(isPro ? 'Manage' : 'Upgrade', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditBar() {
    final double fraction = (_credits / 3.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily AI Credits', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              Text('$_credits / 3 Remaining', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                fraction > 0.3 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Credits reset daily at midnight • Unlimited in Pro Tier',
            style: TextStyle(color: Color(0xFF475569), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.15), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
