import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.openPlayer();
      log("Audio player initialized successfully");
      setState(() {
        _isInitialized = true;
      });
      _startPlaying();
    } catch (e) {
      log("Error initializing audio player: $e");
      setState(() {
        _isInitialized = false;
      });
    }
  }

  Future<void> _startPlaying() async {
    if (!_isInitialized) {
      log("Audio player not initialized. Cannot start playback.");
      return;
    }

    try {
      log("Starting audio playback ${widget.audioUrl}");
      await _audioPlayer.startPlayer(
        fromURI: widget.audioUrl,
        codec: Codec.pcm16WAV,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      log("Error starting audio playback: $e");
    }
  }

  Future<void> _togglePlay() async {
    if (!_isInitialized) {
      log("Audio player not initialized. Cannot toggle playback.");
      return;
    }

    try {
      if (_isPlaying) {
        log("Pausing audio playback");
        await _audioPlayer.pausePlayer();
      } else {
        log("Resuming audio playback");
        await _audioPlayer.resumePlayer();
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
        _isPlaying ? Icons.pause : Icons.volume_up,
      ),
      onPressed: _isInitialized ? _togglePlay : null,
    );
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    super.dispose();
  }
}
