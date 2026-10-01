import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_application/models/discussion.dart';
import 'package:fyp_application/viewmodels/discussion_viewmodel.dart';
import 'package:provider/provider.dart';

class CreateDiscussionView extends StatefulWidget {
  final DiscussionModel? discussion;

  const CreateDiscussionView({
    super.key,
    this.discussion,
  });

  bool get isEditing => discussion != null;

  @override
  State<CreateDiscussionView> createState() =>
      _CreateDiscussionViewState();
}

class _CreateDiscussionViewState
    extends State<CreateDiscussionView> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.discussion != null) {
      _titleController.text =
          widget.discussion!.title;

      _descriptionController.text =
          widget.discussion!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveDiscussion() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in.'),
        ),
      );
      return;
    }

    final viewModel =
        context.read<DiscussionViewModel>();

    final title = _titleController.text.trim();
    final description =
        _descriptionController.text.trim();

    bool success;

    if (widget.isEditing) {
      final oldDiscussion = widget.discussion!;

      final updatedDiscussion = DiscussionModel(
        discussionId: oldDiscussion.discussionId,
        userId: oldDiscussion.userId,
        title: title,
        description: description,
        createdDate: oldDiscussion.createdDate,
        lastUpdated: DateTime.now(),
        status: oldDiscussion.status,
      );

      success = await viewModel.updateDiscussion(
        updatedDiscussion,
      );
    } else {
      final now = DateTime.now();

      final discussion = DiscussionModel(
        discussionId: '',
        userId: user.uid,
        title: title,
        description: description,
        createdDate: now,
        lastUpdated: now,
        status: 'Active',
      );

      success = await viewModel.createDiscussion(
        discussion,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Discussion updated successfully.'
                : 'Discussion created successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ??
                (widget.isEditing
                    ? 'Failed to update discussion.'
                    : 'Failed to create discussion.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme =
        Theme.of(context).colorScheme;

    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Discussion'
              : 'Start a Discussion',
        ),
      ),

      body: Consumer<DiscussionViewModel>(
        builder: (context, viewModel, child) {
          final isLoading = viewModel.isLoading;

          return Form(
            key: _formKey,

            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                32,
              ),

              children: [

                const SizedBox(height: 6),

                // =========================================================
                // TITLE
                // =========================================================

                Text(
                  'Title',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _titleController,
                  enabled: !isLoading,
                  maxLength: 100,
                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    hintText:
                        'What do you want to discuss?',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.title_outlined,
                    ),
                  ),

                  validator: (value) {
                    final title =
                        value?.trim() ?? '';

                    if (title.isEmpty) {
                      return 'Please enter a title.';
                    }

                    if (title.length < 3) {
                      return 'Title must be at least 3 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // =========================================================
                // DESCRIPTION
                // =========================================================

                Text(
                  'Description',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                      _descriptionController,
                  enabled: !isLoading,
                  maxLines: 7,
                  maxLength: 1000,
                  textInputAction:
                      TextInputAction.newline,

                  decoration: const InputDecoration(
                    hintText:
                        'Add a description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        bottom: 100,
                      ),
                      child: Icon(
                        Icons.description_outlined,
                      ),
                    ),
                  ),

                  validator: (value) {
                    final description =
                        value?.trim() ?? '';

                    if (description.isEmpty) {
                      return 'Please enter a description.';
                    }

                    if (description.length < 10) {
                      return 'Enter at least 10 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // =========================================================
                // BUTTON
                // =========================================================

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                        isLoading ? null : _saveDiscussion,

                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isEditing
                                ? Icons.save_outlined
                                : Icons.send_outlined,
                          ),

                    label: Text(
                      isLoading
                          ? isEditing
                              ? 'Saving...'
                              : 'Posting...'
                          : isEditing
                              ? 'Save Changes'
                              : 'Post Discussion',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}