import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_application/constants/lists.dart';
import 'package:fyp_application/models/discussion.dart';
import 'package:fyp_application/models/discussion_answer.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/viewmodels/discussion_viewmodel.dart';
import 'package:fyp_application/viewmodels/menu_viewmodel.dart';
import 'package:fyp_application/viewmodels/user_viewmodel.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';
import 'package:fyp_application/views/discussion_add_answer_view.dart';
import 'package:fyp_application/views/disucssion_create_view.dart';
import 'package:fyp_application/views/profile_view.dart';
import 'package:fyp_application/views/vendor_details_view.dart';
import 'package:fyp_application/widgets/report_dialog.dart';
import 'package:provider/provider.dart';

class DiscussionDetailsView extends StatefulWidget {
  final DiscussionModel discussion;
  final bool adminMode;

  const DiscussionDetailsView({
    super.key,
    required this.discussion,
    this.adminMode = false,
  });

  @override
  State<DiscussionDetailsView> createState() => _DiscussionDetailsViewState();
}

class _DiscussionDetailsViewState extends State<DiscussionDetailsView> {
  // ============================================================
  // ANSWER SORTING
  // ============================================================

  String _selectedAnswerSort = AppLists.answerSortOptions.first;

  // ============================================================
  // SORT ANSWERS
  // ============================================================

