import 'package:flutter/foundation.dart';

/// Controller for managing the enhanced OCR widget
class EnhancedOCRController extends ChangeNotifier {
  bool _isActive = true;
  bool _isDetectionComplete = false;
  String _detectedText = '';

  /// Whether the camera is currently active and scanning
  bool get isActive => _isActive;

  /// Whether detection has completed (used with detectOnce)
  bool get isDetectionComplete => _isDetectionComplete;

  /// The last detected text
  String get detectedText => _detectedText;

  /// Start or resume the camera scanning
  void start() {
    if (!_isActive) {
      _isActive = true;
      _isDetectionComplete = false;
      notifyListeners();
    }
  }

  /// Stop the camera scanning
  void stop() {
    if (_isActive) {
      _isActive = false;
      notifyListeners();
    }
  }

  /// Toggle between start and stop
  void toggle() {
    _isActive = !_isActive;
    if (_isActive) {
      _isDetectionComplete = false;
    }
    notifyListeners();
  }

  /// Reset the controller to initial state
  void reset() {
    _isActive = true;
    _isDetectionComplete = false;
    _detectedText = '';
    notifyListeners();
  }

  /// Internal method to mark detection as complete
  void _markDetectionComplete(String text) {
    _detectedText = text;
    _isDetectionComplete = true;
    _isActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
