# Usage Guide - Flutter Scalable OCR Enhanced

## Quick Start

### 1. Install the Package

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_scalable_ocr_enhanced:
    path: path/to/flutter_scalable_ocr_enhanced
```

### 2. Import

```dart
import 'package:flutter_scalable_ocr_enhanced/flutter_scalable_ocr_enhanced.dart';
```

### 3. Create Controller

```dart
final EnhancedOCRController _controller = EnhancedOCRController();
```

### 4. Use the Widget

```dart
EnhancedScalableOCR(
  controller: _controller,
  detectOnce: true,
  onTextDetected: (text) {
    print("Detected: $text");
  },
)
```

## Common Use Cases

### Case 1: Scan and Stop Manually

Perfect for when user wants to control when to capture text:

```dart
Column(
  children: [
    EnhancedScalableOCR(
      controller: _controller,
      detectOnce: false, // Manual control
      onTextDetected: (text) {
        setState(() => _scannedText = text);
      },
    ),
    ElevatedButton(
      onPressed: () => _controller.stop(),
      child: Text("Capture Text"),
    ),
  ],
)
```

### Case 2: Auto-Capture (Detect Once)

Perfect for barcode scanning, QR codes, or specific text patterns:

```dart
EnhancedScalableOCR(
  controller: _controller,
  detectOnce: true,
  minTextLength: 5, // Minimum 5 characters
  onDetectionComplete: (text) {
    // Navigate to next screen or process text
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(text: text),
      ),
    );
  },
)
```

### Case 3: Scan with Validation

Perfect for scanning specific formats (license plates, IDs, etc.):

```dart
EnhancedScalableOCR(
  controller: _controller,
  detectOnce: false,
  onTextDetected: (text) {
    // Custom validation
    if (isValidLicensePlate(text)) {
      _controller.stop();
      processLicensePlate(text);
    }
  },
)

bool isValidLicensePlate(String text) {
  // Your validation logic
  final regex = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{2}\d{4}$');
  return regex.hasMatch(text);
}
```

### Case 4: Multiple Scans in Sequence

Perfect for scanning multiple documents or items:

```dart
class MultiScanScreen extends StatefulWidget {
  @override
  _MultiScanScreenState createState() => _MultiScanScreenState();
}

class _MultiScanScreenState extends State<MultiScanScreen> {
  final EnhancedOCRController _controller = EnhancedOCRController();
  final List<String> _scannedTexts = [];

  void _onDetectionComplete(String text) {
    setState(() {
      _scannedTexts.add(text);
    });
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Scanned ${_scannedTexts.length} items"),
        content: Text("Scan another?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.reset(); // Scan again
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Done scanning
            },
            child: Text("Done"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          EnhancedScalableOCR(
            controller: _controller,
            detectOnce: true,
            onDetectionComplete: _onDetectionComplete,
          ),
          Text("Scanned ${_scannedTexts.length} items"),
        ],
      ),
    );
  }
}
```

### Case 5: Real-time Preview with Stop Button

Perfect for general OCR with live preview:

```dart
class LiveOCRScreen extends StatefulWidget {
  @override
  _LiveOCRScreenState createState() => _LiveOCRScreenState();
}

class _LiveOCRScreenState extends State<LiveOCRScreen> {
  final EnhancedOCRController _controller = EnhancedOCRController();
  String _liveText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: EnhancedScalableOCR(
              controller: _controller,
              detectOnce: false,
              onTextDetected: (text) {
                setState(() => _liveText = text);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Live Preview:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(_liveText),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _controller.stop();
                      // Save or process _liveText
                    },
                    child: Text("Stop & Save"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Advanced Features

### Custom Stopped Widget

```dart
EnhancedScalableOCR(
  controller: _controller,
  stoppedWidget: CustomPaint(
    painter: YourCustomPainter(),
    child: Center(
      child: Text("Custom Stopped State"),
    ),
  ),
)
```

### Listen to Controller State

```dart
@override
void initState() {
  super.initState();
  _controller.addListener(() {
    if (_controller.isDetectionComplete) {
      print("Detection completed!");
      print("Text: ${_controller.detectedText}");
    }
  });
}
```

### Conditional Detection

```dart
String _targetText = "URGENT";

EnhancedScalableOCR(
  controller: _controller,
  detectOnce: false,
  onTextDetected: (text) {
    if (text.contains(_targetText)) {
      _controller.stop();
      showAlert("Found target text!");
    }
  },
)
```

## Best Practices

1. **Always dispose the controller:**
   ```dart
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
   ```

2. **Use detectOnce for specific targets:**
   - Barcodes
   - QR codes
   - License plates
   - ID cards

3. **Use manual control for:**
   - Documents
   - Free-form text
   - When user needs to review

4. **Set appropriate minTextLength:**
   - Too low: May stop on noise
   - Too high: May miss valid text
   - Recommended: 3-5 for most cases

5. **Handle errors gracefully:**
   ```dart
   onTextDetected: (text) {
     try {
       // Process text
     } catch (e) {
       print("Error processing text: $e");
       _controller.reset(); // Try again
     }
   }
   ```

## Troubleshooting

**Camera doesn't stop:**
- Ensure `detectOnce: true`
- Check `minTextLength` isn't too high
- Verify text is being detected (check `onTextDetected`)

**Camera restarts unexpectedly:**
- Don't recreate the controller
- Use same controller instance
- Call `reset()` instead of creating new controller

**Text not detected:**
- Check lighting
- Ensure text is in focus
- Adjust `boxHeight` parameter
- Try different `minTextLength`

**Performance issues:**
- Reduce `boxHeight`
- Limit widget rebuilds
- Use `const` constructors where possible
