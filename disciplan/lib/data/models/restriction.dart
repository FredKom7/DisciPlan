class Restriction {
  const Restriction({
    required this.id,
    required this.title,
    required this.type,
    this.limitMinutes,
    this.isActive = true,
  });

  final String id;
  final String title;
  final RestrictionType type;
  final int? limitMinutes;
  final bool isActive;
}

enum RestrictionType { appLimit, explicitContent, shortForm }

