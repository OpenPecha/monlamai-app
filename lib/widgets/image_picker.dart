import 'package:flutter/material.dart';

class GalleryImagePicker extends StatelessWidget {
  const GalleryImagePicker({super.key, required this.pickImage});

  final Function()? pickImage;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FloatingActionButton(
        onPressed: pickImage,
        tooltip: "Select image from gallery",
        child: const Icon(Icons.photo),
      ),
    );
  }
}
