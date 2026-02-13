# Flutter Scalable OCR Enhanced

An enhanced wrapper around `flutter_scalable_ocr` that adds:
- **Controller support** for programmatic camera control (start/stop/toggle)
- **detectOnce** feature to automatically stop camera after successful text detection
- Customizable stopped widget
- Detection complete callbacks

## Features

✅ Start/Stop/Toggle camera programmatically  
✅ Auto-stop after text detection with `detectOnce`  
✅ Minimum text length validation  
✅ Custom stopped widget  
✅ Detection complete callbacks  
✅ All original `flutter_scalable_ocr` features preserved  

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_scalable_ocr_enhanced:
    path: path/to/flutter_scalable_ocr_enhanced
```

Or from pub.dev (once published):

```yaml
dependencies:
  flutter_scalable_ocr_enhanced: ^1.0.0
```

## Usage

### Basic Usage with Controller

```dart
import 'package:flutter_scalable_ocr_enhanced/flutter_scalable_ocr_enhanced.dart';

class MyOCRScreen extends StatefulWidget {
  @override
  _MyOCRScreenState createState() => _MyOCRScreenState();
}

class _MyOCRScreenState extends State<MyOCRScreen> {
  final EnhancedOCRController _controller = EnhancedOCRController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: EnhancedScalableOCR(
              controller: _controller,
              onTextDetected: (text) {
                print("Detected: $text");
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _controller.start(),
                child: Text("Start"),
              ),
              ElevatedButton(
                onPressed: () => _controller.stop(),
                child: Text("Stop"),
              ),
              ElevatedButton(
                onPressed: () => _controller.toggle(),
                child: Text("Toggle"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Detect Once Mode

Automatically stops camera after detecting text:

```dart
EnhancedScalableOCR(
  controller: _controller,
  detectOnce: true,
  minTextLength: 5, // Minimum characters to consider detection successful
  onDetectionComplete: (text) {
    print("Detection complete: $text");
    // Show dialog, navigate, etc.
  },
  onTextDetected: (text) {
    print("Scanning: $text");
  },
)
```

### Custom Stopped Widget

```dart
EnhancedScalableOCR(
  controller: _controller,
  stoppedWidget: Container(
    color: Colors.blue.shade900,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 100, color: Colors.green),
          SizedBox(height: 20),
          Text(
            "Text Captured!",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ],
      ),
    ),
  ),
)
```

### Complete Example

```dart
class OCRDemo extends StatefulWidget {
  @override
  _OCRDemoState createState() => _OCRDemoState();
}

class _OCRDemoState extends State<OCRDemo> {
  final EnhancedOCRController _controller = EnhancedOCRController();
  String _currentText = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enhanced OCR Demo"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _controller.reset(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Camera View
          Container(
            height: 400,
            child: EnhancedScalableOCR(
              controller: _controller,
              detectOnce: true,
              minTextLength: 3,
              boxHeight: 200,
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
                  ),
                );
              },
            ),
          ),

          // Controls
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
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
                          ),
                        ),
                        if (_controller.isDetectionComplete)
                          ElevatedButton.icon(
                            onPressed: () => _controller.reset(),
                            icon: Icon(Icons.refresh),
                            label: Text("Scan Again"),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detected Text:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _currentText.isEmpty ? "No text detected" : _currentText,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Controller Methods

| Method | Description |
|--------|-------------|
| `start()` | Start/resume camera scanning |
| `stop()` | Stop camera scanning |
| `toggle()` | Toggle between start/stop |
| `reset()` | Reset to initial state (clears detected text) |

## Controller Properties

| Property | Type | Description |
|----------|------|-------------|
| `isActive` | `bool` | Whether camera is currently scanning |
| `isDetectionComplete` | `bool` | Whether detection has completed (with detectOnce) |
| `detectedText` | `String` | Last detected text |

## Widget Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controller` | `EnhancedOCRController?` | `null` | Controller for managing camera state |
| `detectOnce` | `bool` | `false` | Auto-stop after successful detection |
| `minTextLength` | `int` | `3` | Minimum text length for successful detection |
| `onTextDetected` | `Function(String)?` | `null` | Callback when text is detected |
| `onDetectionComplete` | `Function(String)?` | `null` | Callback when detection completes |
| `stoppedWidget` | `Widget?` | `null` | Custom widget shown when camera stopped |
| `torchOn` | `bool` | `false` | Enable/disable torch |
| `cameraSelection` | `int` | `0` | Camera selection (0=back, 1=front) |
| `lockCamera` | `bool` | `true` | Lock camera orientation |
| `boxHeight` | `double` | `200` | Height of scanning box |
| `boxLeftOff` | `double` | `10` | Box offset from left |
| `boxRightOff` | `double` | `10` | Box offset from right |
| `boxTopOff` | `double` | `2.5` | Box offset from top |
| `boxBottomOff` | `double` | `2.5` | Box offset from bottom |
| `paintboxCustom` | `Paint?` | `null` | Custom paint for scanning box |

## Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- flutter_scalable_ocr: ^2.4.0

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
