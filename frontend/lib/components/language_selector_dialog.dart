import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/services/locale_service.dart';

class LanguageSelectorDialog extends StatefulWidget {
  const LanguageSelectorDialog({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }

  @override
  State<LanguageSelectorDialog> createState() => _LanguageSelectorDialogState();
}

class _LanguageSelectorDialogState extends State<LanguageSelectorDialog> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentCode = LocaleService.currentLocale.value;

    final filteredList = LocaleService.supportedLanguages.where((lang) {
      final matchesSearch = lang.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lang.nativeName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          (_selectedCategory == 'Global' && lang.region == 'Global') ||
          (_selectedCategory == 'Indian' && lang.region == 'India');
      return matchesSearch && matchesCategory;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B0C24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFCE7F3),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : const Color(0xFFEC4899).withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.translate_rounded, color: Color(0xFFEC4899), size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select App Language',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '22 Indian & International Languages Supported',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF110817) : const Color(0xFFFDF2F8),
              hintText: 'Search language / भाषा खोजें...',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFEC4899), size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFCE7F3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFCE7F3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEC4899), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips
          Row(
            children: [
              _buildCategoryChip('All (22)', isDark),
              const SizedBox(width: 8),
              _buildCategoryChip('Global (10)', isDark, categoryKey: 'Global'),
              const SizedBox(width: 8),
              _buildCategoryChip('Indian (12)', isDark, categoryKey: 'Indian'),
            ],
          ),
          const SizedBox(height: 12),

          // Language List
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final lang = filteredList[index];
                final isSelected = lang.code == currentCode;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEC4899).withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF110817) : Colors.white),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFEC4899)
                          : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFFCE7F3)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isDark || isSelected
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFFEC4899).withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        await LocaleService.setLanguage(lang.code);
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEC4899).withValues(alpha: 0.2)
                                    : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFFDF2F8)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFEC4899)
                                      : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFFCE7F3)),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                lang.flag,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.nativeName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFFEC4899)
                                          : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '${lang.name} • ${lang.region}',
                                    style: TextStyle(
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFEC4899),
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isDark, {String? categoryKey}) {
    final key = categoryKey ?? 'All';
    final isSelected = _selectedCategory == key;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCategory = key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEC4899).withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark ? const Color(0xFF110817) : const Color(0xFFFDF2F8)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFEC4899)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFCE7F3)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFEC4899)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
