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
  int? limitMinutes; // for app_limit - daily limit

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? startTime; // When restriction becomes active

  @HiveField(7)
  DateTime? endTime; // When restriction expires

  @HiveField(8)
  String scheduleType; // 'once', 'daily', 'weekly', 'duration'

  @HiveField(9)
  List<int>? activeDays; // Days of week (0=Sunday, 6=Saturday) for weekly

  @HiveField(10)
  String? dailyStartTime; // HH:mm format for recurring daily restrictions

  @HiveField(11)
  String? dailyEndTime; // HH:mm format for recurring daily restrictions

  @HiveField(12)
  int? durationMinutes; // For duration-based restrictions (e.g., block for 2 hours)

  @HiveField(13)
  String? packageName; // Android package name for app blocking

  Restriction({
    required this.id,
    required this.type,
    required this.target,
    this.limitMinutes,
    this.isActive = true,
    DateTime? createdAt,
    this.startTime,
    this.endTime,
    this.scheduleType = 'once',
    this.activeDays,
    this.dailyStartTime,
    this.dailyEndTime,
    this.durationMinutes,
    this.packageName,
  }) : createdAt = createdAt ?? DateTime.now();

  // Check if restriction is currently active based on schedule
  bool isCurrentlyActive() {
    if (!isActive) return false;

    final now = DateTime.now();

    switch (scheduleType) {
      case 'once':
        if (startTime != null && endTime != null) {
          return now.isAfter(startTime!) && now.isBefore(endTime!);
        }
        return false;

      case 'duration':
        if (startTime != null && durationMinutes != null) {
          final calculatedEndTime = startTime!.add(Duration(minutes: durationMinutes!));
          return now.isAfter(startTime!) && now.isBefore(calculatedEndTime);
        }
        return false;

      case 'daily':
        if (dailyStartTime != null && dailyEndTime != null) {
          final startParts = dailyStartTime!.split(':');
          final endParts = dailyEndTime!.split(':');
          final todayStart = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
          final todayEnd = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
          
          // Handle case where end time is next day (e.g., 11 PM to 6 AM)
          if (todayEnd.isBefore(todayStart)) {
            return now.isAfter(todayStart) || now.isBefore(todayEnd);
          }
          return now.isAfter(todayStart) && now.isBefore(todayEnd);
        }
        return false;

      case 'weekly':
        if (activeDays != null && activeDays!.isNotEmpty && dailyStartTime != null && dailyEndTime != null) {
          final currentWeekday = now.weekday % 7; // Convert to 0=Sunday
          if (!activeDays!.contains(currentWeekday)) return false;

          final startParts = dailyStartTime!.split(':');
          final endParts = dailyEndTime!.split(':');
          final todayStart = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
          final todayEnd = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
          
          if (todayEnd.isBefore(todayStart)) {
            return now.isAfter(todayStart) || now.isBefore(todayEnd);
          }
          return now.isAfter(todayStart) && now.isBefore(todayEnd);
        }
        return false;

      default:
        return false;
    }
  }

  // Get time remaining in minutes (for active restrictions)
  int? getTimeRemainingMinutes() {
    if (!isCurrentlyActive()) return null;

    final now = DateTime.now();

    switch (scheduleType) {
      case 'once':
        if (endTime != null) {
          return endTime!.difference(now).inMinutes;
        }
        break;

      case 'duration':
        if (startTime != null && durationMinutes != null) {
          final calculatedEndTime = startTime!.add(Duration(minutes: durationMinutes!));
          return calculatedEndTime.difference(now).inMinutes;
        }
        break;

      case 'daily':
      case 'weekly':
        if (dailyEndTime != null) {
          final endParts = dailyEndTime!.split(':');
          final todayEnd = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));
          
          if (todayEnd.isBefore(now)) {
            // End time is tomorrow
            final tomorrowEnd = todayEnd.add(const Duration(days: 1));
            return tomorrowEnd.difference(now).inMinutes;
          }
          return todayEnd.difference(now).inMinutes;
        }
        break;
    }

    return null;
  }

  Restriction copyWith({
    String? id,
    String? type,
    String? target,
    int? limitMinutes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? startTime,
    DateTime? endTime,
    String? scheduleType,
    List<int>? activeDays,
    String? dailyStartTime,
    String? dailyEndTime,
    int? durationMinutes,
    String? packageName,
  }) {
    return Restriction(
      id: id ?? this.id,
      type: type ?? this.type,
      target: target ?? this.target,
      limitMinutes: limitMinutes ?? this.limitMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      scheduleType: scheduleType ?? this.scheduleType,
      activeDays: activeDays ?? this.activeDays,
      dailyStartTime: dailyStartTime ?? this.dailyStartTime,
      dailyEndTime: dailyEndTime ?? this.dailyEndTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      packageName: packageName ?? this.packageName,
    );
  }
}