import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monlamai_app/services/file_upload.dart';
import 'package:monlamai_app/services/ocr_service.dart';
import 'package:monlamai_app/services/translation_service.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/speaker.dart';
import 'package:permission_handler/permission_handler.dart';

class OcrScreen extends ConsumerStatefulWidget {
  const OcrScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends ConsumerState<OcrScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  String _errorMessage = '';
  XFile? _capturedImage;
  final List<bool> _isSelected = [
    true,
    false
  ]; // Initial state - original selected
  List<dynamic> textCoordinates = [];
  Map<String, dynamic> ocrResult = {};
  String markText = '';
  final FileUpload _fileUpload = FileUpload();
  final OcrService _ocrService = OcrService();
  final TranslationService _translationService = TranslationService();

  int imageWidth = 0;
  int imageHeight = 0;

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
      print('Picture taken: ${photo.path}');
      _sendImage();
    } catch (e) {
      log('Error taking picture: $e');
    }
  }

  // Function to pick images from the gallery
  Future<void> _pickImages() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = 'To use Monlam AI OCR, allow photo access';
      });
      return;
    }
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage != null) {
        setState(() {
          _capturedImage = pickedImage;
        });
        _sendImage();
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<void> _sendImage() async {
    if (_capturedImage == null) return;

    try {
      // send the audio file to the server
      Map<String, dynamic> uploadResult = await _fileUpload.uploadFile(
        filePath: _capturedImage!.path,
      );
      print('Sending image: ${_capturedImage!.path}');

      if (uploadResult['success'] == true) {
        String imageUrl = uploadResult['file_url'];

        // send the image file URL to the OCR service
        Map<String, dynamic> ocrResponse = await _ocrService.fetchTextFromImage(
          imageUrl: imageUrl,
        );

        if (ocrResponse['success'] == true) {
          print("OCR result: ${ocrResponse['output']} ");
          imageHeight = ocrResponse['height'];
          imageWidth = ocrResponse['width'];
          setState(() {
            textCoordinates = ocrResponse['output'];
          });

          // get the first text from the list
          String text = utf8.decode(ocrResponse['output'][0]['text'].codeUnits);
          String targetLang = ref.watch(targetLanguageProvider);

          print("Overall text: $text $targetLang");
          // Handle OCR result
          // send the text to the translation service
          Map<String, dynamic> translationResponse =
              await _translationService.translateText(text, targetLang);

          if (translationResponse['success'] == true) {
            print(
                "Ocr Translation result: ${translationResponse['translatedText']}");
            markText = translationResponse['translatedText'];
          } else {
            print("Failed to translate text: ${translationResponse['error']}");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to translate text')),
            );
          }
        } else {
          print("Failed to fetch text from image: ${ocrResponse['error']}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch text from image')),
          );
        }
      } else {
        print("Failed to upload image: ${uploadResult['error']}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      print('Error sending image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send image to upload')),
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
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FloatingActionButton(
                        onPressed: _pickImages,
                        tooltip: "Select image from gallery",
                        child: const Icon(Icons.photo),
                      ),
                      const SizedBox(height: 16),
                      const LanguageToggle()
                    ],
                  )
                : Container(),
            _capturedImage != null && textCoordinates.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Theme.of(context)
                                    .elevatedButtonTheme
                                    .style
                                    ?.backgroundColor
                                    ?.resolve({WidgetState.pressed}) ??
                                Colors.transparent),
                        child: Row(
                          children: [
                            SpeakerWidget(
                              text: _isSelected[1]
                                  ? markText
                                  : utf8.decode(
                                      textCoordinates.first['text'].codeUnits),
                              language: _isSelected[1]
                                  ? ref.watch(targetLanguageProvider)
                                  : ref.watch(sourceLanguageProvider),
                            ),
                            const Text('Listen'),
                            const SizedBox(width: 10),
                          ],
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
                          Clipboard.setData(
                            ClipboardData(
                                text: _isSelected[1]
                                    ? markText
                                    : utf8.decode(textCoordinates
                                        .first['text'].codeUnits)),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Text copied')),
                          );
                        },
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
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
      return LayoutBuilder(
        builder: (context, constraints) {
          // This gives you the width and height of the widget containing the image
          final double displayWidth = constraints.maxWidth;
          final double displayHeight = constraints.maxHeight;
          return Stack(
            fit: StackFit.loose,
            children: [
              _buildCapturedImage(),
              (textCoordinates.isNotEmpty)
                  ? _buildTextOverlay(
                      displayWidth,
                      displayHeight,
                    )
                  : Container(),
            ],
          );
        },
      );
    } else if (_isCameraInitialized &&
        _isCameraPermissionGranted &&
        _cameraController != null) {
      return CameraPreview(_cameraController!);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildCapturedImage() {
    return Image.file(
      File(_capturedImage!.path),
      fit: BoxFit.cover,
    );
  }

  Widget _buildTextOverlay(double displayWidth, double displayHeight) {
    print(
        "Display width: $displayWidth, height: $displayHeight, image width: $imageWidth, height: $imageHeight");

    // Calculate scale factors
    final double scaleX = (displayWidth / imageWidth).toDouble();
    final double scaleY = (displayHeight / imageHeight).toDouble();

    print("Scale factors: $scaleX, $scaleY");

    // Get only the first item from the list
    final coord = textCoordinates.first;

    final List<dynamic> boundingBox = coord['boundingBox']['vertices'];
    final text = utf8.decode(coord['text'].codeUnits);
    // Calculate the position and size of the text overlay
    final left = boundingBox[0]['x'].toDouble() * scaleX;
    final top = boundingBox[0]['y'].toDouble() * scaleY;
    final width =
        (boundingBox[2]['x'] - boundingBox[0]['x']).toDouble() * scaleX;
    final height =
        (boundingBox[2]['y'] - boundingBox[0]['y']).toDouble() * scaleY;

    print(
      'Text: $text, left: $left, top: $top, width: $width, height: $height',
    );

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: width,
              height: height,
              color: Colors.black.withOpacity(0.5),
              child: Text(
                _isSelected[1] ? markText : text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
