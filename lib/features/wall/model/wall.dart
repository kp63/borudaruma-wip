import 'package:isar/isar.dart';

part 'wall.g.dart';

@collection
class Wall {
  Id id = Isar.autoIncrement;

  late String uuid;
  late String name;
  late String description;
  late String imagePath;

  Wall();

  Wall.create({
    required this.uuid,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  Wall copyWith({
    String? name,
    String? description,
  }) {
    final newWall = Wall.create(
      uuid: uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath,
    );
    newWall.id = id;
    return newWall;
  }
}
