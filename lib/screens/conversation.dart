import 'package:flutter/material.dart';
import 'package:monlamai_app/widgets/language_toggle.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  bool _isSourceRecording = false;
  bool _isTargetRecording = false;

  void toggleSourceRecording() {
    setState(() {
      if (_isTargetRecording) {
        // If target is recording, stop it and start source
        _isTargetRecording = false;
        _isSourceRecording = true;
      } else {
        // Otherwise, just toggle source
        _isSourceRecording = !_isSourceRecording;
      }
    });
  }

  void toggleTargetRecording() {
    setState(() {
      if (_isSourceRecording) {
        // If source is recording, stop it and start target
        _isSourceRecording = false;
        _isTargetRecording = true;
      } else {
        // Otherwise, just toggle target
        _isTargetRecording = !_isTargetRecording;
      }
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
            icon: const Icon(Icons.horizontal_split),
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
              _isSourceRecording || _isTargetRecording
                  ? const Text(
                      'Listening ....',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey,
                      ),
                    )
                  : Text(
                      'Speak',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[600],
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    _isSourceRecording ? Icons.square_rounded : Icons.mic,
                    size: 42,
                  ),
                  color: const Color(0xFF202020),
                  onPressed: toggleSourceRecording,
                  tooltip: "Tap to speak",
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: Icon(
                    _isTargetRecording ? Icons.square_rounded : Icons.mic,
                    size: 42,
                  ),
                  color: const Color(0xFF202020),
                  onPressed: toggleTargetRecording,
                  tooltip: "Tap to type",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
