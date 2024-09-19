import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:monlamai_app/services/tts_service.dart';
import 'package:monlamai_app/widgets/audio_player.dart';

class SpeakerWidget extends StatefulWidget {
  const SpeakerWidget({
    super.key,
    required this.text,
    required this.language,
  });

  final String text;
  final String language;

  @override
  State<SpeakerWidget> createState() => _SpeakerWidgetState();
}

class _SpeakerWidgetState extends State<SpeakerWidget> {
  bool _isLoading = false;
  String? _audioUrl;
  String? _errorMessage;
  bool isTtsInitialized = false;
  late FlutterTts flutterTts;

  final TtsService ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    initTTS();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> initTTS() async {
    flutterTts = FlutterTts();
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      setState(() {
        isTtsInitialized = true;
      });
    } catch (e) {
      log("TTS initialization failed: $e");
      // Handle the error, perhaps show a dialog to the user
    }
  }

  Future<void> speak(String text) async {
    if (isTtsInitialized) {
      try {
        await flutterTts.speak(text);
      } catch (e) {
        log("TTS speak failed: $e");
        // Handle the error, perhaps show a dialog to the user
      }
    } else {
      log("TTS not initialized");
      // Inform the user that TTS is not ready
    }
  }

  Future<void> _fetchAudioUrl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _audioUrl = null;
    });
    try {
      final Map<String, dynamic> audioUrl = await ttsService.fetchAudioUrl(
        text: widget.text,
        language: widget.language,
      );
      if (audioUrl['success']) {
        setState(() {
          _audioUrl = audioUrl['output'];
        });
      } else {
        // Handle error
        log("Failed to fetch audio URL: ${audioUrl['error']}");
        setState(() {
          _errorMessage = audioUrl['error'];
        });
      }
    } catch (error) {
      // Handle error
      log("Error fetching audio URL: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(),
      );
    } else if (_errorMessage != null) {
      return IconButton(
        icon: const Icon(Icons.error),
        onPressed: () {
          if (widget.language == "en" && isTtsInitialized) {
            speak(widget.text);
          } else {
            _fetchAudioUrl();
          }
        },
        tooltip: _errorMessage,
      );
    } else if (_audioUrl != null) {
      return AudioPlayerWidget(audioUrl: _audioUrl!);
    } else {
      return IconButton(
        icon: const Icon(Icons.volume_up),
        onPressed: () {
          if (widget.language == 'en') {
            speak(widget.text);
          } else {
            _fetchAudioUrl();
          }
        },
      );
    }
  }
}
