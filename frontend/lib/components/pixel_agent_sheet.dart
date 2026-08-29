import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cleanpixel_ai/services/agentic_ai_service.dart';

class PixelAgentSheet extends StatefulWidget {
  final Size canvasSize;
  final Function(List<Rect> targetBoxes, String agentMessage) onAgentAction;

  const PixelAgentSheet({
    Key? key,
    required this.canvasSize,
    required this.onAgentAction,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required Size canvasSize,
    required Function(List<Rect> targetBoxes, String agentMessage) onAgentAction,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PixelAgentSheet(
        canvasSize: canvasSize,
        onAgentAction: onAgentAction,
      ),
    );
  }

  @override
  State<PixelAgentSheet> createState() => _PixelAgentSheetState();
}

class _PixelAgentSheetState extends State<PixelAgentSheet> {
  final TextEditingController _promptController = TextEditingController();
  bool _isProcessing = false;
  String? _agentStatus;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _handleAutoScan() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _agentStatus = "Scanning image neural contours & text OCR...";
    });

    final artifacts = await AgenticAiService.autoDetectArtifacts(imageSize: widget.canvasSize);

    setState(() {
      _isProcessing = false;
      _agentStatus = "Found ${artifacts.length} target regions! Applying autonomous masks...";
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.pop(context);

    widget.onAgentAction(
      artifacts.map((e) => e.boundingBox).toList(),
      "PixelAgent auto-targeted ${artifacts.length} watermarks and logos.",
    );
  }

  Future<void> _handleCustomPrompt(String prompt) async {
    if (prompt.trim().isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _agentStatus = "Interpreting prompt with Vision LLM...";
    });

    final response = await AgenticAiService.executeAgentCommand(
      prompt: prompt,
      imageSize: widget.canvasSize,
    );

    setState(() {
      _isProcessing = false;
      _agentStatus = response;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pop(context);

    final w = widget.canvasSize.width > 0 ? widget.canvasSize.width : 360.0;
    final h = widget.canvasSize.height > 0 ? widget.canvasSize.height : 500.0;

    final targetBoxes = [
      Rect.fromLTWH(w * 0.5, h * 0.8, w * 0.45, h * 0.15),
    ];

    widget.onAgentAction(targetBoxes, response);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
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
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 18),

          // Agent Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFFEC4899)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'PixelAgent Copilot',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            color: Color(0xFFEC4899),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'AI helper to remove watermarks and objects',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1-Tap Autonomous Action Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? const Color(0xFF110817) : const Color(0xFFFDF2F8),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFCE7F3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isProcessing ? null : _handleAutoScan,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                        ),
                        child: const Icon(Icons.radar_rounded, color: Color(0xFFEC4899), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto-Remove All Watermarks',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'AI automatically finds and marks watermarks for you',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFFEC4899), size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Agent Prompt Ideas Chips
          Text(
            'OR TAP AN OPTION BELOW',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPromptChip('Erase bottom watermark', isDark),
              _buildPromptChip('Remove copyright logo', isDark),
              _buildPromptChip('Erase person in background', isDark),
              _buildPromptChip('Clean timestamps & subtitles', isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Natural Language Input Box
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promptController,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? const Color(0xFF110817) : const Color(0xFFFDF2F8),
                    hintText: 'e.g. Remove logo on top right...',
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFEC4899), size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  onSubmitted: _handleCustomPrompt,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isProcessing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  onPressed: _isProcessing ? null : () => _handleCustomPrompt(_promptController.text),
                ),
              ),
            ],
          ),

          if (_agentStatus != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_rounded, color: Color(0xFFEC4899), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _agentStatus!,
                      style: const TextStyle(color: Color(0xFFEC4899), fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _promptController.text = text;
        _handleCustomPrompt(text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF110817) : const Color(0xFFFDF2F8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFCE7F3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFEC4899), size: 12),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
