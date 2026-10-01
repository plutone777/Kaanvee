import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_application/models/vendor_review.dart';
import 'package:fyp_application/utils/points_animation_utils.dart';
import 'package:fyp_application/viewmodels/review_viewmodel.dart';
import 'package:provider/provider.dart';

class AddVendorReviewView extends StatefulWidget {
  final String vendorId;

  const AddVendorReviewView({super.key, required this.vendorId});

  @override
  State<AddVendorReviewView> createState() => _AddVendorReviewViewState();
}

class _AddVendorReviewViewState extends State<AddVendorReviewView> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();

  int _rating = 0;
  int? _taste;
  int? _value;
  int? _portion;
  int? _service;
  int? _cleanliness;
  int? _waitingTime;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // ======================================================================
  // SUBMIT REVIEW
  // ======================================================================

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating == 0) {
      _showMessage('Please select an overall rating.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('You must be logged in to leave a review.');
      return;
    }

    final now = DateTime.now();

    final reviewId = FirebaseFirestore.instance
        .collection('VendorReviews')
        .doc()
        .id;

    final review = VendorReviewModel(
      vendorReviewId: reviewId,
      vendorId: widget.vendorId,
      userId: user.uid,
      rating: _rating,
      reviewText: _reviewController.text.trim(),
      createdDate: now,
      lastUpdated: now,
      taste: _taste,
      value: _value,
      portion: _portion,
      service: _service,
      cleanliness: _cleanliness,
      waitingTime: _waitingTime,
    );

    final viewModel = context.read<ReviewViewModel>();

    final success = await viewModel.addVendorReview(review);

    if (!mounted) return;

    if (success) {
      showPointsAnimation(context, 5);

      await Future.delayed(const Duration(milliseconds: 1300));

      if (!mounted) return;

      _showMessage('Review submitted successfully.');
      Navigator.pop(context, true);
    } else {
      _showMessage(viewModel.errorMessage ?? 'Failed to submit review.');
    }
  }

  // ======================================================================
  // MESSAGE
  // ======================================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ======================================================================
  // OVERALL RATING
  // ======================================================================

  Widget _ratingStars({
    required int rating,
    required ValueChanged<int> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        final selected = value <= rating;

        return IconButton(
          onPressed: () {
            onChanged(value);
          },
          splashRadius: 24,
          icon: Icon(
            selected ? Icons.star_rounded : Icons.star_border_rounded,
            size: 40,
            color: selected ? colorScheme.primary : colorScheme.outline,
          ),
        );
      }),
    );
  }

  // ======================================================================
  // CATEGORY RATING
  // ======================================================================

  Widget _categoryRating({
    required String label,
    required int? value,
    required ValueChanged<int> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final rating = index + 1;
              final selected = rating <= (value ?? 0);

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  onChanged(rating);
                },
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    selected ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 22,
                    color: selected ? colorScheme.primary : colorScheme.outline,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ======================================================================
  // BUILD
  // ======================================================================

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),

      body: Consumer<ReviewViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======================================================
                  // OVERALL RATING
                  // ======================================================
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Overall Rating',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'How would you rate your overall experience?',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 10),

                          _ratingStars(
                            rating: _rating,
                            onChanged: (value) {
                              setState(() {
                                _rating = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // REVIEW
                  // ======================================================
                  Text(
                    'Your Review',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _reviewController,
                    maxLines: 5,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience',
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================================================
                  // DETAILED RATINGS
                  // ======================================================
                  Text(
                    'Rate Your Experience',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Column(
                        children: [
                          _categoryRating(
                            label: 'Taste',
                            value: _taste,
                            onChanged: (value) {
                              setState(() {
                                _taste = value;
                              });
                            },
                          ),

                          _categoryRating(
                            label: 'Value for Money',
                            value: _value,
                            onChanged: (value) {
                              setState(() {
                                _value = value;
                              });
                            },
                          ),

                          _categoryRating(
                            label: 'Portion',
                            value: _portion,
                            onChanged: (value) {
                              setState(() {
                                _portion = value;
                              });
                            },
                          ),

                          _categoryRating(
                            label: 'Service',
                            value: _service,
                            onChanged: (value) {
                              setState(() {
                                _service = value;
                              });
                            },
                          ),

                          _categoryRating(
                            label: 'Cleanliness',
                            value: _cleanliness,
                            onChanged: (value) {
                              setState(() {
                                _cleanliness = value;
                              });
                            },
                          ),

                          _categoryRating(
                            label: 'Waiting Time',
                            value: _waitingTime,
                            onChanged: (value) {
                              setState(() {
                                _waitingTime = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ======================================================
                  // SUBMIT
                  // ======================================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _submitReview,
                      child: viewModel.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Submit Review',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
