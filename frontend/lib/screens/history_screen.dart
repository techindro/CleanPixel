import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onOpenStudio;

  const HistoryScreen({Key? key, this.onOpenStudio}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final list = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String id) async {
    HapticFeedback.mediumImpact();
    await HistoryService.deleteItem(id);
    _loadHistory();
  }

  void _showPreviewModal(HistoryItem item) {
    HapticFeedback.lightImpact();
    final file = File(item.filePath);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF131C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image View
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  if (file.existsSync())
                    Image.file(file, height: 280, width: double.infinity, fit: BoxFit.contain)
                  else
                    Container(
                      height: 200,
                      color: isDark ? Colors.black26 : const Color(0xFFF0F9FF),
                      child: const Center(child: Icon(Icons.broken_image_rounded, color: Color(0xFF2563EB), size: 40)),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('CLEANED 4K', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.mode,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTimestamp(item.timestamp),
                        style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteItem(item.id);
                          },
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                          label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8)]),
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.all(16),
                                  content: const Text('Saved to Gallery!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                            label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Creation History',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const Text(
              'Your cleaned photos & 4K exports',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
            ),
          ],
        ),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 22),
              tooltip: 'Clear All History',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF131C2E) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: Text('Clear All History?', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A))),
                    content: Text('This will delete all locally cached exports.', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B)))),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await HistoryService.clearAll();
                  _loadHistory();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : _items.isEmpty
              ? _buildEmptyState(isDark)
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  color: const Color(0xFF2563EB),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final file = File(item.filePath);
                      return GestureDetector(
                        onTap: () => _showPreviewModal(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131C2E) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: file.existsSync()
                                      ? Image.file(file, width: double.infinity, fit: BoxFit.cover)
                                      : Container(
                                          color: isDark ? Colors.black26 : const Color(0xFFF0F9FF),
                                          child: const Center(
                                            child: Icon(Icons.broken_image_rounded, color: Color(0xFF2563EB), size: 30),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.mode,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatTimestamp(item.timestamp),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8)]),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.35), blurRadius: 24, spreadRadius: 4),
                ],
              ),
              child: const Icon(Icons.auto_fix_high_rounded, size: 42, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Creations Yet',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your cleaned photos and watermark-free exports will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.onOpenStudio != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8)]),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 4)),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: widget.onOpenStudio,
                  icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 20),
                  label: const Text('Open Inpaint Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day}/${dt.month}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
