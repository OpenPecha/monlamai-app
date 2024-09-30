import 'package:flutter/material.dart';

class ToggleText extends StatelessWidget {
  const ToggleText(
      {super.key, required this.isSelected, required this.toggleButton});

  final List<bool> isSelected;
  final Function(int)? toggleButton;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: toggleButton,
      borderRadius: BorderRadius.circular(20),
      color: Colors.black, // Unselected text color
      selectedColor: Colors.white, // Selected text color
      fillColor: Colors.black,
      constraints: const BoxConstraints(
        minWidth: 100,
        minHeight: 30,
      ), // Background color when selected
      children: const [
        Text(
          'Original',
          style: TextStyle(fontSize: 14),
        ),
        Text(
          'Translated',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
