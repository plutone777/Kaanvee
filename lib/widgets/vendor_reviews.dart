import 'package:flutter/material.dart';
import 'package:fyp_application/constants/lists.dart';
import 'package:fyp_application/models/vendor_review.dart';
import 'package:fyp_application/viewmodels/review_viewmodel.dart';
import 'package:fyp_application/viewmodels/user_viewmodel.dart';
import 'package:fyp_application/views/profile_view.dart';
import 'package:fyp_application/views/vendor_add_review_view.dart';
import 'package:provider/provider.dart';

class VendorReviewsSection extends StatefulWidget {
  final String vendorId;
  final bool adminMode;

  const VendorReviewsSection({
    super.key,
    required this.vendorId,
    this.adminMode = false,
  });

  @override
  State<VendorReviewsSection> createState() => _VendorReviewsSectionState();
}

class _VendorReviewsSectionState extends State<VendorReviewsSection> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reviewViewModel = context.read<ReviewViewModel>();
      final userViewModel = context.read<UserViewModel>();

      await reviewViewModel.loadVendorReviews(widget.vendorId);

      if (!mounted) return;

      for (final review in reviewViewModel.vendorReviews) {
        await userViewModel.loadUser(review.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ReviewViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviews',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // ==========================================================
            // LOADING
            // ==========================================================
            if (viewModel.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            // ==========================================================
            // ERROR
            // ==========================================================
            else if (viewModel.errorMessage != null)
              Text(viewModel.errorMessage!)
            // ==========================================================
            // NO REVIEWS
            // ==========================================================
            else if (viewModel.vendorReviews.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('No reviews yet.'),

                  if (!widget.adminMode) ...[
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddVendorReviewView(vendorId: widget.vendorId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Be the first to review'),
                    ),
                  ],
                ],
              )
            // ==========================================================
            // REVIEWS AVAILABLE
            // ==========================================================
            else
              _RatingSummary(
                reviews: viewModel.vendorReviews,
                vendorId: widget.vendorId,
                adminMode: widget.adminMode,
              ),
          ],
        );
      },
    );
  }
}

class VendorAllReviewsView extends StatefulWidget {
  final String vendorId;
  final bool adminMode;

  const VendorAllReviewsView({
    super.key,
    required this.vendorId,
    this.adminMode = false,
  });

  @override
  State<VendorAllReviewsView> createState() => _VendorAllReviewsViewState();
}

class _VendorAllReviewsViewState extends State<VendorAllReviewsView> {
  // ==========================================================
  // SELECTED SORT OPTION
  // ==========================================================

  String _selectedSort = AppLists.reviewSortOptions.first;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reviewViewModel = context.read<ReviewViewModel>();
      final userViewModel = context.read<UserViewModel>();

      await reviewViewModel.loadVendorReviews(widget.vendorId);

      if (!mounted) return;

