import 'package:flutter/material.dart';
import 'package:fyp_application/models/discussion.dart';
import 'package:fyp_application/viewmodels/discussion_viewmodel.dart';
import 'package:fyp_application/viewmodels/user_viewmodel.dart';
import 'package:fyp_application/views/discussion_details_view.dart';
import 'package:fyp_application/views/disucssion_create_view.dart';
import 'package:provider/provider.dart';

class DiscussionView extends StatefulWidget {
  final bool adminMode;

  const DiscussionView({
    super.key,
    this.adminMode = false,
  });

  @override
  State<DiscussionView> createState() => _DiscussionViewState();
}

class _DiscussionViewState extends State<DiscussionView> {
  // ==========================================================
  // SORT OPTION
  // ==========================================================

  String _selectedSort = 'Newest';

  // ==========================================================
  // SORT DISCUSSIONS
  // ==========================================================

  List<DiscussionModel> _sortDiscussions(
    List<DiscussionModel> discussions,
  ) {
    final sorted = List<DiscussionModel>.from(discussions);

    switch (_selectedSort) {
      case 'Oldest':
        sorted.sort(
          (a, b) => a.createdDate.compareTo(b.createdDate),
        );
        break;

      case 'Newest':
      default:
        sorted.sort(
          (a, b) => b.createdDate.compareTo(a.createdDate),
        );
        break;
    }

    return sorted;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscussionViewModel>().loadDiscussions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // ==========================================================
      // CREATE DISCUSSION BUTTON
      // ==========================================================

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateDiscussionView(),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),

      // ==========================================================
      // DISCUSSIONS
      // ==========================================================

      body: Consumer<DiscussionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.errorMessage != null) {
            return _ErrorState(
              message: viewModel.errorMessage!,
              onRetry: () {
                viewModel.loadDiscussions();
              },
            );
          }

          final discussions = _sortDiscussions(
            viewModel.discussions,
          );

          return RefreshIndicator(
            onRefresh: viewModel.loadDiscussions,

            child: viewModel.discussions.isEmpty
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      24,
                      16,
                      120,
                    ),
                    children: [
                      const SizedBox(height: 32),
                      const _EmptyState(),
                    ],
                  )
                : ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      24,
                      16,
                      120,
                    ),

                    // +1 for the sort dropdown
                    itemCount: discussions.length + 1,

                    itemBuilder: (context, index) {
                      // ==================================================
                      // SORT DROPDOWN
                      // ==================================================

                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sort_rounded,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                'Sort by',
                                style: textTheme.bodyMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child:
                                    DropdownButtonFormField<String>(
                                  value: _selectedSort,
                                  isExpanded: true,

                                  decoration:
                                      const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    border:
                                        OutlineInputBorder(),
                                  ),

                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Newest',
                                      child:
                                          Text('Newest'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Oldest',
                                      child:
                                          Text('Oldest'),
                                    ),
                                  ],

                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    setState(() {
                                      _selectedSort =
                                          value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ==================================================
                      // DISCUSSION
                      // ==================================================

                      final discussion =
                          discussions[index - 1];

                      return _DiscussionCard(
                        discussion: discussion,
                        adminMode: widget.adminMode,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

// ======================================================================
// DISCUSSION CARD
// ======================================================================

class _DiscussionCard extends StatelessWidget {
  final DiscussionModel discussion;
  final bool adminMode;

  const _DiscussionCard({
    required this.discussion,
    required this.adminMode,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<UserViewModel>(
      builder: (
        context,
        userViewModel,
        child,
      ) {
        final user = userViewModel.getUser(
          discussion.userId,
        );

        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          clipBehavior: Clip.antiAlias,

          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DiscussionDetailsView(
                    discussion: discussion,
                    adminMode: adminMode,
                  ),
                ),
              );
            },

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ====================================================
                  // TITLE
                  // ====================================================

                  Text(
                    discussion.title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,

                    style: textTheme.titleMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ====================================================
                  // DESCRIPTION
                  // ====================================================

                  Text(
                    discussion.description,
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,

                    style: textTheme.bodyMedium
                        ?.copyWith(
                      color: colorScheme
                          .onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ====================================================
                  // AUTHOR + DATE
                  // ====================================================

                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 17,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          user?.username ??
                              'Loading...',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,

                          style: textTheme
                              .bodySmall
                              ?.copyWith(
                            color: colorScheme
                                .onSurfaceVariant,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        _formatDate(
                          discussion.createdDate,
                        ),

                        style: textTheme
                            .bodySmall
                            ?.copyWith(
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 13,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ======================================================================
// EMPTY STATE
// ======================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48,
            color: colorScheme.outline,
          ),

          const SizedBox(height: 16),

          Text(
            'No discussions yet.',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Start a discussion and share your thoughts with the community.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// ERROR STATE
// ======================================================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error,
            ),

            const SizedBox(height: 16),

            Text(
              'Unable to load discussions',
              textAlign: TextAlign.center,

              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              message,
              textAlign: TextAlign.center,

              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}