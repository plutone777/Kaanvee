import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_application/models/discussion_answer.dart';
import 'package:fyp_application/viewmodels/discussion_viewmodel.dart';
import 'package:fyp_application/widgets/discussion_recommendation.dart';
import 'package:provider/provider.dart';

class AddAnswerView extends StatefulWidget {
  final String discussionId;

  const AddAnswerView({
    super.key,
    required this.discussionId,
  });

  @override
  State<AddAnswerView> createState() =>
      _AddAnswerViewState();
}

class _AddAnswerViewState extends State<AddAnswerView> {
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();
  String? _selectedVendorId;
  String? _selectedMenuId;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _addAnswer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to post an answer.'),
        ),
      );
      return;
    }

    final answerId = FirebaseFirestore.instance
        .collection('Discussion Answer')
        .doc()
        .id;

    final answer = DiscussionAnswerModel(
      answerId: answerId,
      discussionId: widget.discussionId,
      userId: user.uid,
      answerText: _answerController.text.trim(),
      createdDate: DateTime.now(),
      recommendedVendorId: _selectedVendorId,
      recommendedMenuId: _selectedMenuId,
      likes: 0,
    );

    final viewModel = context.read<DiscussionViewModel>();

    final success = await viewModel.addAnswer(answer);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answer posted successfully.'),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ??
                'Failed to post answer.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Answer'),
      ),

      body: Consumer<DiscussionViewModel>(
        builder: (context, viewModel, child) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },

            child: Form(
              key: _formKey,

              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  const Text(
                    'Your Answer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Share your thoughts or answer the question.',
                  ),

                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _answerController,
                    maxLines: 8,
                    maxLength: 1000,

                    decoration: const InputDecoration(
                      labelText: 'Answer',
                      hintText: 'Write your answer...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter an answer.';
                      }

                      return null;
                    },
                  ),

                  RecommendationSelector(
                    selectedVendorId: _selectedVendorId,
                    selectedMenuId: _selectedMenuId,

                    onVendorSelected: (value) {
                      setState(() {
                        _selectedVendorId = value;
                      });
                    },

                    onMenuSelected: (value) {
                      setState(() {
                        _selectedMenuId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,

                    child: ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : _addAnswer,

                      child: viewModel.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Post Answer',
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