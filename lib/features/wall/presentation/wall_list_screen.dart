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
      appBar: AppBar(title: const Text('ウォール一覧')),
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
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2列表示
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: walls.length,
            itemBuilder: (context, index) {
              final wall = walls[index];
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
                        onTap: () async {
                          await context.push('/walls/detail/${wall.uuid}');
                          _reloadWalls(); // 詳細画面から戻ってきたときに再読込
                        },
                        onLongPress: () async {
                          final messenger = ScaffoldMessenger.of(context);

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('削除の確認'),
                                content: Text(
                                  '「${wall.name.isNotEmpty ? wall.name : 'ウォール #${wall.id}'}」を削除しますか？',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
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

                              messenger.showSnackBar(
                                const SnackBar(content: Text('壁を削除しました')),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('削除に失敗しました: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
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
