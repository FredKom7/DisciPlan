import 'package:hive/hive.dart';
import '../models/restriction.dart';

class RestrictionRepository {
  static const String boxName = 'restrictions';

  Future<Box<Restriction>> _getBox() async {
    return await Hive.openBox<Restriction>(boxName);
  }

  Future<List<Restriction>> getRestrictions() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> addRestriction(Restriction restriction) async {
    final box = await _getBox();
    await box.put(restriction.id, restriction);
  }

  Future<void> updateRestriction(Restriction restriction) async {
    final box = await _getBox();
    await box.put(restriction.id, restriction);
  }

  Future<void> deleteRestriction(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
} 