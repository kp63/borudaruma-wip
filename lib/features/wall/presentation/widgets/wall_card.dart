import 'dart:io';
import 'package:flutter/material.dart';

import 'package:borudaruma/features/wall/model/wall.dart';

class WallCard extends StatelessWidget {
  const WallCard({
    super.key,
    required this.wall,
    required this.onTap,
    required this.onLongPress,
  });

  final Wall wall;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(wall.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black54,
              child: Text(
                wall.name.isNotEmpty ? wall.name : 'ウォール #${wall.id}',
                style: TextStyle(
                  color: wall.name.isNotEmpty
                      ? Colors.white
                      : Colors.grey[400],
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
            ),
          ),
        ],
      ),
    );
  }
}
