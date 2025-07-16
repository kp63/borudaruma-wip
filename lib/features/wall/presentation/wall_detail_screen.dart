import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:borudaruma/features/wall/presentation/widgets/wall_image_display.dart';
import 'package:borudaruma/features/wall/data/wall_repository.dart';
import 'package:borudaruma/features/wall/model/wall.dart';

class WallDetailScreen extends StatefulWidget {
  final int id;

  const WallDetailScreen({super.key, required this.id});

  @override
  State<WallDetailScreen> createState() => _WallDetailScreenState();
}

class _WallDetailScreenState extends State<WallDetailScreen> {
  late final WallRepository _repository;
  Wall? _wall;
  late TextEditingController _descriptionController;
  late FocusNode _descriptionFocusNode;

  @override
  void initState() {
    super.initState();
    _repository = WallRepository();
    _descriptionController = TextEditingController();
    _descriptionFocusNode = FocusNode();

    _loadWall();

    _descriptionFocusNode.addListener(() {
      if (!_descriptionFocusNode.hasFocus) {
        // When focus is lost, save the description
        _saveDescription();
      }
    });
  }

  Future<void> _loadWall() async {
    _wall = await _repository.getWallById(widget.id);
    if (mounted) {
      setState(() {
        _descriptionController.text = _wall?.description ?? '';
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _editWallName() async {
    if (_wall == null) return;
    final controller = TextEditingController(text: _wall!.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('名称を変更'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '新しい名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('変更'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final updatedWall = _wall!.copyWith(name: newName);
      await _repository.updateWall(updatedWall);
      setState(() {
        _wall = updatedWall;
      });
    }
  }

  Future<void> _saveDescription() async {
    if (_wall == null) return;

    final newDescription = _descriptionController.text;
    if (newDescription != _wall!.description) {
      final updatedWall = _wall!.copyWith(description: newDescription);
      await _repository.updateWall(updatedWall);
      setState(() {
        _wall = updatedWall;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_wall == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ウォール詳細')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _wall!.name.isNotEmpty ? _wall!.name : 'ウォール #${_wall!.id}',
          style: TextStyle(
            color: _wall!.name.isNotEmpty ? Colors.black : Colors.grey[600],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('確認'),
                  content: const Text('本当にこの壁を削除しますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => context.pop(true),
                      child: const Text('削除'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _repository.deleteWall(widget.id);
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            WallImageDisplay(imagePath: _wall!.imagePath),
            ListTile(
              title: Text(
                _wall!.name.isNotEmpty ? _wall!.name : 'ウォール #${_wall!.id}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _wall!.name.isNotEmpty
                      ? Colors.black
                      : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () => _editWallName(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _descriptionController..text = _wall!.description,
                focusNode: _descriptionFocusNode,
                decoration: const InputDecoration(
                  labelText: '備考',
                  hintText: '説明を追加',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onSubmitted: (value) => _saveDescription(),
              ),
            ),

            const SizedBox(height: 100),

            // TODO: 課題・ホールド管理への導線
          ],
        ),
      ),
    );
  }
}
