import 'package:flutter/material.dart';

class LoadingText extends StatelessWidget {
  const LoadingText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Loading...',
      style: TextStyle(
        fontSize: 22,
        color: Colors.grey,
      ),
    );
  }
}
