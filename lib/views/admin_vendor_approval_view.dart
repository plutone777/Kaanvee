import 'package:flutter/material.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';
import 'package:fyp_application/widgets/vendor_info.dart';
import 'package:provider/provider.dart';

class VendorApprovalView extends StatefulWidget {
  const VendorApprovalView({super.key});

  @override
  State<VendorApprovalView> createState() => _VendorApprovalViewState();
}

class _VendorApprovalViewState extends State<VendorApprovalView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorViewModel>().loadVendors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<VendorViewModel>(
      builder: (context, viewModel, child) {
        // ==============================================================
        // LOADING
        // ==============================================================

        if (viewModel.isLoading && viewModel.pendingVendors.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ==============================================================
        // ERROR
        // ==============================================================

        if (viewModel.errorMessage != null &&
            viewModel.pendingVendors.isEmpty) {
          return _ErrorState(
            message: viewModel.errorMessage!,
            onRetry: viewModel.loadVendors,
          );
        }

        final vendors = viewModel.pendingVendors;

        // ==============================================================
        // EMPTY
        // ==============================================================

        if (vendors.isEmpty) {
          return const _EmptyState();
        }

        // ==============================================================
        // VENDOR LIST
        // ==============================================================

        return RefreshIndicator(
          onRefresh: viewModel.loadVendors,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              24,
            ),
            children: [

              Text(
                '${vendors.length} vendor${vendors.length == 1 ? '' : 's'} '
                'awaiting approval.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              // VENDORS
              ...vendors.map(
                (vendor) => _VendorApprovalCard(
                  vendor: vendor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ======================================================================
// VENDOR APPROVAL CARD
// ======================================================================

class _VendorApprovalCard extends StatelessWidget {
  final VendorModel vendor;

  const _VendorApprovalCard({
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // IMAGE
            // ==========================================================

            _VendorImage(vendor: vendor),

            const SizedBox(height: 16),

            // ==========================================================
            // VENDOR INFORMATION
            // ==========================================================

            VendorInfoSection(vendor: vendor),

            const SizedBox(height: 20),

            // ==========================================================
            // SUBMITTED INFORMATION
            // ==========================================================

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Submitted by',
                    value: vendor.createdBy,
                  ),

                  const SizedBox(height: 10),

                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Submitted',
                    value: _formatDate(vendor.createdDate),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================================
            // ACTIONS
            // ==========================================================

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _rejectVendor(context, vendor);
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _approveVendor(context, vendor);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // APPROVE
  // ====================================================================

  Future<void> _approveVendor(
    BuildContext context,
    VendorModel vendor,
  ) async {
    final confirmed = await _showConfirmation(
      context,
      title: 'Approve Vendor?',
      message:
          'Are you sure you want to approve "${vendor.name}"?',
      confirmText: 'Approve',
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final viewModel = context.read<VendorViewModel>();

    final success = await viewModel.approveVendor(
      vendor.vendorId,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${vendor.name} approved successfully.'
              : viewModel.errorMessage ??
                    'Failed to approve vendor.',
        ),
      ),
    );
  }

  // ====================================================================
  // REJECT
  // ====================================================================

  Future<void> _rejectVendor(
    BuildContext context,
    VendorModel vendor,
  ) async {
    final confirmed = await _showConfirmation(
      context,
      title: 'Reject Vendor?',
      message:
          'Are you sure you want to reject "${vendor.name}"?',
      confirmText: 'Reject',
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final viewModel = context.read<VendorViewModel>();

    final success = await viewModel.rejectVendor(
      vendor.vendorId,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${vendor.name} rejected.'
              : viewModel.errorMessage ??
                    'Failed to reject vendor.',
        ),
      ),
    );
  }

  // ====================================================================
  // CONFIRMATION DIALOG
  // ====================================================================

  Future<bool?> _showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),

          actions: [
            // Stack buttons vertically to avoid cramped
            // side-by-side buttons.
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(confirmText),
                ),

                const SizedBox(height: 4),

                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
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
// INFORMATION ROW
// ======================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// VENDOR IMAGE
// ======================================================================

class _VendorImage extends StatelessWidget {
  final VendorModel vendor;

  const _VendorImage({
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (vendor.imageUrls.isEmpty) {
      return _placeholder(colorScheme);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        vendor.imageUrls.first,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,

        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return _loadingPlaceholder(colorScheme);
        },

        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _placeholder(colorScheme);
        },
      ),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.restaurant_outlined,
        size: 64,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _loadingPlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 180,
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: colorScheme.primary,
            ),

            const SizedBox(height: 16),

            Text(
              'All caught up!',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'There are no vendors waiting for approval.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
              Icons.error_outline_rounded,
              size: 52,
              color: colorScheme.error,
            ),

            const SizedBox(height: 16),

            Text(
              'Unable to load vendors',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

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

