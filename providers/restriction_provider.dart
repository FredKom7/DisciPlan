import 'package:flutter/material.dart';
import '../data/models/restriction.dart';
import '../data/repositories/restriction_repository.dart';

class RestrictionProvider extends ChangeNotifier {
  final RestrictionRepository _repository = RestrictionRepository();
  List<Restriction> _restrictions = [];

  List<Restriction> get restrictions => _restrictions;

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

  Future<void> toggleActive(Restriction restriction) async {
    final updated = Restriction(
      id: restriction.id,
      type: restriction.type,
      target: restriction.target,
      limitMinutes: restriction.limitMinutes,
      isActive: !restriction.isActive,
      createdAt: restriction.createdAt,
    );
    await _repository.updateRestriction(updated);
    await loadRestrictions();
  }
} 