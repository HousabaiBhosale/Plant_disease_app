import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/tflite_service.dart';
import '../services/api_service.dart';
import 'home_page.dart' show AppColors;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  final _tflite = TFLiteService();
  final _picker  = ImagePicker();
  CameraController? _cam;
  List<CameraDescription> _cameras = [];
  int  _camIdx    = 0;
  bool _flashOn   = false;
  bool _camReady  = false;
  bool _modelLoading = true;
  bool _analyzing    = false;

  late AnimationController _scanAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanAnim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([_loadModel(), _initCamera()]);
  }

  Future<void> _loadModel() async {
    await _tflite.loadModel();
    if (mounted) setState(() => _modelLoading = false);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _startCam(_cameras[_camIdx]);
    } catch (_) {}
  }

  Future<void> _startCam(CameraDescription cam) async {
    final ctrl = CameraController(cam, ResolutionPreset.high, enableAudio: false);
    await ctrl.initialize();
    if (!mounted) { await ctrl.dispose(); return; }
    await _cam?.dispose();
    setState(() { _cam = ctrl; _camReady = true; });
  }

  Future<void> _flipCam() async {
    if (_cameras.length < 2) return;
    _camIdx = (_camIdx + 1) % _cameras.length;
    setState(() => _camReady = false);
    await _startCam(_cameras[_camIdx]);
  }

  Future<void> _toggleFlash() async {
    if (_cam == null) return;
    _flashOn = !_flashOn;
    await _cam!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  Future<void> _takePhoto() async {
    if (!_camReady || _cam == null || _analyzing || _modelLoading) return;
    try {
      final xf = await _cam!.takePicture();
      await _runPrediction(File(xf.path));
    } catch (e) { _showError(e.toString()); }
  }

  Future<void> _pickGallery() async {
    if (_analyzing || _modelLoading) return;
    final xf = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90, maxWidth: 1024);
    if (xf == null) return;
    await _runPrediction(File(xf.path));
  }

  Future<void> _runPrediction(File imageFile) async {
    setState(() { _analyzing = true; });
    final sw = Stopwatch()..start();
    try {
      final result    = await _tflite.predict(imageFile);
      sw.stop();
      // Step 2: Save image to local storage
      final savedPath = await _saveImage(imageFile);
      
      // Step 3: Prepare disease code
      String rawCode;
      if (result.isUnknown) {
        rawCode = "Unknown___Unknown";
      } else {
        rawCode = "${result.plantName.replaceAll(' ', '_')}___${result.diseaseName.replaceAll(' ', '_')}";
      }
      
      // Step 4: Log to backend (THIS IS CRITICAL)
      final logged = await ApiService.logLocalPrediction(
        diseaseCode: rawCode,
        confidence: result.confidence / 100.0,
        imageName: p.basename(imageFile.path),
        processingTimeMs: sw.elapsedMilliseconds.toDouble(),
      );
      
      print('✅ Prediction logged: $logged'); // Debug print
      
      // Step 5: Show result to user
      if (mounted) {
        setState(() => _analyzing = false);
        final predictionId = logged['prediction_id']?.toString();
        _showResult(result, File(savedPath), predictionId);
      }
    } catch (e) {
      if (mounted) { setState(() => _analyzing = false); _showError(e.toString()); }
    }
  }

  Future<String> _saveImage(File file) async {
    final dir     = await getApplicationDocumentsDirectory();
    final scanDir = Directory(p.join(dir.path, 'scans'));
    if (!await scanDir.exists()) await scanDir.create(recursive: true);
    final name  = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await file.copy(p.join(scanDir.path, name));
    return saved.path;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white))),
        ]),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showResult(PredictionResult result, File image, String? predictionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultSheet(result: result, imageFile: image, predictionId: predictionId),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cam == null || !_cam!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cam!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startCam(_cameras[_camIdx]);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnim.dispose();
    _cam?.dispose();
    _tflite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        // Camera preview fills screen
        if (_camReady && _cam != null)
          Positioned.fill(child: CameraPreview(_cam!))
        else
          Positioned.fill(child: Container(
            color: const Color(0xFF050E08),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('🌿', style: TextStyle(fontSize: 80, color: Colors.white.withValues(alpha: 0.08))),
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: AppColors.g400, strokeWidth: 2),
              const SizedBox(height: 14),
              Text('Starting camera…', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white54)),
            ])),
          )),

        // Gradient vignette top
        Positioned(top: 0, left: 0, right: 0, child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent]),
          ),
        )),

        // Gradient vignette bottom
        Positioned(bottom: 0, left: 0, right: 0, child: Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter, end: Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent]),
          ),
        )),

        // Top bar
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(children: [
                _GlassBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context), size: 18),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Scan Leaf', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
                  Text('Point at a leaf and tap capture', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white54)),
                ])),
                _GlassBtn(
                  icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  onTap: _toggleFlash,
                  active: _flashOn,
                ),
                const SizedBox(width: 8),
                _GlassBtn(icon: Icons.flip_camera_ios_rounded, onTap: _flipCam),
              ]),
            ),
          ),
        ),

        // Scan frame in center
        Center(
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.g500.withValues(alpha: 0.2), width: 1),
              boxShadow: [
                BoxShadow(color: AppColors.g500.withValues(alpha: 0.08), blurRadius: 40, spreadRadius: 5),
              ],
            ),
            child: Stack(children: [
              // Corner brackets
              _Corner(top: true,  left: true),
              _Corner(top: true,  left: false),
              _Corner(top: false, left: true),
              _Corner(top: false, left: false),

              // Center crosshair (Glowing)
              Center(child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.g500.withValues(alpha: 0.6), width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.g500, shape: BoxShape.circle))),
              )),

              // Animated scan line (Laser style)
              AnimatedBuilder(
                animation: _scanAnim,
                builder: (_, __) => Positioned(
                  top: 12 + _scanAnim.value * 218, left: 12, right: 12,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        AppColors.g500.withValues(alpha: 0.4),
                        AppColors.g500,
                        AppColors.g500.withValues(alpha: 0.4),
                        Colors.transparent,
                      ]),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: AppColors.g500.withValues(alpha: 0.8), blurRadius: 15, spreadRadius: 1),
                        BoxShadow(color: AppColors.g500.withValues(alpha: 0.3), blurRadius: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),

        // Hint pill below scan frame
        Positioned(
          top: MediaQuery.of(context).size.height * 0.5 + 140,
          left: 0, right: 0,
          child: Center(child: _HintPill(text: 'Place leaf inside frame · avoid shadows')),
        ),

        // Bottom controls
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: SafeArea(
            top: false,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Scan tips row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(children: const [
                  _ScanTip(emoji: '☀️', label: 'Good light'),
                  SizedBox(width: 8),
                  _ScanTip(emoji: '🍃', label: 'Single leaf'),
                  SizedBox(width: 8),
                  _ScanTip(emoji: '📏', label: '20–30 cm'),
                  SizedBox(width: 8),
                  _ScanTip(emoji: '🎯', label: 'Symptoms visible'),
                  SizedBox(width: 8),
                  _ScanTip(emoji: '🖼️', label: 'Plain background'),
                ]),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(children: [
                  // Gallery button
                  GestureDetector(
                    onTap: _modelLoading ? null : _pickGallery,
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.photo_library_rounded, color: Colors.white, size: 22),
                        Text('Gallery', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Main capture button
                  Expanded(child: GestureDetector(
                    onTap: _modelLoading ? null : _takePhoto,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _modelLoading
                            ? [Colors.grey.shade600, Colors.grey.shade700]
                            : [AppColors.g500, AppColors.g700],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _modelLoading ? [] : [
                          BoxShadow(color: AppColors.g600.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(
                          _modelLoading ? Icons.hourglass_top_rounded : Icons.camera_alt_rounded,
                          color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          _modelLoading ? 'Loading AI model…' : 'Take Photo & Diagnose',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
                      ]),
                    ),
                  )),
                  const SizedBox(width: 16),

                  // Mode indicator
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.memory_rounded, color: Colors.white, size: 22),
                      Text('On-Device', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ),

        // ── Analyzing overlay ────────────────────────────────
        if (_analyzing)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const _ProcessingOrbs(),
                  const SizedBox(height: 32),
                  Text('Analyzing leaf…',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text('NEURAL ENGINE ACTIVE',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.g500, letterSpacing: 2)),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.security_rounded, color: AppColors.g500, size: 16),
                      const SizedBox(width: 10),
                      Text('Secure On-Device Inference',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
                    ]),
                  ),
                ]),
              ),
            ),
          ),

        // ── Model loading overlay ────────────────────────────
        if (_modelLoading)
          Positioned.fill(child: Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const CircularProgressIndicator(color: AppColors.g300, strokeWidth: 3),
              const SizedBox(height: 20),
              Text('Loading AI model…', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
              Text('Please wait a moment', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white54)),
            ]),
          )),
      ]),
    );
  }
}