      for (final review in reviewViewModel.vendorReviews) {
        await userViewModel.loadUser(review.userId);
      }
    });
  }

  // ==========================================================
  // SORT REVIEWS
  // ==========================================================

  List<VendorReviewModel> _sortReviews(
    List<VendorReviewModel> reviews,
  ) {
    final sortedReviews = List<VendorReviewModel>.from(reviews);

    switch (_selectedSort) {
      case 'Newest':
        sortedReviews.sort(
          (a, b) => b.createdDate.compareTo(a.createdDate),
        );
        break;

      case 'Oldest':
        sortedReviews.sort(
          (a, b) => a.createdDate.compareTo(b.createdDate),
        );
        break;

      case 'Highest Rating':
        sortedReviews.sort(
          (a, b) => b.rating.compareTo(a.rating),
        );
        break;

      case 'Lowest Rating':
        sortedReviews.sort(
          (a, b) => a.rating.compareTo(b.rating),
        );
        break;
    }

    return sortedReviews;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),

      body: Consumer2<ReviewViewModel, UserViewModel>(
        builder: (context, reviewViewModel, userViewModel, child) {
          // ==========================================================
          // LOADING
          // ==========================================================

          if (reviewViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ==========================================================
          // ERROR
          // ==========================================================

          if (reviewViewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  reviewViewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ),
            );
          }

          final allReviews = reviewViewModel.vendorReviews;

          // ==========================================================
          // NO REVIEWS
          // ==========================================================

          if (allReviews.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 52,
                      color: colorScheme.primary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'No reviews yet',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Be the first to share your experience.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    if (!widget.adminMode) ...[
                      const SizedBox(height: 20),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddVendorReviewView(
                                vendorId: widget.vendorId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.rate_review_outlined,
                        ),
                        label: const Text(
                          'Be the first to review',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          // ==========================================================
          // SORT REVIEWS
          // ==========================================================

          final reviews = _sortReviews(allReviews);

          // ==========================================================
          // REVIEWS
          // ==========================================================

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24,
            ),
            children: [
              // ========================================================
              // RATING SUMMARY
              // ========================================================

              _RatingSummary(
                reviews: allReviews,
                vendorId: widget.vendorId,
                adminMode: widget.adminMode,
                showSeeAllButton: false,
              ),

              // ========================================================
              // LEAVE A REVIEW
              // ========================================================

              if (!widget.adminMode) ...[
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddVendorReviewView(
                            vendorId: widget.vendorId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.rate_review_outlined,
                    ),
                    label: const Text('Leave a Review'),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ========================================================
              // CUSTOMER REVIEWS HEADING + SORT
              // ========================================================

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'People\'s Reviews',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSort,

                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                      ),

                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),

                      items: AppLists.reviewSortOptions.map(
                        (option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        },
                      ).toList(),

                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedSort = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ========================================================
              // REVIEW CARDS
              // ========================================================

              ...reviews.map((review) {
                final user = userViewModel.getUser(
                  review.userId,
                );

                return _ReviewCard(
                  review: review,
                  username: user?.username ?? 'Unknown User',
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

// ======================================================================
// RATING SUMMARY
// ======================================================================

class _RatingSummary extends StatelessWidget {
  final List<VendorReviewModel> reviews;
  final String vendorId;
  final bool adminMode;
  final bool showSeeAllButton;

  const _RatingSummary({
    required this.reviews,
    required this.vendorId,
    required this.adminMode,
    this.showSeeAllButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);

    final average = total / reviews.length;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // ==========================================================
            // RATING + BREAKDOWN
            // ==========================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========================================================
                // OVERALL RATING
                // ========================================================
                SizedBox(
                  width: 105,
                  child: Column(
                    children: [
                      Text(
                        average.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < average.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 17,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '${reviews.length} '
                        '${reviews.length == 1 ? 'review' : 'reviews'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 18),

                // ========================================================
                // RATING BREAKDOWN
                // ========================================================
                Expanded(
                  child: Column(
                    children: [
                      _RatingRow(
                        label: 'Taste',
                        value: _average(reviews, (review) => review.taste),
                      ),

                      _RatingRow(
                        label: 'Value',
                        value: _average(reviews, (review) => review.value),
                      ),

                      _RatingRow(
                        label: 'Portion',
                        value: _average(reviews, (review) => review.portion),
                      ),

                      _RatingRow(
                        label: 'Service',
                        value: _average(reviews, (review) => review.service),
                      ),

                      _RatingRow(
                        label: 'Clean',
                        value: _average(
                          reviews,
                          (review) => review.cleanliness,
                        ),
                      ),

                      _RatingRow(
                        label: 'Wait',
                        value: _average(
                          reviews,
                          (review) => review.waitingTime,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ==========================================================
              // SEE WHAT PEOPLE ARE SAYING
              // ==========================================================
            ),
            if (!adminMode && showSeeAllButton) ...[
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VendorAllReviewsView(
                          vendorId: vendorId,
                          adminMode: adminMode,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.forum_outlined, size: 19),
                  label: const Text('See reviews'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _average(
    List<VendorReviewModel> reviews,
    int? Function(VendorReviewModel) getRating,
  ) {
    final ratings = reviews.map(getRating).whereType<int>().toList();

    if (ratings.isEmpty) {
      return 0;
    }

    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}

// ======================================================================
// RATING ROW
// ======================================================================

class _RatingRow extends StatelessWidget {
  final String label;
  final double value;

  const _RatingRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: value / 5, minHeight: 6),
            ),
          ),

          const SizedBox(width: 6),

          SizedBox(
            width: 25,
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// REVIEW CARD
// ======================================================================

class _ReviewCard extends StatelessWidget {
  final VendorReviewModel review;
  final String username;

  const _ReviewCard({
    required this.review,
    required this.username,
  });

  // ======================================================================
  // DATE FORMAT
  // ======================================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // REVIEWER + RATING
            // ==========================================================

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ------------------------------------------------------
                // USER
                // ------------------------------------------------------

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileView(
                            userId: review.userId,
                          ),
                        ),
                      );
                    },

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 19,

                          backgroundColor:
                              colorScheme.primaryContainer,

                          child: Icon(
                            Icons.person,
                            size: 21,
                            color:
                                colorScheme.onPrimaryContainer,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Flexible(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // ------------------------------------------------
                              // USERNAME
                              // ------------------------------------------------

                              Text(
                                username,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 2),

                              // ------------------------------------------------
                              // CREATED DATE
                              // ------------------------------------------------

                              Text(
                                _formatDate(review.createdDate),
                                style:
                                    textTheme.bodySmall?.copyWith(
                                  color:
                                      colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------------
                // OVERALL RATING
                // ------------------------------------------------------

                Row(
                  mainAxisSize: MainAxisSize.min,

                  children: List.generate(
                    5,

                    (index) => Icon(
                      index < review.rating
                          ? Icons.star
                          : Icons.star_border,

                      size: 17,

                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            // ==========================================================
            // REVIEW TEXT
            // ==========================================================

            if (review.reviewText != null &&
                review.reviewText!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),

              Text(
                review.reviewText!,

                style: textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
              ),
            ],

            // ==========================================================
            // DETAILED RATINGS
            // ==========================================================

            if (_hasDetailedRatings()) ...[
              const SizedBox(height: 14),

              Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),

              const SizedBox(height: 12),

              _DetailedRatings(
                review: review,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ======================================================================
  // CHECK DETAILED RATINGS
  // ======================================================================

  bool _hasDetailedRatings() {
    return review.taste != null ||
        review.value != null ||
        review.portion != null ||
        review.service != null ||
        review.cleanliness != null ||
        review.waitingTime != null;
  }
}


// ======================================================================
// DETAILED RATINGS
// ======================================================================

class _DetailedRatings extends StatelessWidget {
  final VendorReviewModel review;

  const _DetailedRatings({required this.review});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final ratings = <String, int?>{
      'Taste': review.taste,
      'Value': review.value,
      'Portion': review.portion,
      'Service': review.service,
      'Cleanliness': review.cleanliness,
      'Waiting': review.waitingTime,
    };

    final available = ratings.entries
        .where((entry) => entry.value != null)
        .toList();

    if (available.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: available.map((entry) {
        final rating = entry.value!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.key, style: const TextStyle(fontSize: 11)),

              const SizedBox(width: 5),

              Text(
                '$rating',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 2),

              Icon(Icons.star, size: 13, color: colorScheme.primary),
            ],
          ),
        );
      }).toList(),
    );
  }
}
