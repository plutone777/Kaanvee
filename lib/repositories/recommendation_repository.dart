import '../models/recommendation_result.dart';
import '../services/recommendation_service.dart';

class RecommendationRepository {
  final RecommendationService _service;

  RecommendationRepository(this._service);

  Future<List<RecommendationResult>>
      getPreferenceRecommendations(
    String userId,
  ) async {
    return await _service
        .getPreferenceRecommendations(userId);
  }
}