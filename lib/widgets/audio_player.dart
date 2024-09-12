import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:developer';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  FlutterSoundPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isInitialized = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _audioPlayer = FlutterSoundPlayer();
  //   _initAudioPlayer();
  // }

  // Future<void> _initAudioPlayer() async {
  //   try {
  //     log("Initializing audio player");
  //     await _audioPlayer!.openPlayer();
  //     log("Audio player initialized successfully");
  //     setState(() {
  //       _isInitialized = true;
  //     });
  //   } catch (e) {
  //     log("Error initializing audio player: $e");
  //     setState(() {
  //       _isInitialized = false;
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   _audioPlayer!.closePlayer();
  //   _audioPlayer = null;
  //   super.dispose();
  // }

  void _togglePlay() async {
    if (!_isInitialized) {
      log("Audio player not initialized. Retrying initialization...");
      // await _initAudioPlayer();
      // if (!_isInitialized) return;
    }

    try {
      if (_isPlaying) {
        log("Pausing audio playback $_isPlaying");
        await _audioPlayer!.pausePlayer();
      } else {
        log("Starting audio playback $_isPlaying ${_audioPlayer?.isOpen()} ${widget.audioUrl}");
        await _audioPlayer!.startPlayer(
          codec: Codec.pcm16WAV,
          fromURI: widget.audioUrl,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
            });
          },
        );
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      log("Error toggling audio playback: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isPlaying ? Icons.pause : Icons.mic,
      ),
      onPressed: _isInitialized ? _togglePlay : null,
    );
  }
}
