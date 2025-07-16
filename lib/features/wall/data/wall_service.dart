import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:borudaruma/features/wall/model/wall.dart';
import 'package:borudaruma/features/wall/data/wall_repository.dart';

class WallService {
  final WallRepository _repository;
  final ImagePicker _picker;

  WallService({
    WallRepository? repository,
    ImagePicker? picker,
  })
      : _repository = repository ?? WallRepository(),
        _picker = picker ?? ImagePicker();

  Future<Wall?> createWallFromImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) {
      return null;
    }

    final imagePath = await _saveImageLocally(File(pickedFile.path));
    final newWall = Wall.create(
      name: '',
      description: '',
      imagePath: imagePath,
    );
    await _repository.addWall(newWall);
    return newWall;
  }

  Future<String> _saveImageLocally(File originalImage) async {
    final appDocumentPath = (await getApplicationDocumentsDirectory()).path;
    final fileExtension = originalImage.path.split('.').last;
    final fileName = 'wall_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final newPath = '$appDocumentPath/$fileName';
    final copied = await originalImage.copy(newPath);
    return copied.path;
  }
}
