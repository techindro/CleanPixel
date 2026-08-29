import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/screens/workspace_screen.dart';
import 'package:cleanpixel_ai/screens/tools_hub_screen.dart';
import 'package:cleanpixel_ai/screens/history_screen.dart';
import 'package:cleanpixel_ai/screens/settings_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({Key? key}) : super(key: key);

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _currentIndex = 0;

  void _navigateToStudio() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> screens = [
      const WorkspaceScreen(),
      ToolsHubScreen(onSelectTool: (mode) {
        _navigateToStudio();
      }),
      HistoryScreen(onOpenStudio: _navigateToStudio),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0715) : const Color(0xFFFAF5FF),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B0C24) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFCE7F3),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0xFFEC4899).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.auto_fix_high_rounded, 'Studio'),
                _buildNavItem(1, Icons.category_rounded, 'AI Suite'),
                _buildNavItem(2, Icons.collections_rounded, 'Recents'),
                _buildNavItem(3, Icons.person_rounded, 'Account'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEC4899).withValues(alpha: isDark ? 0.2 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected && !isDark
              ? Border.all(color: const Color(0xFFFCE7F3), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFEC4899) : const Color(0xFF94A3B8),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFEC4899)
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