// ── Glass button ───────────────────────────────────────────────
class _GlassBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  final double size; final bool active;
  const _GlassBtn({required this.icon, required this.onTap, this.size = 20, this.active = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: active ? AppColors.amber.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? AppColors.amber.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: active ? AppColors.amber : Colors.white, size: size),
    ),
  );
}

// ── Corner bracket ─────────────────────────────────────────────
class _Corner extends StatelessWidget {
  final bool top, left;
  const _Corner({required this.top, required this.left});
  @override
  Widget build(BuildContext context) => Positioned(
    top: top ? 0 : null, bottom: top ? null : 0,
    left: left ? 0 : null, right: left ? null : 0,
    child: Container(width: 40, height: 40, decoration: BoxDecoration(
      border: Border(
        top:    top  ? const BorderSide(color: AppColors.g300, width: 3) : BorderSide.none,
        bottom: !top ? const BorderSide(color: AppColors.g300, width: 3) : BorderSide.none,
        left:   left ? const BorderSide(color: AppColors.g300, width: 3) : BorderSide.none,
        right: !left ? const BorderSide(color: AppColors.g300, width: 3) : BorderSide.none,
      ),
      borderRadius: BorderRadius.only(
        topLeft:     (top && left)   ? const Radius.circular(8) : Radius.zero,
        topRight:    (top && !left)  ? const Radius.circular(8) : Radius.zero,
        bottomLeft:  (!top && left)  ? const Radius.circular(8) : Radius.zero,
        bottomRight: (!top && !left) ? const Radius.circular(8) : Radius.zero,
      ),
    )),
  );
}

