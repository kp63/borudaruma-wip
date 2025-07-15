import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../model/wall.dart';

class WallRepository {
  static final WallRepository _instance = WallRepository._internal();
  late final Future<Isar> _db;

  factory WallRepository() => _instance;

  WallRepository._internal() {
    _db = _initIsar();
  }

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([WallSchema], directory: dir.path);
  }

  Future<void> addWall(Wall wall) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.walls.put(wall);
    });
  }

  Future<List<Wall>> getAllWalls() async {
    final isar = await _db;
    final walls = await isar.walls.where().findAll();
    walls.sort((a, b) => b.id.compareTo(a.id)); // 降順ソート
    return walls;
  }

  Future<Wall?> getWallById(int id) async {
    final isar = await _db;
    return await isar.walls.filter().idEqualTo(id).findFirst();
  }

  Future<void> deleteWall(int id) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.walls.filter().idEqualTo(id).deleteAll();
    });
  }

  Future<void> updateWall(Wall wall) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.walls.put(wall);
    });
  }
}
