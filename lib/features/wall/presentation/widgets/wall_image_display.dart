import 'dart:io';

import 'package:flutter/material.dart';

class WallImageDisplay extends StatefulWidget {
  final String imagePath;

  const WallImageDisplay({super.key, required this.imagePath});

  @override
  State<WallImageDisplay> createState() => _WallImageDisplayState();
}

class _WallImageDisplayState extends State<WallImageDisplay> {
  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(widget.imagePath),
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image)),
    );
  }
}
