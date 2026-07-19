import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImagePreviewCard extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final double height;

  const ImagePreviewCard({
    super.key,
    this.imageFile,
    this.imageBytes,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (imageBytes != null) {
      child = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (imageFile != null) {
      child = Image.file(imageFile!, fit: BoxFit.cover);
    } else {
      child = const Center(child: Text("No image selected"));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(height: height, child: child),
    );
  }
}