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
} 