import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class AudioRecordingS3Widget extends StatefulWidget {
  const AudioRecordingS3Widget(
      {Key? key, required this.isRecording, required this.toggleRecording})
      : super(key: key);

  final bool isRecording;
  final Function toggleRecording;

  @override
  State<AudioRecordingS3Widget> createState() => _AudioRecordingS3WidgetState();
}

class _AudioRecordingS3WidgetState extends State<AudioRecordingS3Widget> {
  // Initialize audio recorder
  final _audioRecorder = AudioRecorder();
  // final _audioRecorder = await FlutterSound()
  String _audioPath = '';
  String _s3Url = '';

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _audioPath = '${directory.path}/${const Uuid().v4()}';

        // Log before starting recording
        log("Attempting to start recording at path: $_audioPath");

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
          ),
          path: _audioPath,
        );

        widget.toggleRecording();
      }
    } catch (e) {
      log('Error starting recording: $e');
      // Print stack trace for more detailed error information
      log(StackTrace.current.toString());
    }
  }

  Future<void> _stopRecording() async {
    try {
      log("Stopping recording ${await _audioRecorder.isEncoderSupported(AudioEncoder.wav)}");
      final stoped = await _audioRecorder.stop();
      widget.toggleRecording();
      await _sendAudio();
    } catch (e) {
      log('Error stopping recording: $e');
    }
  }

  Future<void> _sendAudio() async {
    final file = File(_audioPath);

    // Check if file exists
    if (!await file.exists()) {
      log("Error: File does not exist at path: $_audioPath");
      return;
    }

    // Check file size
    final fileSize = await file.length();
    log("File size: $fileSize bytes");

    if (fileSize == 0) {
      log("Error: File is empty");
      return;
    }
    // Check file permissions
    try {
      await file.openRead().first;
    } catch (e) {
      log("Error: Unable to read file. Check permissions. Error: $e");
      return;
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
                widget.toggleRecording();
              },
              // onPressed: widget.isRecording ? _stopRecording : _startRecording,
              child: Icon(
                widget.isRecording ? Icons.square_rounded : Icons.mic,
                size: 35,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