  List<DiscussionAnswerModel> _sortAnswers(
    List<DiscussionAnswerModel> answers,
  ) {
    final sortedAnswers = List<DiscussionAnswerModel>.from(answers);

    switch (_selectedAnswerSort) {
      case 'Oldest':
        sortedAnswers.sort(
          (a, b) => a.createdDate.compareTo(b.createdDate),
        );
        break;

      case 'Most Popular':
        sortedAnswers.sort(
          (a, b) => b.likes.compareTo(a.likes),
        );
        break;

      case 'Newest':
      default:
        sortedAnswers.sort(
          (a, b) => b.createdDate.compareTo(a.createdDate),
        );
        break;
    }

    return sortedAnswers;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscussionViewModel>().loadAnswers(
        widget.discussion.discussionId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAnswerView(
                discussionId: widget.discussion.discussionId,
              ),
            ),
          );
        },
        icon: const Icon(Icons.reply_outlined),
        label: const Text('Post Answer'),
      ),

      body: Consumer<DiscussionViewModel>(
        builder: (context, viewModel, child) {
          // ============================================================
          // SORTED ANSWERS
          // ============================================================

          final sortedAnswers = _sortAnswers(viewModel.answers);

          return RefreshIndicator(
            onRefresh: () {
              return viewModel.loadAnswers(
                widget.discussion.discussionId,
              );
            },

            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                100,
              ),

              children: [
                // ========================================================
                // DISCUSSION POST
                // ========================================================

                _DiscussionPost(
                  discussion: widget.discussion,
                  adminMode: widget.adminMode,
                ),

                const SizedBox(height: 28),

                // ========================================================
                // ANSWERS HEADING
                // ========================================================

                Row(
                  children: [
                    Text(
                      'Answers',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      '${viewModel.answers.length}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ========================================================
                // LOADING
                // ========================================================

                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )

                // ========================================================
                // ERROR
                // ========================================================

                else if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                    ),
                    child: Center(
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )

                // ========================================================
                // NO ANSWERS
                // ========================================================

                else if (viewModel.answers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 32,
                    ),
                    child: Center(
                      child: Text(
                        'No answers yet.\nBe the first to answer!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )

                // ========================================================
                // ANSWERS
                // ========================================================
                else ...[
                  // ------------------------------------------------------
                  // SORT DROPDOWN
                  // ------------------------------------------------------

                  DropdownButtonFormField<String>(
                    initialValue: _selectedAnswerSort,
                    isExpanded: true,

                    decoration: const InputDecoration(
                      labelText: 'Sort answers',
                      prefixIcon: Icon(
                        Icons.sort,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),

                    items: AppLists.answerSortOptions.map(
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
                        _selectedAnswerSort = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // ------------------------------------------------------
                  // SORTED ANSWER CARDS
                  // ------------------------------------------------------

                  ...sortedAnswers.map(
                    (answer) => _AnswerCard(
                      answer: answer,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// DISCUSSION POST
// ============================================================================

class _DiscussionPost extends StatefulWidget {
  final DiscussionModel discussion;
  final bool adminMode;

  const _DiscussionPost({
    required this.discussion,
    this.adminMode = false,
  });

  @override
  State<_DiscussionPost> createState() => _DiscussionPostState();
}

class _DiscussionPostState extends State<_DiscussionPost> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadUser(
        widget.discussion.userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        final user = userViewModel.getUser(
          widget.discussion.userId,
        );

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ========================================================
                // USER + DATE
                // ========================================================

                _UserHeader(
  username: user?.username ?? 'Loading...',
  date: widget.discussion.createdDate,
  userId: widget.discussion.userId,
  fromDiscussion: true,

  trailing: widget.adminMode
      ? IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete Discussion',
          onPressed: () {
            _showDeleteConfirmation(context);
          },
        )
      : PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey.shade600,
                          ),

                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CreateDiscussionView(
                                    discussion:
                                        widget.discussion,
                                  ),
                                ),
                              );
                            }

                            if (value == 'report') {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    ReportDialog(
                                  reportType: 'Discussion',
                                  targetId: widget
                                      .discussion
                                      .discussionId,
                                ),
                              );
                            }
                          },

                          itemBuilder: (context) {
                            final currentUser =
                                FirebaseAuth
                                    .instance
                                    .currentUser;

                            final isOwner =
                                currentUser?.uid ==
                                widget.discussion.userId;

                            if (isOwner) {
                              return const [
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .edit_outlined,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                              ];
                            }

                            return const [
                              PopupMenuItem<String>(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .flag_outlined,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Report'),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // ========================================================
                // TITLE
                // ========================================================

                Text(
                  widget.discussion.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // ========================================================
                // DESCRIPTION
                // ========================================================

                Text(
                  widget.discussion.description,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Discussion?'),

          content: const Text(
            'Are you sure you want to delete this discussion? '
            'All answers under this discussion will also be deleted.',
          ),

          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true ||
        !context.mounted) {
      return;
    }

    final viewModel =
        context.read<DiscussionViewModel>();

    final success =
        await viewModel.deleteDiscussion(
      widget.discussion.discussionId,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Discussion deleted successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ??
                'Failed to delete discussion.',
          ),
        ),
      );
    }
  }
}

// ============================================================================
// ANSWER CARD
// ============================================================================

class _AnswerCard extends StatefulWidget {
  final DiscussionAnswerModel answer;

  const _AnswerCard({
    required this.answer,
  });

  @override
  State<_AnswerCard> createState() =>
      _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadUser(
        widget.answer.userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<UserViewModel>(
      builder: (
        context,
        userViewModel,
        child,
      ) {
        final user = userViewModel.getUser(
          widget.answer.userId,
        );

        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ========================================================
                // USER + DATE
                // ========================================================

                _UserHeader(
                  username:
                      user?.username ?? 'Loading...',
                  date: widget.answer.createdDate,
                  userId: widget.answer.userId,
                ),

                const SizedBox(height: 16),

                // ========================================================
                // ANSWER
                // ========================================================

                Text(
                  widget.answer.answerText,
                  style: textTheme.bodyMedium,
                ),

                // ========================================================
                // RECOMMENDATION
                // ========================================================

                if (widget.answer
                            .recommendedVendorId !=
                        null ||
                    widget.answer
                            .recommendedMenuId !=
                        null) ...[
                  const SizedBox(height: 14),

                  _RecommendationCard(
                    answer: widget.answer,
                  ),
                ],

                const SizedBox(height: 10),

                // ========================================================
                // LIKE
                // ========================================================

                Consumer<DiscussionViewModel>(
                  builder: (
                    context,
                    viewModel,
                    child,
                  ) {
                    final currentUser =
                        FirebaseAuth.instance
                            .currentUser;

                    final isLiked =
                        currentUser != null &&
                        widget.answer.likedBy
                            .contains(
                          currentUser.uid,
                        );

                    return Row(
                      children: [
                        IconButton(
                          visualDensity:
                              VisualDensity.compact,
                          padding: EdgeInsets.zero,

                          onPressed: () async {
                            await viewModel
                                .likeAnswer(
                              widget.answer.answerId,
                            );
                          },

                          icon: Icon(
                            isLiked
                                ? Icons.thumb_up
                                : Icons
                                    .thumb_up_outlined,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          widget.answer.likes
                              .toString(),
                          style:
                              textTheme.bodyMedium,
                        ),
                      ],
                    );
                  },
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
// USER HEADER
// ============================================================================

class _UserHeader extends StatelessWidget {
  final String username;
  final DateTime date;
  final String userId;
  final Widget? trailing;
  final bool fromDiscussion;

  const _UserHeader({
    required this.username,
    required this.date,
    required this.userId,
    this.trailing,
    this.fromDiscussion = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileView(
                  userId: userId,
                  fromDiscussion: fromDiscussion,
                ),
              ),
            );
          },

          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                child: Icon(
                  Icons.person_outline,
                  size: 18,
                ),
              ),

              const SizedBox(width: 8),

              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 160,
                ),

                child: Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        Text(
          _formatDate(date),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
// ============================================================================
// RECOMMENDATION CARD
// ============================================================================

class _RecommendationCard extends StatelessWidget {
  final DiscussionAnswerModel answer;

  const _RecommendationCard({
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // MENU RECOMMENDATION
    // ==========================================================

    if (answer.recommendedMenuId != null) {
      return FutureBuilder<MenuModel?>(
        future: context
            .read<MenuViewModel>()
            .getMenuItem(
              answer.recommendedMenuId!,
            ),

        builder: (
          context,
          menuSnapshot,
        ) {
          if (menuSnapshot.connectionState ==
              ConnectionState.waiting) {
            return _loadingCard();
          }

          final menu =
              menuSnapshot.data;

          if (menu == null) {
            return const SizedBox.shrink();
          }

          return FutureBuilder<VendorModel?>(
            future: context
                .read<VendorViewModel>()
                .getVendor(
                  menu.vendorId,
                ),

            builder: (
              context,
              vendorSnapshot,
            ) {
              if (vendorSnapshot
                      .connectionState ==
                  ConnectionState.waiting) {
                return _loadingCard();
              }

              final vendor =
                  vendorSnapshot.data;

              if (vendor == null) {
                return const SizedBox.shrink();
              }

              return _buildRecommendationCard(
                context,

                title: menu.itemName,

                subtitle: vendor.name,

                imageUrl:
                    menu.imageUrls.isNotEmpty
                        ? menu.imageUrls.first
                        : null,

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
              );
            },
          );
        },
      );
    }

    // ==========================================================
    // VENDOR RECOMMENDATION
    // ==========================================================

    if (answer.recommendedVendorId != null) {
      return FutureBuilder<VendorModel?>(
        future: context
            .read<VendorViewModel>()
            .getVendor(
              answer.recommendedVendorId!,
            ),

        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return _loadingCard();
          }

          final vendor =
              snapshot.data;

          if (vendor == null) {
            return const SizedBox.shrink();
          }

          return _buildRecommendationCard(
            context,

            title: vendor.name,

            imageUrl:
                vendor.imageUrls.isNotEmpty
                    ? vendor.imageUrls.first
                    : null,

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
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: onTap,

        child: Row(
          children: [
            // ========================================================
            // IMAGE
            // ========================================================

            SizedBox(
              width: 85,
              height: 85,

              child: imageUrl != null &&
                      imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,

                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          color: colorScheme
                              .surfaceContainerHighest,

                          child: const Icon(
                            Icons
                                .image_not_supported_outlined,
                          ),
                        );
                      },

                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress ==
                            null) {
                          return child;
                        }

                        return Container(
                          color: colorScheme
                              .surfaceContainerHighest,

                          child:
                              const Center(
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: colorScheme
                          .surfaceContainerHighest,

                      child: const Icon(
                        Icons.restaurant_outlined,
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // ========================================================
            // DETAILS
            // ========================================================

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const Padding(
              padding:
                  EdgeInsets.only(right: 12),

              child: Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingCard() {
    return const Card(
      margin: EdgeInsets.zero,

      child: SizedBox(
        height: 85,

        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}