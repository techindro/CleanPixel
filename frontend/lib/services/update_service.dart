import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppUpdateInfo {
  final String latestVersion;
  final int latestBuildNumber;
  final String releaseNotes;
  final String downloadUrl;
  final bool isMandatory;

  AppUpdateInfo({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.releaseNotes,
    required this.downloadUrl,
    this.isMandatory = false,
  });
}

class UpdateService {
  static const String currentVersion = "2.6.0";
  static const int currentBuildNumber = 103;

  /// Check for latest OTA version update
  static Future<AppUpdateInfo?> checkForUpdate() async {
    // Simulated remote version check endpoint
    await Future.delayed(const Duration(milliseconds: 800));

    // Remote server payload simulation
    return AppUpdateInfo(
      latestVersion: "2.6.0",
      latestBuildNumber: 103,
      releaseNotes: "• 22-Language Multi-Lingual Engine\n• Mobile Number OTP Authentication\n• Over-The-Air Seamless Update Channel\n• Lossless 4K Master Neural Inpainter",
      downloadUrl: "http://192.168.31.210:8080/CleanPixel_AI.apk",
      isMandatory: false,
    );
  }

  /// Display Google Play style In-App Update Sheet
  static void showUpdateDialog(BuildContext context, AppUpdateInfo info) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.system_update_rounded, color: Color(0xFF38BDF8), size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CleanPixel AI Update',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Version ${info.latestVersion} is ready to install',
                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'WHAT\'S NEW IN THIS UPDATE',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(
                info.releaseNotes,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
                  ),
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF10B981),
                        content: const Row(
                          children: [
                            Icon(Icons.downloading_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Downloading update package in background...'),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text(
                    'Download & Install Update Now',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
