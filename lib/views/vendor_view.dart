import 'package:flutter/material.dart';
import 'package:fyp_application/viewmodels/collaborative_recommendation_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/models/recommendation_result.dart';
import 'package:fyp_application/viewmodels/auth_viewmodel.dart';
import 'package:fyp_application/viewmodels/user_viewmodel.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';
import 'package:fyp_application/viewmodels/recommendation_viewmodel.dart';
import 'package:fyp_application/views/add_vendor_view.dart';
import 'package:fyp_application/widgets/vendor_card.dart';
import 'package:fyp_application/widgets/vendor_filter.dart';

class VendorHomeView extends StatefulWidget {
  final bool adminMode;

  const VendorHomeView({super.key, this.adminMode = false});

  @override
  State<VendorHomeView> createState() => _VendorHomeViewState();
}

class _VendorHomeViewState extends State<VendorHomeView> {
  String? _selectedLocation;
  String _searchQuery = '';
  VendorFilterResult _currentFilter = const VendorFilterResult();
  List<VendorModel> filteredVendors = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vendorViewModel = context.read<VendorViewModel>();
      final authViewModel = context.read<AuthViewModel>();
      final userViewModel = context.read<UserViewModel>();
      final recommendationViewModel = context.read<RecommendationViewModel>();
      final collaborativeRecommendationViewModel =
          context.read<CollaborativeRecommendationViewModel>();

      await vendorViewModel.loadVendors();

      if (!mounted) return;

      final userId = authViewModel.user?.uid;

      if (userId != null) {
        await userViewModel.loadUser(userId);

        if (!mounted) return;

        await recommendationViewModel.loadPreferenceRecommendations(userId);

        if (!mounted) return;

        await collaborativeRecommendationViewModel.loadRecommendations(userId);
      }

      if (!mounted) return;

