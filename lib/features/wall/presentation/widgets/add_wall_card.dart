import 'package:flutter/material.dart';

class AddWallCard extends StatelessWidget {
  const AddWallCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.red[300],
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.only(top: 32.0, bottom: 32.0),
          child: Column(
            children: [
              Icon(Icons.add_circle_outline, size: 32.0, color: Colors.white),
              SizedBox(height: 6.0),
              Text(
                '新しいウォールを追加',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
