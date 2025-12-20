import 'package:hive/hive.dart';

part 'app_restriction.g.dart';

@HiveType(typeId: 7)
class AppRestriction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String packageName;

  @HiveField(2)
  final String appName;

  @HiveField(3)
  final int dailyLimitMinutes;

  @HiveField(4)
  final List<int> restrictedDays; // 1=Monday, 7=Sunday

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final bool isActive;

  AppRestriction({
    required this.id,
    required this.packageName,
    required this.appName,
    required this.dailyLimitMinutes,
    this.restrictedDays = const [],
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'appName': appName,
      'dailyLimitMinutes': dailyLimitMinutes,
      'restrictedDays': restrictedDays,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory AppRestriction.fromJson(Map<String, dynamic> json) {
    return AppRestriction(
      id: json['id'] as String,
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      dailyLimitMinutes: json['dailyLimitMinutes'] as int,
      restrictedDays: (json['restrictedDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  AppRestriction copyWith({
    String? id,
    String? packageName,
    String? appName,
    int? dailyLimitMinutes,
    List<int>? restrictedDays,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return AppRestriction(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      restrictedDays: restrictedDays ?? this.restrictedDays,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isRestrictedToday() {
    final today = DateTime.now().weekday;
    return restrictedDays.contains(today);
  }

  String get limitText {
    final hours = dailyLimitMinutes ~/ 60;
    final minutes = dailyLimitMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m/day';
    } else if (hours > 0) {
      return '${hours}h/day';
    } else {
      return '${minutes}m/day';
    }
  }

  @override
  String toString() {
    return 'AppRestriction(packageName: $packageName, appName: $appName, limit: $dailyLimitMinutes min, days: $restrictedDays)';
  }
}
