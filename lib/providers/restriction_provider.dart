import 'package:flutter/material.dart';
import '../data/models/restriction.dart';
import '../data/repositories/restriction_repository.dart';

class RestrictionProvider extends ChangeNotifier {
  final RestrictionRepository _repository = RestrictionRepository();
  List<Restriction> _restrictions = [];

  List<Restriction> get restrictions => _restrictions;

  List<Restriction> get activeRestrictions {
    return _restrictions.where((r) => r.isActive).toList();
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

  Future<void> toggleRestriction(String id) async {
    final restriction = _restrictions.firstWhere((r) => r.id == id);
    restriction.isActive = !restriction.isActive;
    await updateRestriction(restriction);
  }
}