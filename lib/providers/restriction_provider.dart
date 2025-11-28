import 'package:flutter/material.dart';
import '../data/models/restriction.dart';
import '../data/repositories/restriction_repository.dart';

class RestrictionProvider extends ChangeNotifier {
  final RestrictionRepository _repository = RestrictionRepository();
  List<Restriction> _restrictions = [];

  List<Restriction> get restrictions => _restrictions;

  // Get all currently active restrictions
  List<Restriction> get activeRestrictions {
    return _restrictions.where((r) => r.isCurrentlyActive()).toList();
  }

  // Get restrictions for a specific app/target
  List<Restriction> getRestrictionsForApp(String appName) {
    return _restrictions
        .where((r) => r.target.toLowerCase() == appName.toLowerCase())
        .toList();
  }

  // Check if an app is currently restricted
  bool isAppRestricted(String appName) {
    return _restrictions.any((r) =>
        r.target.toLowerCase() == appName.toLowerCase() &&
        r.isCurrentlyActive());
  }

  // Get active restriction for an app (if any)
  Restriction? getActiveRestrictionForApp(String appName) {
    try {
      return _restrictions.firstWhere((r) =>
          r.target.toLowerCase() == appName.toLowerCase() &&
          r.isCurrentlyActive());
    } catch (e) {
      return null;
    }
  }

  Future<void> loadRestrictions() async {
    _restrictions = await _repository.getRestrictions();
    notifyListeners();
  }

  Future<void> addRestriction(Restriction restriction) async {
    await _repository.addRestriction(restriction);
    await loadRestrictions();
  }

  Future<void> updateRestriction(Restriction restriction) async {
    await _repository.updateRestriction(restriction);
    await loadRestrictions();
  }

  Future<void> deleteRestriction(String id) async {
    await _repository.deleteRestriction(id);
    await loadRestrictions();
  }

  Future<void> toggleRestriction(String id, bool isActive) async {
    final restriction = _restrictions.firstWhere((r) => r.id == id);
    await updateRestriction(restriction.copyWith(isActive: isActive));
  }

  // Clean up expired one-time and duration-based restrictions
  Future<void> cleanupExpiredRestrictions() async {
    final now = DateTime.now();
    final expiredRestrictions = _restrictions.where((r) {
      if (r.scheduleType == 'once' && r.endTime != null) {
        return now.isAfter(r.endTime!);
      }
      if (r.scheduleType == 'duration' &&
          r.startTime != null &&
          r.durationMinutes != null) {
        final endTime =
            r.startTime!.add(Duration(minutes: r.durationMinutes!));
        return now.isAfter(endTime);
      }
      return false;
    }).toList();

    for (final restriction in expiredRestrictions) {
      await updateRestriction(restriction.copyWith(isActive: false));
    }
  }
}