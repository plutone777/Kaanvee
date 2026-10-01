import 'package:fyp_application/repositories/like_repository.dart';
import 'package:fyp_application/repositories/recommendation_repository.dart';
import 'package:fyp_application/services/collaborative_reccomendation_service.dart';
import 'package:fyp_application/services/like_service.dart';
import 'package:fyp_application/services/recommendation_service.dart';
import 'package:fyp_application/viewmodels/collaborative_recommendation_viewmodel.dart';
import 'package:fyp_application/viewmodels/like_viewmodel.dart';
import 'package:fyp_application/viewmodels/profile_viewmodel.dart';
import 'package:fyp_application/viewmodels/recommendation_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/vendor_service.dart';
import '../services/menu_service.dart';
import '../services/review_service.dart';
import '../services/report_service.dart';
import '../services/discussion_service.dart';

import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/vendor_repository.dart';
import '../repositories/menu_repository.dart';
import '../repositories/review_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/discussion_repository.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/vendor_viewmodel.dart';
import '../viewmodels/menu_viewmodel.dart';
import '../viewmodels/review_viewmodel.dart';
import '../viewmodels/report_viewmodel.dart';
import '../viewmodels/discussion_viewmodel.dart';

List<SingleChildWidget> appProviders = [
  // SERVICES
  Provider<AuthService>(create: (_) => AuthService()),

  Provider<UserService>(create: (_) => UserService()),

  Provider<VendorService>(create: (_) => VendorService()),

  Provider<MenuService>(create: (_) => MenuService()),

  Provider<ReviewService>(create: (_) => ReviewService()),

  Provider<ReportService>(create: (_) => ReportService()),

  Provider<DiscussionService>(create: (_) => DiscussionService()),

  // REPOSITORIES
  Provider<AuthRepository>(
    create: (context) => AuthRepository(context.read<AuthService>()),
  ),

  Provider<UserRepository>(
    create: (context) => UserRepository(context.read<UserService>()),
  ),

  Provider<VendorRepository>(
    create: (context) => VendorRepository(context.read<VendorService>()),
  ),

  Provider<MenuRepository>(
    create: (context) => MenuRepository(context.read<MenuService>()),
  ),

  Provider<ReviewRepository>(
    create: (context) => ReviewRepository(context.read<ReviewService>()),
  ),

  Provider<ReportRepository>(
    create: (context) => ReportRepository(context.read<ReportService>()),
  ),

  Provider<DiscussionRepository>(
    create: (context) =>
        DiscussionRepository(context.read<DiscussionService>()),
  ),

  // VIEWMODELS
  ChangeNotifierProvider<AuthViewModel>(
    create: (context) => AuthViewModel(
      context.read<AuthRepository>(),
      context.read<UserRepository>(),
    ),
  ),

  ChangeNotifierProvider<UserViewModel>(
    create: (context) => UserViewModel(context.read<UserRepository>()),
  ),

  ChangeNotifierProvider<VendorViewModel>(
    create: (context) => VendorViewModel(context.read<VendorRepository>()),
  ),

  ChangeNotifierProvider<MenuViewModel>(
    create: (context) => MenuViewModel(context.read<MenuRepository>()),
  ),

  ChangeNotifierProvider<ReviewViewModel>(
    create: (context) => ReviewViewModel(context.read<ReviewRepository>()),
  ),

  ChangeNotifierProvider<ReportViewModel>(
    create: (context) => ReportViewModel(context.read<ReportRepository>()),
  ),

  ChangeNotifierProvider<DiscussionViewModel>(
    create: (context) => DiscussionViewModel(
      context.read<DiscussionRepository>(),
      context.read<UserService>(),
    ),
  ),

  ChangeNotifierProvider<ProfileViewModel>(
    create: (context) => ProfileViewModel(
      context.read<ReviewRepository>(),
      context.read<DiscussionRepository>(),
    ),
  ),

  Provider<LikeService>(create: (_) => LikeService()),

  Provider<LikeRepository>(
    create: (context) => LikeRepository(context.read<LikeService>()),
  ),

  ChangeNotifierProvider<LikeViewModel>(
    create: (context) => LikeViewModel(context.read<LikeRepository>()),
  ),

  Provider<RecommendationService>(
    create: (context) => RecommendationService(
      context.read<UserService>(),
      context.read<VendorService>(),
    ),
  ),

  Provider<RecommendationRepository>(
    create: (context) =>
        RecommendationRepository(context.read<RecommendationService>()),
  ),

  ChangeNotifierProvider<RecommendationViewModel>(
    create: (context) =>
        RecommendationViewModel(context.read<RecommendationRepository>()),
  ),

  Provider<CollaborativeRecommendationService>(
    create: (context) => CollaborativeRecommendationService(
      context.read<LikeRepository>(),
      context.read<VendorService>(),
    ),
  ),

  ChangeNotifierProvider<CollaborativeRecommendationViewModel>(
    create: (context) => CollaborativeRecommendationViewModel(
      context.read<CollaborativeRecommendationService>(),
    ),
  ),
];
