import 'dart:developer';

import 'package:flutter/material.dart';
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

  final TtsService ttsService = TtsService();

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
      return const CircularProgressIndicator();
    } else if (_errorMessage != null) {
      return IconButton(
        icon: const Icon(Icons.error),
        onPressed: () {
          // _fetchAudioUrl();
        },
        tooltip: _errorMessage,
      );
    } else if (_audioUrl != null) {
      return AudioPlayerWidget(audioUrl: _audioUrl!);
    } else {
      return IconButton(
        icon: const Icon(Icons.volume_up),
        onPressed: () {
          // _fetchAudioUrl();
        },
      );
    }
  }
}
