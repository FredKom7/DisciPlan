import 'package:hive/hive.dart';

part 'app_usage_stats.g.dart';

@HiveType(typeId: 6)
class AppUsageStats extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final int usageTimeMinutes;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? appIcon; // Base64 encoded icon data

  AppUsageStats({
    required this.packageName,
    required this.appName,
    required this.usageTimeMinutes,
    required this.date,
    this.appIcon,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'usageTimeMinutes': usageTimeMinutes,
      'date': date.toIso8601String(),
      'appIcon': appIcon,
    };
  }

  factory AppUsageStats.fromJson(Map<String, dynamic> json) {
    return AppUsageStats(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      usageTimeMinutes: json['usageTimeMinutes'] as int,
      date: DateTime.parse(json['date'] as String),
      appIcon: json['appIcon'] as String?,
    );
  }

  AppUsageStats copyWith({
    String? packageName,
    String? appName,
    int? usageTimeMinutes,
    DateTime? date,
    String? appIcon,
  }) {
    return AppUsageStats(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      usageTimeMinutes: usageTimeMinutes ?? this.usageTimeMinutes,
      date: date ?? this.date,
      appIcon: appIcon ?? this.appIcon,
    );
  }

  @override
  String toString() {
    return 'AppUsageStats(packageName: $packageName, appName: $appName, usageTime: ${usageTimeMinutes}min, date: $date)';
  }
}
