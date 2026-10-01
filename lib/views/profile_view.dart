import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_application/models/user.dart';
import 'package:fyp_application/viewmodels/profile_viewmodel.dart';
import 'package:fyp_application/viewmodels/user_viewmodel.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';
import 'package:fyp_application/views/discussion_details_view.dart';
import 'package:fyp_application/views/settings_view.dart';
import 'package:fyp_application/views/vendor_details_view.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  final String userId;

  // True when the profile was opened from DiscussionDetailsView.
  final bool fromDiscussion;

  const ProfileView({
    super.key,
    required this.userId,
    this.fromDiscussion = false,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _showAllReviews = false;
  bool _showAllDiscussions = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadUser(widget.userId);
      context.read<ProfileViewModel>().loadProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final currentUser = FirebaseAuth.instance.currentUser;

    final isOwnProfile =
        currentUser != null && currentUser.uid == widget.userId;

    return Consumer2<UserViewModel, ProfileViewModel>(
      builder: (
        context,
        userViewModel,
        profileViewModel,
        child,
      ) {
        final UserModel? user =
            userViewModel.getUser(widget.userId);

        // ==========================================================
        // LOADING
        // ==========================================================

        if (userViewModel.isLoading ||
            profileViewModel.isLoading) {
          return Scaffold(
            appBar: widget.fromDiscussion
                ? AppBar(
                    title: const Text('Profile'),
                  )
                : null,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ==========================================================
        // ERROR
        // ==========================================================

        if (profileViewModel.errorMessage != null) {
          return Scaffold(
            appBar: widget.fromDiscussion
                ? AppBar(
                    title: const Text('Profile'),
                  )
                : null,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  profileViewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
              ),
            ),
          );
        }

        // ==========================================================
        // USER NOT FOUND
        // ==========================================================

        if (user == null) {
          return Scaffold(
            appBar: widget.fromDiscussion
                ? AppBar(
                    title: const Text('Profile'),
                  )
                : null,
            body: const Center(
              child: Text('User not found.'),
            ),
          );
        }

        final vendorReviews =
            profileViewModel.vendorReviews;

        final totalReviews =
            vendorReviews.length;

        final allReviews = [
          ...vendorReviews,
        ];

        final displayedReviews = _showAllReviews
            ? allReviews
            : allReviews.take(3).toList();

        final discussions =
            profileViewModel.discussions;

        final displayedDiscussions = _showAllDiscussions
            ? discussions
            : discussions.take(3).toList();

        return Scaffold(
          // ==========================================================
          // APP BAR
          // Only shown when coming from DiscussionDetailsView.
          // ==========================================================

          appBar: widget.fromDiscussion
              ? AppBar(
                  title: const Text('Profile'),
                )
              : null,

          body: RefreshIndicator(
            onRefresh: () async {
              await userViewModel.loadUser(
                widget.userId,
                forceRefresh: true,
              );

              await profileViewModel.loadProfile(
                widget.userId,
              );
            },

            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                16,
                24,
                16,
                32,
              ),

              children: [
                // ====================================================
                // PROFILE HEADER
                // ====================================================

                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            colorScheme.primaryContainer,

                        child: Icon(
                          Icons.person_outline,
                          size: 48,
                          color:
                              colorScheme.onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        user.username,
                        textAlign: TextAlign.center,

                        style:
                            textTheme.headlineSmall?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color:
                              colorScheme.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: colorScheme
                                  .onPrimaryContainer,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              '${user.points} points',

                              style: textTheme
                                  .bodySmall
                                  ?.copyWith(
                                fontWeight:
                                    FontWeight.w600,
                                color: colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // SETTINGS
                      // ==================================================

                      if (isOwnProfile) ...[
                        const SizedBox(height: 14),

                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SettingsView(
                                  user: user,
                                ),
                              ),
                            );
                          },

                          icon: const Icon(
                            Icons.settings_outlined,
                            size: 18,
                          ),

                          label:
                              const Text('Settings'),

                          style: OutlinedButton
                              .styleFrom(
                            minimumSize:
                                Size.zero,

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),

                            tapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ====================================================
                // REVIEWS
                // ====================================================

                _SectionHeader(
                  title: 'Reviews',
                  count: totalReviews,
                  showButton:
                      totalReviews > 3,
                  isExpanded:
                      _showAllReviews,

                  onPressed: () {
                    setState(() {
                      _showAllReviews =
                          !_showAllReviews;
                    });
                  },
                ),

                const SizedBox(height: 12),

                if (totalReviews == 0)
                  const _EmptySection(
                    icon:
                        Icons.rate_review_outlined,
                    message:
                        'No reviews yet.',
                  )
                else
                  ...displayedReviews.map(
                    (review) {
                      final isVendorReview =
                          vendorReviews
                              .contains(review);

                      if (isVendorReview) {
                        return _VendorReviewCard(
                          review: review,
                        );
                      }

                      return _MenuReviewCard(
                        review: review,
                      );
                    },
                  ),

                const SizedBox(height: 28),

                // ====================================================
                // DISCUSSIONS
                // ====================================================

                _SectionHeader(
                  title: 'Discussion Posts',
                  count: discussions.length,
                  showButton:
                      discussions.length > 3,
                  isExpanded:
                      _showAllDiscussions,

                  onPressed: () {
                    setState(() {
                      _showAllDiscussions =
                          !_showAllDiscussions;
                    });
                  },
                ),

                const SizedBox(height: 12),

                if (discussions.isEmpty)
                  const _EmptySection(
                    icon:
                        Icons.forum_outlined,
                    message:
                        'No discussion posts yet.',
                  )
                else
                  ...displayedDiscussions.map(
                    (discussion) => Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),

                      clipBehavior:
                          Clip.antiAlias,

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        leading: CircleAvatar(
                          backgroundColor:
                              colorScheme
                                  .secondaryContainer,

                          child: Icon(
                            Icons
                                .forum_outlined,
                            color: colorScheme
                                .onSecondaryContainer,
                          ),
                        ),

                        title: Text(
                          discussion.title,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,

                          style: textTheme
                              .titleSmall
                              ?.copyWith(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        subtitle: Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 4,
                          ),

                          child: Text(
                            discussion.description,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,

                            style: textTheme
                                .bodySmall
                                ?.copyWith(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),

                        trailing: Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          size: 15,
                          color: colorScheme
                              .onSurfaceVariant,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DiscussionDetailsView(
                                discussion:
                                    discussion,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool showButton;
  final bool isExpanded;
  final VoidCallback onPressed;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.showButton,
    required this.isExpanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme;

    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: textTheme.titleLarge
              ?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 8),

        if (count > 0)
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),

            decoration: BoxDecoration(
              color: colorScheme
                  .surfaceContainerHighest,

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Text(
              '$count',

              style: textTheme.bodySmall
                  ?.copyWith(
                fontWeight:
                    FontWeight.w600,
                color: colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),

        const Spacer(),

        if (showButton)
          TextButton.icon(
            onPressed: onPressed,

            icon: Icon(
              isExpanded
                  ? Icons
                      .keyboard_arrow_up_rounded
                  : Icons
                      .keyboard_arrow_down_rounded,
              size: 18,
            ),

            label: Text(
              isExpanded
                  ? 'Show less'
                  : 'See all',
            ),

            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
              ),

              minimumSize: Size.zero,

              tapTargetSize:
                  MaterialTapTargetSize
                      .shrinkWrap,
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// VENDOR REVIEW
// ============================================================================

class _VendorReviewCard
    extends StatelessWidget {
  final dynamic review;

  const _VendorReviewCard({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme;

    final colorScheme =
        Theme.of(context).colorScheme;

    return FutureBuilder(
      future: context
          .read<VendorViewModel>()
          .getVendor(review.vendorId),

      builder: (context, snapshot) {
        final vendor = snapshot.data;

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Card(
            margin:
                EdgeInsets.only(bottom: 10),

            child: ListTile(
              leading: SizedBox(
                width: 40,
                height: 40,

                child: Center(
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),

              title:
                  Text('Loading review...'),
            ),
          );
        }

        if (vendor == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin:
              const EdgeInsets.only(bottom: 10),

          clipBehavior:
              Clip.antiAlias,

          child: ListTile(
            contentPadding:
                const EdgeInsets.all(14),

            leading: CircleAvatar(
              radius: 22,

              backgroundColor:
                  colorScheme.primaryContainer,

              backgroundImage:
                  vendor.imageUrls.isNotEmpty
                      ? NetworkImage(
                          vendor.imageUrls.first,
                        )
                      : null,

              child:
                  vendor.imageUrls.isEmpty
                      ? Icon(
                          Icons
                              .restaurant_outlined,
                          color: colorScheme
                              .onPrimaryContainer,
                        )
                      : null,
            ),

            title: Text(
              vendor.name,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,

              style: textTheme.titleSmall
                  ?.copyWith(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            subtitle: Padding(
              padding:
                  const EdgeInsets.only(
                top: 6,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  _RatingStars(
                    rating: review.rating,
                  ),

                  const SizedBox(height: 5),

                  Text(
                    review.reviewText !=
                                null &&
                            review.reviewText!
                                .isNotEmpty
                        ? review.reviewText!
                        : 'No written review.',

                    maxLines: 2,

                    overflow:
                        TextOverflow.ellipsis,

                    style: textTheme
                        .bodySmall
                        ?.copyWith(
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            trailing: const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              size: 15,
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      VendorDetailsView(
                    vendor: vendor,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================================
// MENU REVIEW
// ============================================================================

class _MenuReviewCard
    extends StatelessWidget {
  final dynamic review;

  const _MenuReviewCard({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme;

    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),

      clipBehavior:
          Clip.antiAlias,

      child: ListTile(
        contentPadding:
            const EdgeInsets.all(14),

        leading: CircleAvatar(
          radius: 22,

          backgroundColor:
              colorScheme.secondaryContainer,

          child: Icon(
            Icons
                .restaurant_menu_outlined,
            color: colorScheme
                .onSecondaryContainer,
          ),
        ),

        title: Text(
          'Menu Review',

          style: textTheme.titleSmall
              ?.copyWith(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(
            top: 6,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              _RatingStars(
                rating: review.rating,
              ),

              const SizedBox(height: 5),

              Text(
                review.reviewText !=
                            null &&
                        review.reviewText!
                            .isNotEmpty
                    ? review.reviewText!
                    : 'No written review.',

                maxLines: 2,

                overflow:
                    TextOverflow.ellipsis,

                style: textTheme
                    .bodySmall
                    ?.copyWith(
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// RATING STARS
// ============================================================================

class _RatingStars
    extends StatelessWidget {
  final int rating;

  const _RatingStars({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: List.generate(
        5,
        (index) => Icon(
          index < rating
              ? Icons.star_rounded
              : Icons.star_outline_rounded,

          size: 18,

          color: index < rating
              ? colorScheme.primary
              : colorScheme.outline,
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY SECTION
// ============================================================================

class _EmptySection
    extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptySection({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme =
        Theme.of(context).textTheme;

    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 20,
      ),

      decoration: BoxDecoration(
        color: colorScheme
            .surfaceContainerLowest,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color:
              colorScheme.outlineVariant,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: colorScheme.outline,
          ),

          const SizedBox(height: 10),

          Text(
            message,
            textAlign:
                TextAlign.center,

            style: textTheme.bodyMedium
                ?.copyWith(
              color: colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
