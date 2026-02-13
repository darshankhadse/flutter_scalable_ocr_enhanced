import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import 'enhanced_ocr_controller.dart';

/// Enhanced OCR widget with controller support and detectOnce feature
class EnhancedScalableOCR extends StatefulWidget {
  /// Controller to manage camera state
  final EnhancedOCRController? controller;

  /// If true, camera stops after first successful text detection
  final bool detectOnce;

  /// Minimum text length required to consider detection successful (for detectOnce)
  final int minTextLength;

  /// Callback when text is detected
  final Function(String)? onTextDetected;

  /// Callback when detection is complete (used with detectOnce)
  final Function(String)? onDetectionComplete;

  /// Callback for raw data from camera
  final Function(dynamic)? getRawData;

  /// Enable/disable torch
  final bool torchOn;

  /// Camera selection (0 = back, 1 = front)
  final int cameraSelection;

  /// Lock camera orientation
  final bool lockCamera;

  /// Custom paint for the scanning box
  final Paint? paintboxCustom;

  /// Box offset from left
  final double boxLeftOff;

  /// Box offset from right
  final double boxRightOff;

  /// Box offset from top
  final double boxTopOff;

  /// Box offset from bottom
  final double boxBottomOff;

  /// Height of scanning box
  final double boxHeight;

  /// Widget to show when camera is stopped
  final Widget? stoppedWidget;

  const EnhancedScalableOCR({
    super.key,
    this.controller,
    this.detectOnce = false,
    this.minTextLength = 3,
    this.onTextDetected,
    this.onDetectionComplete,
    this.getRawData,
    this.torchOn = false,
    this.cameraSelection = 0,
    this.lockCamera = true,
    this.paintboxCustom,
    this.boxLeftOff = 10,
    this.boxRightOff = 10,
    this.boxTopOff = 2.5,
    this.boxBottomOff = 2.5,
    this.boxHeight = 200,
    this.stoppedWidget,
  });

  @override
  State<EnhancedScalableOCR> createState() => _EnhancedScalableOCRState();
}

class _EnhancedScalableOCRState extends State<EnhancedScalableOCR> {
  late EnhancedOCRController _controller;
  bool _isInternalController = false;
  GlobalKey<ScalableOCRState> _ocrKey = GlobalKey<ScalableOCRState>();

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = EnhancedOCRController();
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(EnhancedScalableOCR oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_isInternalController) {
        _controller.dispose();
      } else {
        _controller.removeListener(_onControllerUpdate);
      }

      if (widget.controller == null) {
        _controller = EnhancedOCRController();
        _isInternalController = true;
      } else {
        _controller = widget.controller!;
        _isInternalController = false;
      }
      _controller.addListener(_onControllerUpdate);
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {
        // Rebuild when controller state changes
        if (_controller.isActive && !_controller.isDetectionComplete) {
          // Reinitialize camera with new key
          _ocrKey = GlobalKey<ScalableOCRState>();
        }
      });
    }
  }

  void _handleTextDetection(String text) {
    if (!_controller.isActive || _controller.isDetectionComplete) {
      return;
    }

    // Call the onTextDetected callback
    widget.onTextDetected?.call(text);

    // Check if we should stop after detection
    if (widget.detectOnce && text.trim().length >= widget.minTextLength) {
      _controller.markDetectionComplete(text);
      widget.onDetectionComplete?.call(text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isActive || _controller.isDetectionComplete) {
      return widget.stoppedWidget ??
          Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.isDetectionComplete
                        ? "Detection Complete"
                        : "Camera Stopped",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_controller.detectedText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _controller.detectedText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
    }

    return ScalableOCR(
      key: _ocrKey,
      torchOn: widget.torchOn,
      cameraSelection: widget.cameraSelection,
      lockCamera: widget.lockCamera,
      paintboxCustom: widget.paintboxCustom ??
          (Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..color = const Color.fromARGB(153, 102, 160, 241)),
      boxLeftOff: widget.boxLeftOff,
      boxRightOff: widget.boxRightOff,
      boxTopOff: widget.boxTopOff,
      boxBottomOff: widget.boxBottomOff,
      boxHeight: widget.boxHeight,
      getRawData: widget.getRawData,
      getScannedText: _handleTextDetection,
    );
  }
}
