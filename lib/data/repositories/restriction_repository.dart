import 'package:hive/hive.dart';
import '../models/restriction.dart';

class RestrictionRepository {
  static const String boxName = 'restrictions';

  Future<List<Restriction>> getRestrictions() async {
    final box = await Hive.openBox<Restriction>(boxName);
    return box.values.toList();
  }

  Future<void> addRestriction(Restriction restriction) async {
    final box = await Hive.openBox<Restriction>(boxName);
    await box.put(restriction.id, restriction);
  }

  Future<void> updateRestriction(Restriction restriction) async {
    final box = await Hive.openBox<Restriction>(boxName);
    await box.put(restriction.id, restriction);
  }

  Future<void> deleteRestriction(String id) async {
    final box = await Hive.openBox<Restriction>(boxName);
    await box.delete(id);
  }
} 