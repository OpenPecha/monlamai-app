import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:monlamai_app/services/tts_service.dart';
import 'package:monlamai_app/widgets/audio_player.dart';
import 'dart:developer' as developer;

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
    developer.log("SpeakerWidget: ${widget.text}, ${widget.language}");

    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      setState(() {
        isTtsInitialized = true;
      });
    } catch (e) {
      // Handle the error, perhaps show a dialog to the user
      developer.log("TTS initialization failed: $e");
    }
  }

  Future<void> speak(String text) async {
    if (isTtsInitialized) {
      try {
        await flutterTts.speak(text);
      } catch (e) {
        // Handle the error, perhaps show a dialog to the user
        developer.log("Error speaking: $e");
      }
    } else {
      // Inform the user that TTS is not ready
      developer.log("TTS not initialized");
    }
  }

  Future<void> _fetchAudioUrl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _audioUrl = null;
    });
    developer
        .log("Fetching audio URL for ${widget.text} in ${widget.language}");
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
        developer.log("Failed to fetch audio URL: ${audioUrl['error']}");
        setState(() {
          _errorMessage = audioUrl['error'];
        });
      }
    } catch (error) {
      // Handle error
      developer.log("Error fetching audio URL: $error");
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
      return SizedBox(
        height: 40,
        width: 40,
        child: IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            if (widget.language == 'en') {
              speak(widget.text);
            } else {
              _fetchAudioUrl();
            }
          },
        ),
      );
    }
  }
}
