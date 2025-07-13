import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../data/wall_repository.dart';
import '../model/wall.dart';

class WallListScreen extends StatefulWidget {
  const WallListScreen({super.key});

  @override
  State<WallListScreen> createState() => _WallListScreenState();
}

class _WallListScreenState extends State<WallListScreen> {
  final _repository = WallRepository();
  late Future<List<Wall>> _wallsFuture;

  @override
  void initState() {
    super.initState();
    _wallsFuture = _repository.getAllWalls();
  }

  void _reloadWalls() {
    setState(() {
      _wallsFuture = _repository.getAllWalls();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('壁一覧')),
      body: FutureBuilder<List<Wall>>(
        future: _wallsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          final walls = snapshot.data ?? [];
          if (walls.isEmpty) {
            return const Center(child: Text('登録された壁はありません'));
          }
          return ListView.builder(
            itemCount: walls.length,
            itemBuilder: (context, index) {
              final wall = walls[index];
              return ListTile(
                leading: Image.file(
                  File(wall.imagePath),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
                title: Text(
                  wall.name.isNotEmpty ? wall.name : 'Wall #${wall.id}',
                ),
                textColor: wall.name.isNotEmpty
                    ? Colors.black
                    : Colors.grey[600],
                onTap: () async {
                  await context.push('/walls/detail/${wall.uuid}');
                  _reloadWalls(); // 詳細画面から戻ってきたときに再読込
                },
                onLongPress: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('削除の確認'),
                        content: Text(
                          '「${wall.name.isNotEmpty ? wall.name : 'Wall #${wall.id}'}」を削除しますか？',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('削除'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    try {
                      // 画像ファイルを削除
                      final imageFile = File(wall.imagePath);
                      if (await imageFile.exists()) {
                        await imageFile.delete();
                      }
                      // データベースから削除
                      await _repository.deleteWall(wall.uuid);
                      _reloadWalls();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('壁を削除しました')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('削除に失敗しました: $e')),
                        );
                      }
                    }
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/walls/add');
          _reloadWalls(); // 追加後に再読込
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
