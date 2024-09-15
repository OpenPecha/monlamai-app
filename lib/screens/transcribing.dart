import 'package:flutter/material.dart';
import 'package:monlamai_app/widgets/audio_recording.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';

class TranscribingScreen extends StatefulWidget {
  const TranscribingScreen({super.key});

  @override
  State<TranscribingScreen> createState() => _TranscribingScreenState();
}

class _TranscribingScreenState extends State<TranscribingScreen> {
  bool _isRecording = false;

  void toggleRecording() {
    // Handle recording toggle
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              // Handle star button press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isRecording
                  ? const Text(
                      'Listening ....',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey,
                      ),
                    )
                  : const Text(
                      'Tap the mic button to start',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey,
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const LanguageToggle(),
          AudioRecordingWidget(
            isRecording: _isRecording,
            toggleRecording: toggleRecording,
          ),
        ]),
      ),
    );
  }
}
