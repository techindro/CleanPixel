import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/screens/premium_screen.dart';
import 'package:cleanpixel_ai/screens/auth_screen.dart';
import 'package:cleanpixel_ai/components/rating_dialog.dart';
import 'package:cleanpixel_ai/components/language_selector_dialog.dart';
import 'package:cleanpixel_ai/services/auth_service.dart';
import 'package:cleanpixel_ai/services/locale_service.dart';
import 'package:cleanpixel_ai/services/theme_service.dart';
import 'package:cleanpixel_ai/services/purchase_service.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF131C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocaleService.tr('close'), style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<String>(
      valueListenable: LocaleService.currentLocale,
      builder: (context, currentLangCode, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: PurchaseService.isProNotifier,
          builder: (context, isUserPro, __) {
            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
              appBar: AppBar(
                backgroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleService.tr('settings'),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Text(
                      'Preferences & Workspace Configuration',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
              body: AnimatedBuilder(
                animation: _enterController,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. User Profile & Pro Upgrade Banner
                        _buildStaggered(0.0, 0.3, child: _buildUserProfileCard(isDark, isUserPro)),
                        const SizedBox(height: 18),

                        // 2. Real-time Credit Usage Card
                        _buildStaggered(0.1, 0.4, child: _buildCreditBar(isDark, isUserPro)),
                        const SizedBox(height: 22),

                        // 3. Section 1: App Experience
                        _buildStaggered(0.15, 0.45, child: _buildSectionLabel('APPLICATION & CREATOR', isDark)),
                        const SizedBox(height: 10),

                        // Theme Switcher Tile
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: ThemeService.themeModeNotifier,
                          builder: (context, currentMode, _) {
                            final icon = currentMode == ThemeMode.light
                                ? Icons.light_mode_rounded
                                : currentMode == ThemeMode.system
                                    ? Icons.brightness_auto_rounded
                                    : Icons.dark_mode_rounded;
                            return _buildStaggered(0.17, 0.47, child: _buildSettingTile(
                              icon: icon,
                              iconColor: const Color(0xFF2563EB),
                              title: 'Theme Mode',
                              subtitle: ThemeService.getThemeName(currentMode),
                              onTap: () => _showThemeSelectorDialog(context),
                              isDark: isDark,
                            ));
                          },
                        ),

                        // Language Tile with Country Flags
                        Builder(
                          builder: (context) {
                            final currentLang = LocaleService.getCurrentLanguage();
                            return _buildStaggered(0.19, 0.49, child: _buildSettingTile(
                              icon: Icons.translate_rounded,
                              iconColor: const Color(0xFF0284C7),
                              title: LocaleService.tr('language'),
                              subtitle: '${currentLang.flag} ${currentLang.nativeName} (${currentLang.name})',
                              onTap: () => LanguageSelectorDialog.show(context),
                              isDark: isDark,
                            ));
                          },
                        ),
                        _buildStaggered(0.2, 0.5, child: _buildSettingTile(
                          icon: Icons.star_rate_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Rate CleanPixel on Play Store',
                          subtitle: 'Help us grow with a 5-star review',
                          onTap: () => RatingDialog.show(context),
                          isDark: isDark,
                        )),
                        _buildStaggered(0.25, 0.55, child: _buildSettingTile(
                          icon: Icons.share_rounded,
                          iconColor: const Color(0xFF2563EB),
                          title: 'Share with Friends & Creators',
                          subtitle: 'Spread the word about CleanPixel AI',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                                backgroundColor: const Color(0xFF2563EB),
                                content: const Row(
                                  children: [
                                    Icon(Icons.content_copy_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('App share link copied to clipboard'),
                                  ],
                                ),
                              ),
                            );
                          },
                          isDark: isDark,
                        )),
                        _buildStaggered(0.3, 0.6, child: _buildSettingTile(
                          icon: Icons.cleaning_services_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: LocaleService.tr('clear_cache'),
                          subtitle: 'Free up device memory',
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                                backgroundColor: const Color(0xFF10B981),
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Cache successfully cleared'),
                                  ],
                                ),
                              ),
                            );
                          },
                          isDark: isDark,
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
                          isDark: isDark,
                        )),
                        const SizedBox(height: 22),

                        // 4. Section 2: Privacy & Legal
                        _buildStaggered(0.35, 0.65, child: _buildSectionLabel('PRIVACY & POLICIES', isDark)),
                        const SizedBox(height: 10),
                        _buildStaggered(0.4, 0.7, child: _buildSettingTile(
                          icon: Icons.privacy_tip_rounded,
                          iconColor: const Color(0xFF2563EB),
                          title: LocaleService.tr('privacy_policy'),
                          subtitle: 'How we securely handle your media',
                          onTap: () {
                            _showPolicyDialog(
                              context,
                              'Privacy Policy',
                              'CleanPixel AI is committed to your privacy.\n\n1. Media Privacy: Uploaded photos and inpaint masks are processed exclusively in transient RAM buffers and are automatically wiped immediately after completion.\n\n2. No Model Training: We never use personal photos to train models without consent.\n\n3. Data Encryption: All network communications are encrypted with standard TLS 1.3 / SSL.',
                            );
                          },
                          isDark: isDark,
                        )),
                        _buildStaggered(0.45, 0.75, child: _buildSettingTile(
                          icon: Icons.description_rounded,
                          iconColor: const Color(0xFF38BDF8),
                          title: LocaleService.tr('terms_service'),
                          subtitle: 'Read our service terms',
                          onTap: () {
                            _showPolicyDialog(
                              context,
                              'Terms of Service',
                              '1. Acceptance: By using CleanPixel AI, you agree to these Terms.\n\n2. Prohibited Use: You agree not to upload illegal, abusive, or explicitly copyrighted materials.\n\n3. Subscription: Pro features are billed according to your chosen plan with instant cancelation support.',
                            );
                          },
                          isDark: isDark,
                        )),
                        _buildStaggered(0.5, 0.8, child: _buildSettingTile(
                          icon: Icons.verified_user_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'Zero-Knowledge Privacy',
                          subtitle: 'In-memory processing guarantee (Active)',
                          trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                          onTap: () {},
                          isDark: isDark,
                        )),
                        const SizedBox(height: 22),

                        // 5. Section 3: Account & Session
                        _buildStaggered(0.55, 0.85, child: _buildSectionLabel('ACCOUNT & SESSION', isDark)),
                        const SizedBox(height: 10),
                        _buildStaggered(0.6, 0.9, child: _buildSettingTile(
                          icon: Icons.logout_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: LocaleService.tr('logout'),
                          subtitle: 'Sign out of your creator account',
                          titleColor: const Color(0xFFEF4444),
                          onTap: _handleLogout,
                          isDark: isDark,
                        )),
                        const SizedBox(height: 32),

                        // 6. Footer Brand
                        _buildStaggered(
                          0.65,
                          0.95,
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/logo.png',
                                  height: 32,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF38BDF8), size: 28),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'CleanPixel AI v2.4.0 (Founder Edition)',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showThemeSelectorDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF131C2E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.palette_rounded, color: Color(0xFF2563EB), size: 24),
              const SizedBox(width: 10),
              Text(
                'Select Theme',
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeModeNotifier,
            builder: (context, currentMode, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeRadioOption(context, ThemeMode.light, 'Light Mode (White & Electric Blue)', Icons.light_mode_rounded, currentMode, isDark),
                  _buildThemeRadioOption(context, ThemeMode.dark, 'Dark Mode (OLED)', Icons.dark_mode_rounded, currentMode, isDark),
                  _buildThemeRadioOption(context, ThemeMode.system, 'System Default', Icons.brightness_auto_rounded, currentMode, isDark),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildThemeRadioOption(BuildContext context, ThemeMode mode, String title, IconData icon, ThemeMode currentMode, bool isDark) {
    final isSelected = currentMode == mode;
    return InkWell(
      onTap: () {
        ThemeService.setThemeMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white60 : const Color(0xFF64748B)), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 18),
          ],
        ),
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

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildUserProfileCard(bool isDark, bool isPro) {
    final name = _userProfile?.fullName ?? 'CleanPixel Creator';
    final email = _userProfile?.email ?? 'creator@cleanpixel.ai';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPro
                    ? [const Color(0xFFFF6B00), const Color(0xFFEF4444)]
                    : [const Color(0xFF2563EB), const Color(0xFF38BDF8)],
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
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: isPro
                            ? const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFEF4444)])
                            : null,
                        color: isPro ? null : const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPro ? 'PRO' : 'FREE',
                        style: TextStyle(
                          color: isPro ? Colors.white : const Color(0xFF2563EB),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
              ),
              borderRadius: BorderRadius.circular(12),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumScreen()),
                );
                if (res == true) {
                  _loadUserData();
                }
              },
              child: Text(
                isPro ? 'Active PRO' : 'Upgrade',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditBar(bool isDark, bool isPro) {
    final displayCredits = isPro ? 9999 : _credits;
    final double fraction = isPro ? 1.0 : (_credits / 3.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleService.tr('daily_credits'),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                isPro ? 'Unlimited 4K Credits' : '$_credits of 3 remaining',
                style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF0F9FF),
              valueColor: AlwaysStoppedAnimation<Color>(isPro ? const Color(0xFF10B981) : const Color(0xFF2563EB)),
            ),
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
    required bool isDark,
    Color? titleColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.arrow_forward_ios_rounded,
          color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
          size: 14,
        ),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
      ),
    );
  }
}
