import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monlamai_app/services/file_upload.dart';
import 'package:monlamai_app/services/ocr_service.dart';
import 'package:monlamai_app/widgets/each_mark.dart';
import 'package:monlamai_app/widgets/image_picker.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';
import 'package:monlamai_app/widgets/ocr_tools.dart';
import 'package:monlamai_app/widgets/toggle_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class OcrScreen extends ConsumerStatefulWidget {
  const OcrScreen({super.key});

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
  List<Map<String, dynamic>> textCoordinates = [];
  String captureTexts = '';
  List<String> translatedTexts = [];
  final FileUpload _fileUpload = FileUpload();
  final OcrService _ocrService = OcrService();

  int imageWidth = 0;
  int imageHeight = 0;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  void _toggleButton(int index) {
    setState(() {
      for (int i = 0; i < _isSelected.length; i++) {
        _isSelected[i] = i == index;
      }
    });
  }

  void addTranslatedText(String text) {
    setState(() {
      translatedTexts.add(text);
    });
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
      debugPrint('Picture taken: ${photo.path}');
      _sendImage();
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  // Function to pick images from the gallery
  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (!mounted) return;
      if (!status.isGranted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Can\'t access photos'),
            content: const Text(
              "To translate your photos, allow access to your photo library",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Allow access',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }
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
      debugPrint('Error picking image: ${jsonEncode(e)}');
    }
  }

  Future<void> _sendImage() async {
    if (_capturedImage == null) return;

    try {
      // send the a file to the server
      Map<String, dynamic> uploadResult = await _fileUpload.uploadFile(
        filePath: _capturedImage!.path,
      );
      debugPrint('Upload result: $uploadResult');

      if (uploadResult['success'] == true) {
        String imageUrl = uploadResult['file_url'];

        // send the image file URL to the OCR service
        Map<String, dynamic> ocrResponse = await _ocrService.fetchTextFromImage(
          imageUrl: imageUrl,
        );

        if (ocrResponse['success'] == true) {
          debugPrint('OCR response: $ocrResponse');
          imageHeight = ocrResponse['height'];
          imageWidth = ocrResponse['width'];

          final fullTexts = ocrResponse['output']['fullTextAnnotation']['text'];

          setState(() {
            captureTexts = utf8.decode(fullTexts.codeUnits);
          });

          final processedData = processGoogleOCRData(ocrResponse['output']);

          setState(() {
            textCoordinates = processedData;
          });

          String targetLang = ref.watch(targetLanguageProvider);

          debugPrint('target language: $targetLang');
        } else {
          developer
              .log("Failed to fetch text from image: ${ocrResponse['error']}");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch text from image')),
          );
        }
      } else {
        debugPrint("Failed to upload image: ${uploadResult['error']}");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      debugPrint('Error sending image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send image to upload')),
      );
    }
  }

  List<Map<String, dynamic>> processGoogleOCRData(
      Map<String, dynamic> googleData) {
    List<Map<String, dynamic>> processedData = [];

    for (var page in googleData['fullTextAnnotation']['pages']) {
      for (var block in page['blocks']) {
        for (var paragraph in block['paragraphs']) {
          Map<String, dynamic> sentence = {
            'bounds': {
              'vertices': paragraph['boundingBox']['vertices'],
            },
            'words': paragraph['words'].map((word) {
              return {
                'text':
                    word['symbols'].map((symbol) => symbol['text']).join(''),
                'bounds': {
                  'vertices': word['boundingBox']['vertices'],
                },
              };
            }).toList(),
          };
          processedData.add(sentence);
        }
      }
    }

    return processedData;
  }

  void _resetCapture() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
        ),
        title: _capturedImage != null
            ? ToggleText(
                isSelected: _isSelected,
                toggleButton: _toggleButton,
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
      bottomSheet: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _capturedImage == null && _isCameraInitialized
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Stack(
                        children: [
                          GalleryImagePicker(
                            pickImage: _pickImage,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: FloatingActionButton(
                              shape: const CircleBorder(),
                              onPressed:
                                  _isCameraInitialized ? _takePicture : null,
                              disabledElevation: 4,
                              child: const Icon(
                                Icons.circle,
                                size: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const LanguageToggle()
                  ],
                )
              : Container(),
          _capturedImage != null &&
                  textCoordinates.isNotEmpty &&
                  translatedTexts.isNotEmpty
              ? OcrTools(
                  captureTexts: captureTexts,
                  translatedTexts: translatedTexts,
                  isSelected: _isSelected,
                )
              : Container(),
        ]),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_errorMessage.isNotEmpty && _capturedImage == null) {
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
              _buildCapturedImage(
                width: displayWidth,
                height: displayHeight,
              ),
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

  Widget _buildCapturedImage({required double width, required double height}) {
    return Image.file(
      width: width,
      height: height,
      File(_capturedImage!.path),
      fit: BoxFit.cover,
    );
  }

  Widget _buildTextOverlay(double displayWidth, double displayHeight) {
    final List<Widget> textElements = [];
    debugPrint(
        "Display width: $displayWidth, height: $displayHeight, image width: $imageWidth, height: $imageHeight");

    for (int blockIndex = 0;
        blockIndex < textCoordinates.length;
        blockIndex++) {
      dynamic block = textCoordinates[blockIndex];

      double xScale = (displayWidth / imageWidth).toDouble();
      double yScale = (displayHeight / imageHeight).toDouble();

      Map<String, double> blockBounds =
          getBoundingBox(block['bounds']['vertices'], xScale, yScale);

      String combinedText = (block['words'] as List<dynamic>)
          .map((word) => word['text'].toString())
          .join(" ");

      String decodedText = utf8.decode(combinedText.codeUnits);

      Map<String, double> firstWordBounds = getBoundingBox(
          block['words'][0]['bounds']['vertices'], xScale, yScale);

      double wordHeight = firstWordBounds['bottom']! - firstWordBounds['top']!;
      double fontSize = calculateFontSizeFromWordHeight(wordHeight);

      textElements.add(
        Positioned(
          left: blockBounds['left']!,
          top: blockBounds['top']!,
          child: Container(
            width: blockBounds['right']! - blockBounds['left']!,
            height: blockBounds['bottom']! - blockBounds['top']!,
            color: Colors.black.withOpacity(0.6),
            child: SingleChildScrollView(
              child: EachMark(
                  text: decodedText,
                  translatedTexts: translatedTexts,
                  addTranslatedText: addTranslatedText,
                  fontSize: fontSize,
                  isSelected: _isSelected,
                  targetLang: ref.watch(
                    targetLanguageProvider,
                  )),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: textElements,
    );
  }

  Map<String, double> getBoundingBox(
      List<dynamic> vertices, double xScale, double yScale) {
    double left = vertices[0]['x'] * xScale;
    double top = vertices[0]['y'] * yScale;
    double right = vertices[2]['x'] * xScale;
    double bottom = vertices[2]['y'] * yScale;
    return {'left': left, 'top': top, 'right': right, 'bottom': bottom};
  }

  double calculateFontSizeFromWordHeight(
    double wordHeight,
  ) {
    const scaleFactor = 0.8; // Adjust this as necessary to fit the text nicely
    // Calculate the font size and clamp it between 8 and 20 pixels
    return math.max(wordHeight * scaleFactor, 8);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
