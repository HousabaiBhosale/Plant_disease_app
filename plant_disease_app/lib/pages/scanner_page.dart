import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  final TFLiteService _tfliteService = TFLiteService();
  bool _isProcessing = false;
  List<CameraDescription>? _cameras;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _tfliteService.loadModel();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _captureAndPredict() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      if (kIsWeb) {
        _showResultPanel({
          'plant': 'Tomato',
          'disease': 'Healthy (Web Demo)',
          'confidence': 99.8,
          'probGap': 15.0,
          'isUnknown': false,
        });
        return;
      }
      final XFile tappedImage = await _controller!.takePicture();
      final result = await _tfliteService.predict(tappedImage.path);
      if (mounted) _showResultPanel(result);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _isProcessing = true);
    try {
      if (kIsWeb) {
        _showResultPanel({
          'plant': 'Potato',
          'disease': 'Early Blight (Web Demo)',
          'confidence': 98.5,
          'probGap': 10.0,
          'isUnknown': false,
        });
        return;
      }
      final result = await _tfliteService.predict(image.path);
      if (mounted) _showResultPanel(result);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showResultPanel(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildResultPanel(result),
    );
  }

  Widget _buildResultPanel(Map<String, dynamic> result) {
    final bool isUnknown = result['isUnknown'] ?? true;
    final String plant = result['plant'] ?? 'Unknown';
    final String disease = result['disease'] ?? 'Unknown';
    final double confidence = result['confidence'] ?? 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUnknown ? Colors.orange[50] : Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(isUnknown ? Icons.help_outline : Icons.check_circle, color: isUnknown ? Colors.orange : Colors.green, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnknown ? 'Unknown Issue' : 'Diagnosis Result',
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isUnknown ? 'We couldn\'t identify this plant.' : 'The AI has identified a condition.',
                      style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Target Crop', plant),
          _buildInfoRow('Status', disease),
          _buildInfoRow('Confidence', '${confidence.toStringAsFixed(1)}%'),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isUnknown ? Colors.orange[50] : const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isUnknown ? Colors.orange[100]! : Colors.green[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 18, color: isUnknown ? Colors.orange[900] : const Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Text(
                      'Doctor\'s Advice',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isUnknown ? Colors.orange[900] : const Color(0xFF2E7D32)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isUnknown 
                    ? 'Try taking a clearer photo from a different angle with more light.' 
                    : disease.toLowerCase().contains('healthy') 
                      ? 'Your plant looks great! Keep up the good work with regular irrigation.' 
                      : 'Isolate the affected plant and consult an expert for proper treatment.',
                  style: GoogleFonts.outfit(color: isUnknown ? Colors.orange[800] : Colors.green[900], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 16)),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _tfliteService.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          _buildOverlay(),
          _buildActionButtons(),
          _buildProcessingIndicator(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Crop Doctor', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(onPressed: () {}, icon: const Icon(Icons.flash_off, color: Colors.white)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Viewfinder
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  _buildCorner(0, 0),
                  _buildCorner(0, 1),
                  _buildCorner(1, 0),
                  _buildCorner(1, 1),
                  FadeTransition(
                    opacity: _animController,
                    child: Center(
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.greenAccent.withOpacity(0.5), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Align the leaf inside the frame',
              style: GoogleFonts.outfit(color: Colors.white70, shadows: [const Shadow(blurRadius: 10, color: Colors.black)]),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(double top, double left) {
    return Positioned(
      top: top == 0 ? 0 : null,
      bottom: top == 1 ? 0 : null,
      left: left == 0 ? 0 : null,
      right: left == 1 ? 0 : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top == 0 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            bottom: top == 1 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            left: left == 0 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
            right: left == 1 ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(Icons.photo_library, 'Upload', _pickFromGallery),
          _buildShutterButton(),
          _buildIconButton(Icons.tips_and_updates, 'Tips', () {}),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _captureAndPredict,
      child: Container(
        height: 85,
        width: 85,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.psychology, size: 40, color: Color(0xFF2E7D32)),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    if (!_isProcessing) return const SizedBox.shrink();
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text('Analyzing Crop...', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
