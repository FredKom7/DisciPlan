import 'package:hive/hive.dart';
part 'restriction.g.dart';

@HiveType(typeId: 4)
class Restriction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // app_limit, explicit_content, short_form

  @HiveField(2)
  String target; // app/site/category name

  @HiveField(3)
  int? limitMinutes; // for app_limit

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  DateTime createdAt;

  Restriction({
    required this.id,
    required this.type,
    required this.target,
    this.limitMinutes,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
} 