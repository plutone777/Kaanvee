import 'package:flutter/foundation.dart';
import 'package:fyp_application/models/collaborative_recommendation.dart';
import 'package:fyp_application/services/collaborative_reccomendation_service.dart';

class CollaborativeRecommendationViewModel
    extends ChangeNotifier {
  final CollaborativeRecommendationService _service;

  CollaborativeRecommendationViewModel(
    this._service,
  );

  List<CollaborativeRecommendation>
      _recommendations = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<CollaborativeRecommendation>
      get recommendations =>
          _recommendations;

  bool get isLoading =>
      _isLoading;

  String? get errorMessage =>
      _errorMessage;

  Future<void> loadRecommendations(
    String userId,
  ) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _recommendations =
          await _service.getRecommendations(
        userId,
      );
    } catch (e) {
      _recommendations = [];
      _errorMessage =
          'Failed to load recommendations.';
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void clearRecommendations() {
    _recommendations = [];
    _errorMessage = null;

    notifyListeners();
  }
}