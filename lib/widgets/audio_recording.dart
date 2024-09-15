import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:audio_session/audio_session.dart';

class AudioRecordingWidget extends StatefulWidget {
  const AudioRecordingWidget(
      {Key? key, required this.isRecording, required this.toggleRecording})
      : super(key: key);

  final bool isRecording;
  final Function toggleRecording;

  @override
  State<AudioRecordingWidget> createState() => _AudioRecordingWidgetState();
}

class _AudioRecordingWidgetState extends State<AudioRecordingWidget> {
  FlutterSoundRecorder? _recorder = FlutterSoundRecorder();
  String _audioPath = '';
  bool _recorderIsInited = false;

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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Allow access'),
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
      widget.toggleRecording();
    } catch (e) {
      log('Error starting recording: $e');
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
    }
  }

  void toggleRecording() async {
    if (!_recorderIsInited) {
      log('Recorder is not initialized');
      return;
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

    try {
      // send the audio file to the server

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
                widget.isRecording ? Icons.stop : Icons.mic,
                size: 35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
