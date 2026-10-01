import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_application/models/report.dart';
import 'package:fyp_application/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

class ReportDialog extends StatefulWidget {
  final String reportType;
  final String targetId;
  final String? imageUrl;

  const ReportDialog({
    super.key,
    required this.reportType,
    required this.targetId,
    this.imageUrl,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a report.'),
        ),
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final reportId = FirebaseFirestore.instance
        .collection('Reports')
        .doc()
        .id;

    final report = ReportModel(
      reportId: reportId,
      reportedBy: user.uid,
      reportType: widget.reportType,
      targetId: widget.targetId,
      imageUrl: widget.imageUrl,
      reason: _reasonController.text.trim(),
      status: 'Pending',
      createdDate: DateTime.now(),
    );

    final success = await context
        .read<ReportViewModel>()
        .createReport(report);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pop(context, success);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Report submitted successfully.'
              : 'Failed to submit report.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Report ${widget.reportType}',
            ),
          ),
        ],
      ),

      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _reasonController,
          maxLength: 100,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Tell us why you are reporting this...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please provide a reason';
            }

            return null;
          },
        ),
      ),

      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Submit Report'),
            ),

            const SizedBox(height: 8),

            OutlinedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
}