class _HintPill extends StatelessWidget {
  final String text;
  const _HintPill({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
  );
}

class _ScanTip extends StatelessWidget {
  final String emoji, label;
  const _ScanTip({required this.emoji, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.white.withValues(alpha: 0.85))),
    ]),
  );
}

// ════════════════════════════════════════════════════════════════
// RESULT SHEET
// ════════════════════════════════════════════════════════════════
class _ResultSheet extends StatefulWidget {
  final PredictionResult result;
  final File imageFile;
  final String? predictionId;
  const _ResultSheet({required this.result, required this.imageFile, this.predictionId});

  @override
  State<_ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<_ResultSheet> {
  bool? _isCorrect;
  bool _submitting = false;

  Future<void> _submitFeedback(bool correct) async {
    if (widget.predictionId == null || _submitting) return;
    setState(() { _submitting = true; _isCorrect = correct; });

    try {
      await ApiService.submitFeedback(
        predictionId: widget.predictionId!, 
        wasCorrect: correct
      );
    } catch (_) {}
    
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final healthy = widget.result.isHealthy && !widget.result.isUnknown;

    return DraggableScrollableSheet(
      initialChildSize: 0.90, minChildSize: 0.5, maxChildSize: 0.97,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 44, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),

          Expanded(child: SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Leaf photo ─────────────────────────────────
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(widget.imageFile,
                    width: double.infinity, height: 220, fit: BoxFit.cover),
                ),
                // Gradient overlay
                Positioned(bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.g900.withValues(alpha: 0.92)]),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      _ConfidencePill(confidence: widget.result.confidence, isHealthy: healthy),
                      const SizedBox(height: 6),
                      Text(
                        widget.result.isUnknown ? 'Unrecognised Leaf' : widget.result.plantName,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white, height: 1.1)),
                      Text(
                        widget.result.isUnknown ? 'Too low confidence' : widget.result.diseaseName,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                    ]),
                  )),
                // Close button
                Positioned(top: 12, right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18)),
                  )),
                // Status badge top-left
                Positioned(top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: healthy ? AppColors.g600.withValues(alpha: 0.9) : AppColors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(healthy ? Icons.check_circle_rounded : Icons.warning_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text(widget.result.isUnknown ? 'Invalid' : (healthy ? 'Healthy' : 'Diseased'),
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white)),
                    ]),
                  )),
              ]),

              const SizedBox(height: 14),

              // Low confidence warning
              if (widget.result.isUnknown) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    const Text('⚠️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Low Confidence', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.amber)),
                      Text('Try a clearer photo with better lighting, closer to the leaf.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF7C5A00))),
                    ])),
                  ]),
                ),
                const SizedBox(height: 12),
              ],

              // ── Severity card ─────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('DISEASE SEVERITY',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSoft, letterSpacing: 0.6)),
                    Text('${widget.result.confidence.toStringAsFixed(1)}%',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14,
                        color: healthy ? AppColors.g600 : AppColors.orange)),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: widget.result.confidence / 100,
                      minHeight: 10,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(healthy ? AppColors.g400 : AppColors.orange)),
                  ),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Mild', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSoft)),
                    Text('Moderate', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSoft)),
                    Text(healthy ? '✓ Healthy' : '▶ Severe',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 10,
                        color: healthy ? AppColors.g600 : AppColors.red)),
                  ]),
                ]),
              ),

              const SizedBox(height: 12),

              // ── Stats row ─────────────────────────────────
              Row(children: [
                _StatChip(label: 'Confidence', value: '${widget.result.confidence.toStringAsFixed(1)}%',
                  icon: Icons.percent_rounded, color: AppColors.g600),
                const SizedBox(width: 10),
                _StatChip(label: 'Clarity Gap', value: '${widget.result.probGap.toStringAsFixed(1)}%',
                  icon: Icons.bar_chart_rounded, color: AppColors.blue),
                const SizedBox(width: 10),
                _StatChip(
                  label: 'Status',
                  value: widget.result.isUnknown ? 'Unknown' : (healthy ? 'Healthy' : 'Diseased'),
                  icon: healthy && !widget.result.isUnknown ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: healthy && !widget.result.isUnknown ? AppColors.g600 : AppColors.red),
              ]),

              const SizedBox(height: 14),

              // ── Info cards ────────────────────────────────
              _InfoCard(
                iconBg: const Color(0xFFFFF7E0), icon: '🔍', title: 'Symptoms Detected',
                body: widget.result.isUnknown
                  ? 'The image does not confidently match any known leaf disease. Please ensure it is a single, clear, well-lit leaf.'
                  : 'Visual patterns match known markers for ${widget.result.diseaseName} in ${widget.result.plantName}. High similarity found in the PlantVillage training dataset.',
                tags: widget.result.isUnknown ? ['Low Confidence'] : [widget.result.plantName, widget.result.diseaseName.split(' ').first],
              ),
              const SizedBox(height: 10),

              if (!widget.result.isUnknown) ...[
                _InfoCard(
                  iconBg: const Color(0xFFE8FFF2), icon: '💊', title: 'Recommended Treatment',
                  body: widget.result.recommendation,
                  tags: healthy ? ['No treatment needed', 'Monitor regularly'] : ['Apply fungicide', 'Consult expert'],
                ),
                const SizedBox(height: 10),

                _InfoCard(
                  iconBg: const Color(0xFFE8F3FF), icon: '🛡️', title: 'Prevention Tips',
                  body: 'Ensure proper air circulation. Avoid overhead watering. Apply preventive fungicide before the rainy season. Rotate fungicide types to prevent resistance.',
                ),
              ],

              const SizedBox(height: 20),
              
              // ── Feedback Section ─────────────────────────────
              if (widget.predictionId != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(children: [
                    Text(
                      _isCorrect == null ? 'Was this prediction accurate?' : 'Thank you for your feedback!',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textMid),
                    ),
                    const SizedBox(height: 12),
                    if (_isCorrect == null)
                      Row(children: [
                        Expanded(child: OutlinedButton.icon(
                          onPressed: _submitting ? null : () => _submitFeedback(true),
                          icon: const Icon(Icons.thumb_up_alt_rounded, size: 18),
                          label: const Text('Yes'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.g600,
                            side: const BorderSide(color: AppColors.g600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: OutlinedButton.icon(
                          onPressed: _submitting ? null : () => _submitFeedback(false),
                          icon: const Icon(Icons.thumb_down_alt_rounded, size: 18),
                          label: const Text('No'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.red,
                            side: const BorderSide(color: AppColors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        )),
                      ])
                    else
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(
                          _isCorrect! ? Icons.check_circle_rounded : Icons.info_rounded,
                          color: _isCorrect! ? AppColors.g600 : AppColors.amber,
                          size: 20
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCorrect! ? 'Verified as Correct' : 'Flagged as Incorrect',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.text),
                        ),
                      ]),
                  ]),
                ),
                const SizedBox(height: 12),
              ],

              // Scan again button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.g500, AppColors.g700]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppColors.g600.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text('Scan Another Leaf', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                  ]),
                ),
              ),

              const SizedBox(height: 12),
              Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.textSoft),
                const SizedBox(width: 5),
                Text('Not a substitute for expert agronomist advice',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSoft)),
              ])),
            ]),
          )),
        ]),
      ),
    );
  }
}

