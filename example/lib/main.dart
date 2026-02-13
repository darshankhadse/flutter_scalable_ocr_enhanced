import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr_enhanced/flutter_scalable_ocr_enhanced.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_ocr/flutter_native_ocr.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enhanced OCR Demo',
      home: EnhancedOCRDemo(),
    );
  }
}

class EnhancedOCRDemo extends StatefulWidget {
  const EnhancedOCRDemo({super.key});

  @override
  State<EnhancedOCRDemo> createState() => _EnhancedOCRDemoState();
}

class _EnhancedOCRDemoState extends State<EnhancedOCRDemo> {
  final EnhancedOCRController _controller = EnhancedOCRController();
  final ImagePicker _picker = ImagePicker();
  final FlutterNativeOcr _nativeOcr = FlutterNativeOcr();
  
  String _currentText = "";
  bool _useCamera = true;
  File? _selectedImage;
  bool _isLoading = false;
  String _recognizedText = "";
  bool _detectOnce = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ===============================
  // Pick Image
  // ===============================
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _useCamera = false;
        _recognizedText = "";
        _currentText = "";
      });

      _runImageOCR();
    }
  }

  // ===============================
  // OCR From Image
  // ===============================
  Future<void> _runImageOCR() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final text = await _nativeOcr.recognizeText(_selectedImage!.path);

      setState(() {
        _recognizedText = text.isEmpty ? "No text found" : text;
      });
    } catch (e) {
      setState(() {
        _recognizedText = "Error: $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ===============================
  // Switch Back To Camera
  // ===============================
  void _backToCamera() {
    setState(() {
      _useCamera = true;
      _selectedImage = null;
      _recognizedText = "";
      _currentText = "";
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enhanced OCR Demo"),
        backgroundColor: Colors.blue,
        actions: [
          if (_useCamera)
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _pickImage,
            ),
          if (!_useCamera)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _backToCamera,
            ),
        ],
      ),
      body: Column(
        children: [
          // ===============================
          // CAMERA VIEW
          // ===============================
          if (_useCamera)
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: EnhancedScalableOCR(
                controller: _controller,
                detectOnce: _detectOnce,
                minTextLength: 3,
                boxHeight: MediaQuery.of(context).size.height / 4,
                onTextDetected: (text) {
                  setState(() {
                    _currentText = text;
                  });
                },
                onDetectionComplete: (text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Text captured: $text"),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                stoppedWidget: Container(
                  color: Colors.green.shade900,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Text Captured Successfully!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_controller.detectedText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _controller.detectedText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ===============================
          // IMAGE VIEW
          // ===============================
          if (!_useCamera && _selectedImage != null)
            Container(
              height: 250,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
              ),
            ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),

          // ===============================
          // CONTROLS
          // ===============================
          if (_useCamera)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Detect Once Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Detect Once Mode:",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: _detectOnce,
                        onChanged: (value) {
                          setState(() {
                            _detectOnce = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Control Buttons
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _controller.isActive
                                ? () => _controller.stop()
                                : () => _controller.start(),
                            icon: Icon(
                              _controller.isActive ? Icons.stop : Icons.play_arrow,
                            ),
                            label: Text(
                              _controller.isActive ? "Stop" : "Start",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _controller.isActive
                                  ? Colors.red
                                  : Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          if (_controller.isDetectionComplete)
                            ElevatedButton.icon(
                              onPressed: () => _controller.reset(),
                              icon: const Icon(Icons.refresh),
                              label: const Text("Scan Again"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // ===============================
          // TEXT DISPLAY
          // ===============================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Recognized Text:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_useCamera && _controller.isDetectionComplete)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          "Captured",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _useCamera && _controller.isDetectionComplete
                      ? Colors.green
                      : Colors.grey,
                  width: _useCamera && _controller.isDetectionComplete ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _useCamera && _controller.isDetectionComplete
                    ? Colors.green.shade50
                    : Colors.grey.shade50,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _useCamera
                      ? (_currentText.isEmpty ? "Scanning..." : _currentText)
                      : _recognizedText,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
