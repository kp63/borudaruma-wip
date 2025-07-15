import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../data/wall_repository.dart';
import '../model/wall.dart';

class WallAddScreen extends StatefulWidget {
  const WallAddScreen({super.key});

  @override
  State<WallAddScreen> createState() => _WallAddScreenState();
}

class _WallAddScreenState extends State<WallAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _repository = WallRepository();
  final _picker = ImagePicker();

  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _showImageSourceActionSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('ギャラリーから選択'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('写真を撮る'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _saveImageLocally(File originalImage) async {
    final appDocumentPath = (await getApplicationDocumentsDirectory()).path;
    final fileName = 'wall_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '$appDocumentPath/$fileName';
    final copied = await originalImage.copy(newPath);
    return copied.path;
  }

  Future<void> _saveWall() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('画像を選択してください')));
      return;
    }

    final savedImagePath = await _saveImageLocally(_selectedImage!);

    final wall = Wall.create(
      uuid: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: '',
      imagePath: savedImagePath,
    );

    await _repository.addWall(wall);
    if (!mounted) return;
    Navigator.pop(context); // 戻る（一覧画面で再読み込みされる）
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('壁を追加')),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          top: 16,
          right: 16,
          bottom: 32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: '壁の名前'),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (value.trim().length > 255) {
                              return '名前は255文字以内で入力してください';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _selectedImage != null
                          ? Image.file(_selectedImage!,
                              width: 200, height: 200)
                          : const Text('画像が選択されていません'),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _showImageSourceActionSheet,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('画像を選択'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FloatingActionButton.extended(
                onPressed: _saveWall,
                icon: const Icon(Icons.save),
                label: const Text('壁を登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
