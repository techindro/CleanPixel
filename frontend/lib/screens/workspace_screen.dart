import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cleanpixel_ai/components/interactive_canvas.dart';
import 'package:cleanpixel_ai/components/contextual_toolbar.dart';
import 'package:cleanpixel_ai/components/comparison_slider.dart';
import 'package:cleanpixel_ai/components/paywall_badge.dart';
import 'package:cleanpixel_ai/components/stepper_cta_button.dart';
import 'package:cleanpixel_ai/components/permission_primer_dialog.dart';
import 'package:cleanpixel_ai/components/rating_dialog.dart';
import 'package:cleanpixel_ai/components/export_sheet_dialog.dart';
import 'package:cleanpixel_ai/components/pixel_agent_sheet.dart';
import 'package:cleanpixel_ai/services/inpaint_engine.dart';
import 'package:cleanpixel_ai/services/auth_service.dart';
import 'package:cleanpixel_ai/services/history_service.dart';
import 'package:cleanpixel_ai/screens/premium_screen.dart';
import 'package:cleanpixel_ai/screens/settings_screen.dart';

enum StudioState { idle, drawing, processing, result }
enum StudioMode { photo, video, batch }

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({Key? key}) : super(key: key);

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> with TickerProviderStateMixin {
  StudioState _state = StudioState.idle;
  StudioMode _mode = StudioMode.photo;

  File? _selectedImage;
  Uint8List? _cleanedImageBytes;
  bool _isDemoSample = false;

  // Drawing state
  List<DrawingPoint?> _points = [];
  final List<List<DrawingPoint?>> _history = [];
  final List<List<DrawingPoint?>> _redoHistory = [];
  bool _isBrush = true;
  double _strokeWidth = 32.0;

  // Stepper state
  String _stepperStatus = "Segmenting watermark contours...";
  String _stepperProgress = "Phase 1/4 • 20%";

  final ImagePicker _picker = ImagePicker();

  // Animations
  late AnimationController _idlePulseController;
  late AnimationController _scanLineController;
  late AnimationController _processingController;
  late AnimationController _toolbarRevealController;
  late AnimationController _resultController;

  @override
  void initState() {
    super.initState();

    _idlePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _processingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _toolbarRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _idlePulseController.dispose();
    _scanLineController.dispose();
    _processingController.dispose();
    _toolbarRevealController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _handleImageImport() async {
    final choice = await PermissionPrimerDialog.show(context);
    if (choice == null) return;

    if (choice == MediaPickSource.gallery) {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _onMediaLoaded(File(picked.path), isDemo: false);
      }
    } else if (choice == MediaPickSource.camera) {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        _onMediaLoaded(File(picked.path), isDemo: false);
      }
    } else if (choice == MediaPickSource.demo) {
      _loadDemoSample();
    }
  }

  void _onMediaLoaded(File file, {required bool isDemo}) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedImage = file;
      _cleanedImageBytes = null;
      _isDemoSample = isDemo;
      _points.clear();
      _history.clear();
      _redoHistory.clear();
      _state = StudioState.drawing;
    });
    _toolbarRevealController.forward(from: 0);
  }

  void _loadDemoSample() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedImage = null;
      _cleanedImageBytes = null;
      _isDemoSample = true;
      _points.clear();
      _history.clear();
      _redoHistory.clear();
      _state = StudioState.drawing;
    });
    _toolbarRevealController.forward(from: 0);
  }

  void _saveHistory() {
    _history.add(List.from(_points));
    _redoHistory.clear();
  }

  void _undo() {
    if (_history.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _redoHistory.add(List.from(_points));
        _points = _history.removeLast();
      });
    }
  }

  void _redo() {
    if (_redoHistory.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _history.add(List.from(_points));
        _points = _redoHistory.removeLast();
      });
    }
  }

  void _clearMask() {
    HapticFeedback.mediumImpact();
    setState(() {
      _saveHistory();
      _points.clear();
    });
  }

  Future<void> _runInpaint(Size canvasSize) async {
    final remaining = await AuthService.getRemainingCredits();
    if (remaining <= 0) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('0 Credits remaining. Upgrade to Pro for unlimited cleans.'),
            ],
          ),
          action: SnackBarAction(
            label: 'Upgrade',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen()));
            },
          ),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _state = StudioState.processing;
      _stepperStatus = "Finding watermark area...";
      _stepperProgress = "Step 1 of 4 • 25%";
    });

    final imageProvider = _selectedImage != null
        ? FileImage(_selectedImage!)
        : const AssetImage('assets/logo.png') as ImageProvider;

    // Trigger inpaint engine in parallel with step animations
    final inpaintFuture = InpaintEngine.executeInpaint(
      imageFile: _selectedImage,
      imageProvider: imageProvider,
      points: _points,
      canvasSize: canvasSize,
    );

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _stepperStatus = "Erasing unwanted objects...";
      _stepperProgress = "Step 2 of 4 • 50%";
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _stepperStatus = "Restoring clean background...";
      _stepperProgress = "Step 3 of 4 • 75%";
    });

    final cleanedBytes = await inpaintFuture;
    await AuthService.deductCredit();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _stepperStatus = "Finishing up photo...";
      _stepperProgress = "Step 4 of 4 • 100%";
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    HapticFeedback.heavyImpact();
    _resultController.forward(from: 0);
    setState(() {
      _cleanedImageBytes = cleanedBytes;
      _state = StudioState.result;
    });
  }

  Future<void> _saveResultAndPromptRating() async {
    if (_cleanedImageBytes == null) return;

    ExportSheetDialog.show(
      context,
      imageBytes: _cleanedImageBytes!,
      onExport: (format, resolution) async {
        HapticFeedback.heavyImpact();

        // 1. Save to History Service Disk Storage
        final modeName = _mode == StudioMode.photo ? 'Watermark Inpaint' : 'Batch Clean';
        await HistoryService.saveToHistory(
          imageBytes: _cleanedImageBytes!,
          mode: modeName,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('Exported and saved in ${resolution == ExportResolution.ultra4k ? '4K Ultra' : '2K Quad'}!',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );

        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            RatingDialog.show(context);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider activeImageProvider = _selectedImage != null
        ? FileImage(_selectedImage!)
        : const AssetImage('assets/logo.png') as ImageProvider;

    final ImageProvider cleanedImageProvider = _cleanedImageBytes != null
        ? MemoryImage(_cleanedImageBytes!)
        : activeImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: const Color(0xFF0B0F19).withValues(alpha: 0.75),
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.auto_fix_high_rounded, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CleanPixel AI',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Text(
                        'Neural Inpaint Studio',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEC4899)),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'PixelAgent Copilot',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                  ),
                  onPressed: () {
                    final size = MediaQuery.of(context).size;
                    PixelAgentSheet.show(
                      context,
                      canvasSize: Size(size.width - 28, size.height * 0.55),
                      onAgentAction: (targetBoxes, msg) {
                        _saveHistory();
                        setState(() {
                          _state = StudioState.drawing;
                          for (final box in targetBoxes) {
                            final paint = Paint()
                              ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
                              ..strokeCap = StrokeCap.round
                              ..strokeWidth = 32.0;

                            for (double y = box.top + 8; y <= box.bottom - 8; y += 14) {
                              for (double x = box.left + 8; x <= box.right - 8; x += 14) {
                                _points.add(DrawingPoint(offset: Offset(x, y), paint: paint));
                              }
                              _points.add(null);
                            }
                          }
                        });
                        _toolbarRevealController.forward(from: 0);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF8B5CF6),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.all(16),
                            content: Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 10),
                                Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: PaywallBadge(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PremiumScreen()),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
          child: Column(
            children: [
              // 1. Studio Mode Switcher Tabs
              _buildModeSwitcher(),
              const SizedBox(height: 10),

              // 2. Central Viewport Panel
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _state == StudioState.processing
                              ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_mode == StudioMode.video)
                              _buildVideoTrackingView()
                            else if (_mode == StudioMode.batch)
                              _buildBatchView()
                            else if (_state == StudioState.idle)
                              _buildIdleView()
                            else if (_state == StudioState.drawing)
                              InteractiveCanvas(
                                sourceImage: activeImageProvider,
                                points: _points,
                                currentStrokeWidth: _strokeWidth,
                                isBrush: _isBrush,
                                onPanStart: (pos) {
                                  _saveHistory();
                                  final paint = Paint()
                                    ..color = _isBrush
                                        ? const Color(0xFF38BDF8).withValues(alpha: 0.65)
                                        : const Color(0xFF000000)
                                    ..strokeCap = StrokeCap.round
                                    ..strokeWidth = _strokeWidth
                                    ..blendMode = _isBrush ? BlendMode.srcOver : BlendMode.clear;
                                  setState(() {
                                    _points.add(DrawingPoint(offset: pos, paint: paint));
                                  });
                                },
                                onPanUpdate: (pos) {
                                  final paint = Paint()
                                    ..color = _isBrush
                                        ? const Color(0xFF38BDF8).withValues(alpha: 0.65)
                                        : const Color(0xFF000000)
                                    ..strokeCap = StrokeCap.round
                                    ..strokeWidth = _strokeWidth
                                    ..blendMode = _isBrush ? BlendMode.srcOver : BlendMode.clear;
                                  setState(() {
                                    _points.add(DrawingPoint(offset: pos, paint: paint));
                                  });
                                },
                                onPanEnd: () {
                                  setState(() {
                                    _points.add(null);
                                  });
                                },
                              )
                            else if (_state == StudioState.processing)
                              _buildProcessingView(activeImageProvider)
                            else if (_state == StudioState.result)
                              ScaleTransition(
                                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                                  CurvedAnimation(parent: _resultController, curve: Curves.easeOutCubic),
                                ),
                                child: FadeTransition(
                                  opacity: _resultController,
                                  child: ComparisonSlider(
                                    originalImage: activeImageProvider,
                                    cleanedImage: cleanedImageProvider,
                                  ),
                                ),
                              ),

                            // Floating Contextual Toolbar (Visible in drawing mode)
                            if (_mode == StudioMode.photo && _state == StudioState.drawing)
                              Positioned(
                                bottom: 16,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 2),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _toolbarRevealController,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: FadeTransition(
                                    opacity: _toolbarRevealController,
                                    child: ContextualToolbar(
                                      isBrush: _isBrush,
                                      strokeWidth: _strokeWidth,
                                      canUndo: _history.isNotEmpty,
                                      canRedo: _redoHistory.isNotEmpty,
                                      onToggleTool: () {
                                        HapticFeedback.selectionClick();
                                        setState(() => _isBrush = !_isBrush);
                                      },
                                      onStrokeChanged: (v) => setState(() => _strokeWidth = v),
                                      onUndo: _undo,
                                      onRedo: _redo,
                                      onClear: _clearMask,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // 3. Action Buttons Sub-Panel
              if (_mode == StudioMode.photo)
                if (_state == StudioState.result)
                  FadeTransition(
                    opacity: _resultController,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _toolbarRevealController.forward(from: 0);
                                setState(() => _state = StudioState.drawing);
                              },
                              icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white70),
                              label: const Text('Edit Again',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF0284C7)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: _saveResultAndPromptRating,
                                icon: const Icon(Icons.download_rounded, size: 20, color: Colors.white),
                                label: const Text('Save Clean Photo',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return StepperCtaButton(
                        isProcessing: _state == StudioState.processing,
                        isEnabled: _state == StudioState.drawing && _points.isNotEmpty,
                        statusText: _stepperStatus,
                        progressText: _stepperProgress,
                        onPressed: () => _runInpaint(Size(constraints.maxWidth, 400)),
                      );
                    },
                  )
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF8B5CF6)],
                      ),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PremiumScreen()),
                        );
                      },
                      icon: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                      label: const Text(
                        'Unlock Video Tracking in PRO Tier',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B0C24) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFFCE7F3),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          _buildModeTab('Photo', Icons.photo_outlined, StudioMode.photo),
          _buildModeTab('Video', Icons.videocam_outlined, StudioMode.video, badge: 'PRO'),
          _buildModeTab('Batch', Icons.layers_outlined, StudioMode.batch),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, IconData icon, StudioMode mode, {String? badge}) {
    final isSelected = _mode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _mode = mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEC4899).withValues(alpha: isDark ? 0.25 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? const Color(0xFFEC4899)
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFEC4899)
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdleView() {
    return AnimatedBuilder(
      animation: _idlePulseController,
      builder: (context, _) {
        final pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
          CurvedAnimation(parent: _idlePulseController, curve: Curves.easeInOut),
        ).value;
        final glowOpacity = Tween<double>(begin: 0.2, end: 0.45).animate(
          CurvedAnimation(parent: _idlePulseController, curve: Curves.easeInOut),
        ).value;
        final scanY = _scanLineController.value;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ScanLinePainter(progress: scanY),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero Glowing Icon
                    GestureDetector(
                      onTap: () => _handleImageSourceDirect(MediaPickSource.gallery),
                      child: Transform.scale(
                        scale: pulse,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: glowOpacity),
                                blurRadius: 36,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_photo_alternate_rounded, size: 40, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Clean Any Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Remove watermarks, logos & people in 1 tap',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // 3 Direct Quick Action Pills
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQuickActionPill(
                          icon: Icons.photo_library_rounded,
                          label: 'Gallery',
                          onTap: () => _handleImageSourceDirect(MediaPickSource.gallery),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionPill(
                          icon: Icons.camera_alt_rounded,
                          label: 'Camera',
                          onTap: () => _handleImageSourceDirect(MediaPickSource.camera),
                        ),
                        const SizedBox(width: 8),
                        _buildQuickActionPill(
                          icon: Icons.auto_awesome_rounded,
                          label: 'Try Sample',
                          isAccent: true,
                          onTap: () => _handleImageSourceDirect(MediaPickSource.demo),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionPill({
    required IconData icon,
    required String label,
    bool isAccent = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isAccent
                ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                : const Color(0xFF1E293B).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAccent
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isAccent ? const Color(0xFF38BDF8) : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isAccent ? const Color(0xFF38BDF8) : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleImageSourceDirect(MediaPickSource source) async {
    if (source == MediaPickSource.gallery) {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        _onMediaLoaded(File(picked.path), isDemo: false);
      }
    } else if (source == MediaPickSource.camera) {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        _onMediaLoaded(File(picked.path), isDemo: false);
      }
    } else if (source == MediaPickSource.demo) {
      _loadDemoSample();
    }
  }

  Widget _buildVideoTrackingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFEC4899).withValues(alpha: 0.3), blurRadius: 24),
                ],
              ),
              child: const Icon(Icons.videocam_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 18),
            const Text(
              'Deep Diffusion Video Tracking',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Erase moving watermarks, stamps, and logos across 60 FPS video streams automatically with temporal keyframe propagation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PremiumScreen()));
              },
              child: const Text('Upgrade to Unlock Video Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.layers_rounded, size: 40, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 18),
            const Text(
              'Bulk Image Batch Inpainter',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Clean watermarks from up to 50 photos simultaneously using distributed GPU queue workers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView(ImageProvider imageProvider) {
    return AnimatedBuilder(
      animation: _processingController,
      builder: (context, _) {
        final scanProgress = _processingController.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Opacity(
                opacity: 0.4,
                child: Image(image: imageProvider, fit: BoxFit.contain),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _ShimmerPainter(progress: scanProgress),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: scanProgress * (MediaQuery.of(context).size.height * 0.5),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF38BDF8).withValues(alpha: 0.7),
                      const Color(0xFF38BDF8),
                      const Color(0xFF38BDF8).withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const SweepGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF2563EB), Color(0xFF8B5CF6), Color(0xFF38BDF8)],
                          ).createShader(bounds),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              value: null,
                              color: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        const Icon(Icons.auto_fix_high_rounded, color: Color(0xFF38BDF8), size: 22),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _stepperStatus,
                      key: ValueKey(_stepperStatus),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _stepperProgress,
                      key: ValueKey(_stepperProgress),
                      style: TextStyle(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.8), fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF38BDF8).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 20, size.width, 40));

    canvas.drawRect(Rect.fromLTWH(0, y - 20, size.width, 40), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter old) => old.progress != progress;
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  _ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final x = (progress * 2 - 0.5) * size.width;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          const Color(0xFF38BDF8).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(x - 80, 0, 160, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter old) => old.progress != progress;
}
