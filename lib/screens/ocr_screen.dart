import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:permission_handler/permission_handler.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({Key? key}) : super(key: key);

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  String _errorMessage = '';
  XFile? _capturedImage;
  final List<bool> _isSelected = [
    true,
    false
  ]; // Initial state - original selected

  void _toggleButton(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    setState(() {
      _isCameraPermissionGranted = status.isGranted;
    });
    if (status.isGranted) {
      _initializeCamera();
    } else {
      setState(() {
        _errorMessage = 'To use Monlam AI OCR, allow camera access';
      });
    }
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

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _cameraController == null) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
      });
      log('Picture taken: ${photo.path}');
    } catch (e) {
      log('Error taking picture: $e');
    }
  }

  Future<void> _sendImage() async {
    if (_capturedImage == null) return;

    try {
      // Implement your image upload logic here
      // For example:
      // await uploadImage(_capturedImage!);
      log('Sending image: ${_capturedImage!.path}');
      // Show a success message or navigate to a new screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      log('Error sending image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    }
  }

  void _resetCapture() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Handle back button press
              Navigator.pop(context);
            },
          ),
          title: _capturedImage != null
              ? ToggleButtons(
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
                )
              : Container(),
          actions: [
            _capturedImage != null
                ? IconButton(
                    onPressed: _resetCapture,
                    icon: const Icon(Icons.close),
                  )
                : Container()
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _errorMessage.isEmpty &&
                _isCameraInitialized &&
                _capturedImage == null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: _takePicture,
                  child: const Icon(
                    Icons.circle,
                    size: 50,
                  ),
                ),
              )
            : null,
        bottomSheet: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _capturedImage == null
                ? const LanguageToggle()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.volume_up),
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
          ]),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              onPressed: () {
                openAppSettings();
              },
              label: const Text("Go to settings"),
            )
          ],
        ),
      );
    } else if (_capturedImage != null) {
      return Image.file(File(_capturedImage!.path));
    } else if (_isCameraInitialized &&
        _isCameraPermissionGranted &&
        _cameraController != null) {
      return CameraPreview(_cameraController!);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
