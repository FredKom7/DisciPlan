class ScreenTimeEntry {
  const ScreenTimeEntry({
    required this.id,
    required this.appName,
    required this.minutes,
    required this.loggedAt,
  });

  final String id;
  final String appName;
  final int minutes;
  final DateTime loggedAt;
}

