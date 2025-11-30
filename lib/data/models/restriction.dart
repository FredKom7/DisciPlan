import 'package:hive/hive.dart';
part 'restriction.g.dart';

@HiveType(typeId: 4)
class Restriction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String appName;

  @HiveField(2)
  String startTime;

  @HiveField(3)
  String endTime;

  @HiveField(4)
  List<String> days;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  Restriction({
    required this.id,
    required this.appName,
    required this.startTime,
    required this.endTime,
    required this.days,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}