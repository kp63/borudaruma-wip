import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/wall_repository.dart';
import '../model/wall.dart';

class WallDetailScreen extends StatefulWidget {
  final String uuid;

  const WallDetailScreen({super.key, required this.uuid});

  @override
  State<WallDetailScreen> createState() => _WallDetailScreenState();
}

class _WallDetailScreenState extends State<WallDetailScreen> {
  late final WallRepository _repository;
  late Future<Wall?> _wallFuture;

  @override
  void initState() {
    super.initState();
    _repository = WallRepository();
    _wallFuture = _repository.getWallByUuid(widget.uuid);
  }

  void _reloadWall() {
    setState(() {
      _wallFuture = _repository.getWallByUuid(widget.uuid);
    });
  }

  Future<void> _editWallName(Wall wall) async {
    final controller = TextEditingController(text: wall.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('壁の名前を編集'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '新しい名前'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final updatedWall = wall.copyWith(name: newName);
      await _repository.updateWall(updatedWall);
      _reloadWall();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('壁の詳細'),
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
                await _repository.deleteWall(widget.uuid);
                if (context.mounted) {
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Wall?>(
        future: _wallFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final wall = snapshot.data;
          if (wall == null) {
            return const Center(child: Text('壁が見つかりません'));
          }

          return Column(
            children: [
              Expanded(
                child: Image.file(
                  File(wall.imagePath),
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),
              InkWell(
                onTap: () => _editWallName(wall),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        wall.name.isNotEmpty ? wall.name : 'Wall #${wall.id}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 編集画面への遷移（未実装）
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sorry'),
                      content: const Text('この機能はまだ実装されていません。'),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('編集'),
              ),
              const SizedBox(height: 16),
              // TODO: 課題・ホールド管理への導線
            ],
          );
        },
      ),
    );
  }
}
