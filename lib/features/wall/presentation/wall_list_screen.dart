import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:borudaruma/features/wall/data/wall_service.dart';
import 'package:borudaruma/features/wall/presentation/widgets/wall_card.dart';
import 'package:borudaruma/features/wall/presentation/widgets/add_wall_card.dart';
import 'package:borudaruma/features/wall/data/wall_repository.dart';
import 'package:borudaruma/features/wall/model/wall.dart';
import 'dart:io';

class WallListScreen extends StatefulWidget {
  const WallListScreen({super.key});

  @override
  State<WallListScreen> createState() => _WallListScreenState();
}

class _WallListScreenState extends State<WallListScreen> {
  final _repository = WallRepository();
  final _wallService = WallService();
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

  Future<void> _showImageSourceActionSheetAndCreateWall() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('ギャラリーから選択'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _wallService.createWallFromImage(ImageSource.gallery);
                  _reloadWalls();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('写真を撮る'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _wallService.createWallFromImage(ImageSource.camera);
                  _reloadWalls();
                },
              ),
            ],
          ),
        );
      },
    );
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
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      sliver: SliverToBoxAdapter(
                        child: AddWallCard(
                          onTap: () async {
                            await _showImageSourceActionSheetAndCreateWall();
                          },
                        ),
                      ),
                    ),
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2列表示
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final wall = walls[index];
                        return WallCard(
                          wall: wall,
                          onTap: () async {
                            await context.push('/walls/detail/${wall.id}');
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
                                await _repository.deleteWall(wall.id);
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
                        );
                      }, childCount: walls.length),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
