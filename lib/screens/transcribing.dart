import 'package:flutter/material.dart';
import 'package:monlamai_app/screens/home.dart';

class TranscribingScreen extends StatelessWidget {
  const TranscribingScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Listening ....',
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LanguageButton(language: 'English'),
                SizedBox(width: 16.0),
                Icon(
                  Icons.swap_horiz,
                  size: 30,
                ),
                SizedBox(width: 16.0),
                LanguageButton(language: 'Tibetan'),
              ],
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: FloatingActionButton(
                  onPressed: () {
                    // Handle microphone button press
                  },
                  child: const Icon(
                    Icons.square_rounded,
                    size: 35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