// ── Confidence pill overlay ────────────────────────────────────
class _ConfidencePill extends StatelessWidget {
  final double confidence; final bool isHealthy;
  const _ConfidencePill({required this.confidence, required this.isHealthy});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(
        color: isHealthy ? AppColors.g300 : AppColors.orange, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text('${confidence.toStringAsFixed(1)}% confidence',
        style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
    ]),
  );
}

// ── Stat chip ──────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatChip({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.07), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.nunitoSans(fontSize: 10, color: AppColors.textSoft)),
      ]),
      const SizedBox(height: 5),
      Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.text)),
    ]),
  ));
}

// ── Info card ──────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final Color iconBg; final String icon, title, body; final List<String>? tags;
  const _InfoCard({required this.iconBg, required this.icon, required this.title,
    required this.body, this.tags});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: AppColors.g900.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.text)),
      ]),
      const SizedBox(height: 12),
      Text(body, style: GoogleFonts.nunitoSans(fontSize: 13, color: AppColors.textMid, height: 1.65)),
      if (tags != null) ...[
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: tags!.map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: AppColors.g50, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.g200)),
          child: Text(t, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.g700)),
        )).toList()),
      ],
    ]),
  );
}

class _ProcessingOrbs extends StatefulWidget {
  const _ProcessingOrbs();
  @override
  State<_ProcessingOrbs> createState() => _ProcessingOrbsState();
}

class _ProcessingOrbsState extends State<_ProcessingOrbs> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Stack(alignment: Alignment.center, children: [
          _Circle(angle: _ctrl.value * 2 * math.pi, color: AppColors.g500, size: 80),
          _Circle(angle: (_ctrl.value + 0.33) * 2 * math.pi, color: AppColors.g400, size: 85),
          _Circle(angle: (_ctrl.value + 0.66) * 2 * math.pi, color: AppColors.accent, size: 90),
          const Center(child: Icon(Icons.psychology_rounded, color: Colors.white, size: 36)),
        ]);
      },
    );
  }
}

class _Circle extends StatelessWidget {
  final double angle, size; final Color color;
  const _Circle({required this.angle, required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(math.cos(angle) * 12, math.sin(angle) * 12),
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 2)],
        ),
      ),
    );
  }
}