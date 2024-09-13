import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioRecordingWidget extends StatefulWidget {
  const AudioRecordingWidget({Key? key}) : super(key: key);

  @override
  State<AudioRecordingWidget> createState() => _AudioRecordingWidgetState();
}

class _AudioRecordingWidgetState extends State<AudioRecordingWidget> {
  FlutterSoundRecorder? _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _audioPath = '';
  bool _recorderIsInited = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    // .then((value) {
    //   setState(() {
    //     _recorderIsInited = true;
    //   });
    // });
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      log('Microphone permission not granted $status');
      // throw RecordingPermissionException('Microphone permission not granted');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Microphone Permission Required'),
          content: const Text(
              'Please enable microphone permission in your device settings to use this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
    await _recorder!.openRecorder();
    _recorderIsInited = true;
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Microphone Permission Required'),
          content: const Text(
              'Please enable microphone permission in your device settings to use this feature.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
    return false;
  }

  void startRecording() async {
    log("Starting recording ${_recorder!.isRecording}");
    try {
      final directory = await getApplicationDocumentsDirectory();
      _audioPath = '${directory.path}/${const Uuid().v4()}.wav';
      await _recorder!.startRecorder(toFile: _audioPath);
    } catch (e) {
      log('Error starting recording: $e');
    }
  }

  void stopRecording() async {
    log("Stopping recording ${_recorder!.isRecording}");
    try {
      String? path = await _recorder!.stopRecorder();
      log('Recording stopped: $path');
      await _sendAudio();
    } catch (e) {
      log('Error stopping recording: $e');
    }
  }

  void toggleRecording() async {
    if (!_recorderIsInited) {
      log('Recorder is not initialized');
      return;
    }
    return _recorder!.isStopped ? stopRecording() : startRecording();
    // final hasPermission = await _requestMicrophonePermission();
    // if (!hasPermission) return;

    // try {
    //   final directory = await getApplicationDocumentsDirectory();
    //   _audioPath = '${directory.path}/${const Uuid().v4()}.wav';
    //   await _recorder.startRecorder(toFile: _audioPath);
    //   setState(() => _isRecording = true);
    // } catch (e) {
    //   log('Error starting recording: $e');
    // }
    // } else {
    //   try {
    //     await _recorder.stopRecorder();
    //     setState(() => _isRecording = false);
    //     await _sendAudio();
    //   } catch (e) {
    //     log('Error stopping recording: $e');
    //   }
    // }
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

    try {
      // Here you would implement the logic to send the audio file to S3
      // For example:
      log("Audio file ready for upload: $_audioPath");
    } catch (e) {
      log("Error preparing file for upload: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Center(
            child: FloatingActionButton(
              onPressed: () {
                toggleRecording();
              },
              child: Icon(
                _recorder!.isRecording ? Icons.stop : Icons.mic,
                size: 35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
