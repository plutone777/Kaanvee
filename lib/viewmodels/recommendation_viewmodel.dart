import 'package:flutter/foundation.dart';

import '../models/recommendation_result.dart';
import '../repositories/recommendation_repository.dart';

class RecommendationViewModel extends ChangeNotifier {
  final RecommendationRepository _repository;

  RecommendationViewModel(this._repository);

  List<RecommendationResult>
      _preferenceRecommendations = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<RecommendationResult>
      get preferenceRecommendations =>
          _preferenceRecommendations;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadPreferenceRecommendations(
    String userId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferenceRecommendations =
          await _repository
              .getPreferenceRecommendations(userId);
    } catch (e) {
      _errorMessage =
          'Failed to load recommendations.';
      _preferenceRecommendations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRecommendations() {
    _preferenceRecommendations = [];
    _errorMessage = null;
    notifyListeners();
  }
}