      setState(() {
        filteredVendors = _getRecommendedOrder(vendorViewModel);
      });
    });
  }

  Future<void> _refresh() async {
    final vendorViewModel = context.read<VendorViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final recommendationViewModel = context.read<RecommendationViewModel>();
    final collaborativeRecommendationViewModel =
        context.read<CollaborativeRecommendationViewModel>();

    await vendorViewModel.loadVendors();

    if (!mounted) return;

    final userId = authViewModel.user?.uid;

    if (userId != null) {
      await recommendationViewModel.loadPreferenceRecommendations(userId);

      if (!mounted) return;

      await collaborativeRecommendationViewModel.loadRecommendations(userId);
    }

    if (!mounted) return;

    _applyFilters(vendorViewModel);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserViewModel, VendorViewModel>(
      builder: (context, userViewModel, vendorViewModel, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocation(userViewModel),
                  _buildSearchBar(vendorViewModel),
                  _buildCollaborativeRecommendations(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                    child: Row(
                      children: [
                        Text(
                          'Explore vendors',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_currentFilter.selectedTags.isNotEmpty ||
                            _currentFilter.hours != 'Any' ||
                            _currentFilter.priceRange != 'Any' ||
                            _currentFilter.sortBy != 'Default')
                          Text(
                            'Filters applied',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                      ],
                    ),
                  ),
                  _buildVendorList(vendorViewModel),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add vendor',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddVendorView(adminMode: widget.adminMode),
                ),
              );

              if (!mounted) return;

              final vendorViewModel = context.read<VendorViewModel>();

              await vendorViewModel.loadVendors();

              if (!mounted) return;

              final authViewModel = context.read<AuthViewModel>();
              final recommendationViewModel =
                  context.read<RecommendationViewModel>();
              final collaborativeRecommendationViewModel =
                  context.read<CollaborativeRecommendationViewModel>();

              final userId = authViewModel.user?.uid;

              if (userId != null) {
                await recommendationViewModel
                    .loadPreferenceRecommendations(userId);

                if (!mounted) return;

                await collaborativeRecommendationViewModel
                    .loadRecommendations(userId);
              }

              if (!mounted) return;

              _applyFilters(vendorViewModel);
            },
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(VendorViewModel vendorViewModel) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (query) {
                _searchQuery = query;
                _applyFilters(vendorViewModel, searchQuery: query);
              },
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 52,
            width: 52,
            child: IconButton(
              tooltip: 'Filter and sort',
              icon: Icon(Icons.tune_rounded, color: colorScheme.primary),
              onPressed: () async {
                FocusScope.of(context).unfocus();

                final result =
                    await showModalBottomSheet<VendorFilterResult>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (context) {
                    return VendorFilter(initialFilter: _currentFilter);
                  },
                );

                if (result != null && mounted) {
                  setState(() {
                    _currentFilter = result;
                  });

                  _applyFilters(vendorViewModel);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborativeRecommendations() {
    return Consumer<CollaborativeRecommendationViewModel>(
      builder: (context, collaborativeViewModel, child) {
        final recommendations =
            collaborativeViewModel.recommendations.where((recommendation) {
          return recommendation.vendor.location ==
              (_selectedLocation ??
                  context.read<UserViewModel>().user?.location);
        }).toList();

        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Text(
                      'Others like you also liked',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 16),
                  itemCount: recommendations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final recommendation = recommendations[index];

                    return CollaborativeVendorCard(
                      recommendation: recommendation,
                      adminMode: widget.adminMode,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<VendorModel> _getRecommendedOrder(VendorViewModel vendorViewModel) {
    final recommendationViewModel = context.read<RecommendationViewModel>();

    final recommendations =
        recommendationViewModel.preferenceRecommendations;

    final recommendedIds = recommendations
        .map((recommendation) => recommendation.vendor.vendorId)
        .toSet();

    final recommendedVendors = recommendations
        .map((recommendation) => recommendation.vendor)
        .toList();

    final otherVendors = vendorViewModel.vendors
        .where((vendor) => !recommendedIds.contains(vendor.vendorId))
        .toList();

    return [...recommendedVendors, ...otherVendors];
  }

  void _applyFilters(VendorViewModel viewModel, {String? searchQuery}) {
    final query = (searchQuery ?? _searchQuery).trim().toLowerCase();

    var result = _getRecommendedOrder(viewModel);

    if (query.isNotEmpty) {
      result = result.where((vendor) {
        return vendor.name.toLowerCase().contains(query) ||
            vendor.description.toLowerCase().contains(query) ||
            vendor.location.toLowerCase().contains(query) ||
            vendor.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    result = VendorFilterLogic.apply(
      vendors: result,
      selectedTags: _currentFilter.selectedTags,
      hours: _currentFilter.hours,
      priceRange: _currentFilter.priceRange,
      sortBy: _currentFilter.sortBy,
    );

    if (!mounted) return;

    setState(() {
      filteredVendors = result;
    });
  }

  void _showLocationPicker(
    BuildContext context,
    UserViewModel userViewModel,
  ) {
    final locations = [
      'Malé',
      'Hulhumalé Phase 1',
      'Hulhumalé Phase 2',
      'Vilimalé',
      'Addu City',
      'Fuvahmulah',
    ];

    final currentLocation =
        _selectedLocation ?? userViewModel.user?.location;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Text(
                    'Choose location',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ...locations.map((location) {
                  final isSelected = currentLocation == location;

                  return ListTile(
                    leading: Icon(
                      isSelected
                          ? Icons.location_on_rounded
                          : Icons.location_on_outlined,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(location),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLocation = location;
                      });

                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocation(UserViewModel userViewModel) {
    if (userViewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (userViewModel.user == null) {
      return const SizedBox.shrink();
    }

    final location = _selectedLocation ?? userViewModel.user!.location;

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          FocusScope.of(context).unfocus();
          _showLocationPicker(context, userViewModel);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Text(
                        location,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 19,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVendorList(VendorViewModel viewModel) {
    if (viewModel.isLoading && filteredVendors.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.errorMessage != null && filteredVendors.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final userViewModel = context.read<UserViewModel>();

    final selectedLocation =
        _selectedLocation ?? userViewModel.user?.location;

    final vendors = filteredVendors.where((vendor) {
      return vendor.location == selectedLocation;
    }).toList();

    if (vendors.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 42,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  selectedLocation == null
                      ? 'No vendors found.'
                      : 'No vendors found in\n$selectedLocation.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Try a different search.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<RecommendationViewModel>(
      builder: (context, recommendationViewModel, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            final vendor = vendors[index];

            RecommendationResult? recommendation;

            for (final item
                in recommendationViewModel.preferenceRecommendations) {
              if (item.vendor.vendorId == vendor.vendorId) {
                recommendation = item;
                break;
              }
            }

            return VendorCard(
              vendor: vendor,
              adminMode: widget.adminMode,
              isRecommended: recommendation != null,
              matchPercentage: recommendation?.matchPercentage,
            );
          },
        );
      },
    );
  }
}

class VendorFilterLogic {
  static List<VendorModel> apply({
    required List<VendorModel> vendors,
    List<String> selectedTags = const [],
    String hours = 'Any',
    String priceRange = 'Any',
    String sortBy = 'Default',
  }) {
    List<VendorModel> result = List<VendorModel>.from(vendors);

    if (selectedTags.isNotEmpty) {
      result = result.where((vendor) {
        return selectedTags.every((tag) => vendor.tags.contains(tag));
      }).toList();
    }

    if (hours != 'Any') {
      final selectedTime = _parseTime(hours);

      if (selectedTime != null) {
        result = result.where((vendor) {
          final operatingHours =
              _parseOperatingHours(vendor.operatingHours);

          if (operatingHours == null) {
            return false;
          }

          final opening = operatingHours.$1;
          final closing = operatingHours.$2;

          return _isTimeWithinRange(selectedTime, opening, closing);
        }).toList();
      }
    }

    if (priceRange != 'Any') {
      result = result.where((vendor) {
        return vendor.priceRange == priceRange;
      }).toList();
    }

    switch (sortBy) {
      case 'Name A-Z':
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;

      case 'Name Z-A':
        result.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;

      case 'Newest':
        result.sort(
          (a, b) => b.createdDate.compareTo(a.createdDate),
        );
        break;

      case 'Default':
      default:
        break;
    }

    return result;
  }

  static DateTime? _parseTime(String time) {
    try {
      final parts = time.trim().split(' ');

      if (parts.length != 2) {
        return null;
      }

      final timePart = parts[0];
      final period = parts[1].toUpperCase();

      final timeValues = timePart.split(':');

      int hour = int.parse(timeValues[0]);
      int minute = int.parse(timeValues[1]);

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(2000, 1, 1, hour, minute);
    } catch (_) {
      return null;
    }
  }

  static (DateTime, DateTime)? _parseOperatingHours(String hours) {
    final parts = hours.split('-');

    if (parts.length != 2) {
      return null;
    }

    final opening = _parseTime(parts[0].trim());
    final closing = _parseTime(parts[1].trim());

    if (opening == null || closing == null) {
      return null;
    }

    return (opening, closing);
  }

  static bool _isTimeWithinRange(
    DateTime selected,
    DateTime opening,
    DateTime closing,
  ) {
    if (closing.isAfter(opening)) {
      return !selected.isBefore(opening) && !selected.isAfter(closing);
    }

    return !selected.isBefore(opening) || !selected.isAfter(closing);
  }
}