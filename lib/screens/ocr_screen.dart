import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:permission_handler/permission_handler.dart';

class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = true;
  bool _isCameraOpen = true;
  String _recognizedText = '';
  String _errorMessage = '';
  List<bool> _isSelected = [true, false]; // Initial state - original selected
  String _displayText = 'Original Text'; // Initial text

  void _toggleButton(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
      }

      // Update the display text based on the toggle state
      _displayText = index == 0 ? 'Original Text' : 'Translated Text';
    });
  }

  @override
  void initState() {
    super.initState();
    // _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device.';
        });
        return;
      }

      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_cameraController == null) return;

    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Screen'),
      ),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: _isSelected,
            onPressed: _toggleButton,
            borderRadius: BorderRadius.circular(20),
            color: Colors.black, // Unselected text color
            selectedColor: Colors.white, // Selected text color
            fillColor: Colors.black,
            constraints: const BoxConstraints(
              minWidth: 100,
              minHeight: 30,
            ), // Background color when selected
            children: const [
              Text(
                'Original',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                'Translated',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  // Implement audio playback logic
                },
                label: const Text('Listen'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Implement audio playback logic
                },
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  // Implement audio playback logic
                },
                label: const Text('Copy'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : _isCameraOpen && _cameraController != null
                    ? CameraPreview(_cameraController!)
                    : Center(
                        child: Text(_recognizedText.isEmpty
                            ? 'Tap the camera icon to start'
                            : _recognizedText),
                      ),
          ),
          const SizedBox(height: 40),
          // Display either the original or translated text
          Text(
            _displayText,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _errorMessage.isEmpty
          ? FloatingActionButton(
              onPressed: () async {
                if (_isCameraOpen) {
                  await _cameraController?.stopImageStream();
                  setState(() {
                    _isCameraOpen = false;
                  });
                } else {
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    await _cameraController?.startImageStream(_processImage);
                    setState(() {
                      _isCameraOpen = true;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Camera permission denied')),
                    );
                  }
                }
              },
              child: Icon(_isCameraOpen ? Icons.stop : Icons.camera_alt),
            )
          : null,
      bottomSheet: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          LanguageToggle(),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
