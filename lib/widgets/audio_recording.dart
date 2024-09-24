import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:monlamai_app/services/file_upload.dart';
import 'package:monlamai_app/services/stt_service.dart';
import 'package:monlamai_app/services/translation_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_session/audio_session.dart';

class AudioRecordingWidget extends ConsumerStatefulWidget {
  const AudioRecordingWidget({
    Key? key,
    required this.isRecording,
    required this.toggleRecording,
    required this.toggleLoading,
    required this.setTexts,
    required this.resetText,
    required this.langFrom,
    required this.langTo,
  }) : super(key: key);

  final bool isRecording;
  final Function toggleRecording;
  final Function toggleLoading;
  final Function setTexts;
  final Function resetText;
  final String langFrom;
  final String langTo;

  @override
  ConsumerState<AudioRecordingWidget> createState() =>
      _AudioRecordingWidgetState();
}

class _AudioRecordingWidgetState extends ConsumerState<AudioRecordingWidget> {
  FlutterSoundRecorder? _recorder = FlutterSoundRecorder();
  String _audioPath = '';
  bool _recorderIsInited = false;
  final FileUpload _fileUpload = FileUpload();
  final SttService _sttService = SttService();
  final TranslationService _translationService = TranslationService();

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder!.deleteRecord(fileName: _audioPath);
    _recorder = null;
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await _requestMicrophonePermission();
    await _recorder!.openRecorder();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    // check if the recorder is initialized
    setState(() {
      _recorderIsInited = true;
    });
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    // Ensure the widget is still mounted after the async operation
    if (!mounted) return;
    if (!status.isGranted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Can\'t access microphone'),
          content: const Text(
            "Monlam AI app needs permission to use the microphone.",
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

  void startRecording() async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      _audioPath = '${tempDir.path}/${const Uuid().v4()}.wav';
      log("Audio path: $_audioPath");
      await _recorder!.startRecorder(
        toFile: _audioPath,
        codec: Codec.pcm16WAV,
      );
      widget.resetText();
      widget.toggleRecording();
    } catch (e) {
      log('Error starting recording: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to start recording',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void stopRecording() async {
    try {
      String? path = await _recorder!.stopRecorder();
      log('Recording stopped: $path');
      widget.toggleRecording();
      await _sendAudio();
    } catch (e) {
      log('Error stopping recording: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to stop recording',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void toggleRecording() async {
    if (!_recorderIsInited) {
      log('Recorder is not initialized');
      return;
    }
    var status = await Permission.microphone.isGranted;
    if (!status) {
      await _requestMicrophonePermission();
    }
    return _recorder!.isStopped ? startRecording() : stopRecording();
  }

  Future<void> _sendAudio() async {
    final file = File(_audioPath);
    if (!await file.exists()) {
      log("Error: File does not exist at path: $_audioPath");
      return;
    }

    final fileSize = await file.length();
    log("File size: $fileSize bytes");

    if (fileSize == 0) {
      log("Error: File is empty");
      return;
    }

    widget.toggleLoading(true);

    try {
      // send the audio file to the server
      Map<String, dynamic> uploadResult = await _fileUpload.uploadFile(
        filePath: _audioPath,
      );

      if (uploadResult['success'] == true) {
        log("Audio file uploaded successfully: ${uploadResult['file_url']}");
        String audioUrl = uploadResult['file_url'];
        _recorder!.deleteRecord(fileName: _audioPath);

        // send the audio file URL to the STT service
        Map<String, dynamic> sttResult = await _sttService.fetchTextFromAudio(
          audioUrl: audioUrl,
          language: widget.langFrom,
        );

        if (sttResult['success'] == true) {
          log("Transcribed text: ${sttResult['output']}");
          String transcribedText = sttResult['output'];

          Map<String, dynamic> translationResult =
              await _translationService.translateText(
            transcribedText,
            widget.langTo,
          );

          if (translationResult['success'] == true) {
            log("Translated text: ${translationResult['translatedText']}");
            String translatedText = translationResult['translatedText'];

            widget.setTexts(transcribedText, translatedText, widget.langFrom,
                widget.langTo);
            widget.toggleLoading(false);
          } else {
            log("Error translating text: ${translationResult['error']}");
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to translate text',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          log("Error transcribing audio: ${sttResult['error']}");
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to transcribe audio',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        log("Error uploading audio file: ${uploadResult['error']}");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to upload audio',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      // For example:
      log("Audio file ready for upload: $_audioPath");
    } catch (e) {
      log("Error preparing file for upload: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to prepare audio file',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      widget.toggleLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            icon: Icon(
              widget.isRecording ? Icons.square_rounded : Icons.mic,
              size: 42,
            ),
            color: const Color(0xFF202020),
            onPressed: toggleRecording,
            tooltip: "Tap to speak",
          ),
        ),
      ],
    );
  }
}
