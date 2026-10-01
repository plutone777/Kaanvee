import 'package:flutter/material.dart';
import 'package:fyp_application/models/discussion.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/models/report.dart';
import 'package:fyp_application/models/vendor.dart';

import 'package:fyp_application/viewmodels/discussion_viewmodel.dart';
import 'package:fyp_application/viewmodels/menu_viewmodel.dart';
import 'package:fyp_application/viewmodels/report_viewmodel.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';

import 'package:fyp_application/views/discussion_details_view.dart';
import 'package:fyp_application/views/vendor_details_view.dart';

import 'package:provider/provider.dart';

class AdminReportCard extends StatelessWidget {
  final ReportModel report;
  final dynamic data;

  const AdminReportCard({
    super.key,
    required this.report,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (report.reportType == 'Vendor' && data is VendorModel) {
      return _buildVendorCard(context, data as VendorModel);
    }

    if (report.reportType == 'Menu' && data is MenuModel) {
      return _buildMenuCard(context, data as MenuModel);
    }

    if (report.reportType == 'Discussion' && data is DiscussionModel) {
      return _buildDiscussionCard(
        context,
        data as DiscussionModel,
      );
    }

    return const SizedBox.shrink();
  }

  // ==========================================================
  // VENDOR REPORT
  // ==========================================================

  Widget _buildVendorCard(
    BuildContext context,
    VendorModel vendor,
  ) {
    return _ReportCardContainer(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VendorDetailsView(
              vendor: vendor,
              adminMode: true,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReportHeader(
            icon: Icons.store_outlined,
            title: vendor.name,
            subtitle: 'Vendor',
          ),

          const SizedBox(height: 16),

          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: vendor.location,
          ),

          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Type',
            value: vendor.vendorType,
          ),

          _InfoRow(
            icon: Icons.person_outline,
            label: 'Created by',
            value: vendor.createdBy,
          ),

          const SizedBox(height: 16),

          _ReportDetails(
            report: report,
          ),

          const SizedBox(height: 12),

          _ActionMenu(
            isResolved: report.status == 'Resolved',
            onResolve: () => _resolveReport(context),
            onDelete: () => _deleteVendor(context, vendor),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MENU REPORT
  // ==========================================================

  Widget _buildMenuCard(
    BuildContext context,
    MenuModel menu,
  ) {
    return FutureBuilder<VendorModel?>(
      future: context
          .read<ReportViewModel>()
          .getReportedVendor(menu.vendorId),
      builder: (context, snapshot) {
        final vendor = snapshot.data;

        return _ReportCardContainer(
          onTap: vendor == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VendorDetailsView(
                        vendor: vendor,
                        adminMode: true,
                      ),
                    ),
                  );
                },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReportHeader(
                icon: Icons.restaurant_menu_outlined,
                title: menu.itemName,
                subtitle: 'Menu Item',
              ),

              const SizedBox(height: 16),

              _InfoRow(
                icon: Icons.category_outlined,
                label: 'Category',
                value: menu.category,
              ),

              if (menu.description.isNotEmpty)
                _InfoRow(
                  icon: Icons.description_outlined,
                  label: 'Description',
                  value: menu.description,
                ),

              if (menu.price != null)
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Price',
                  value: 'MVR ${menu.price!.toStringAsFixed(2)}',
                ),

              _InfoRow(
                icon: Icons.store_outlined,
                label: 'Vendor ID',
                value: menu.vendorId,
              ),

              _InfoRow(
                icon: Icons.person_outline,
                label: 'Created by',
                value: menu.createdBy,
              ),

              const SizedBox(height: 16),

              _ReportDetails(
                report: report,
              ),

              const SizedBox(height: 12),

              _ActionMenu(
                isResolved: report.status == 'Resolved',
                onResolve: () => _resolveReport(context),
                onDelete: () => _deleteMenu(context, menu),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // DISCUSSION REPORT
  // ==========================================================

  Widget _buildDiscussionCard(
    BuildContext context,
    DiscussionModel discussion,
  ) {
    return _ReportCardContainer(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiscussionDetailsView(
              discussion: discussion,
              adminMode: true,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReportHeader(
            icon: Icons.forum_outlined,
            title: discussion.title,
            subtitle: 'Discussion',
          ),

          const SizedBox(height: 16),

          Text(
            discussion.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.person_outline,
            label: 'Posted by',
            value: discussion.userId,
          ),

          const SizedBox(height: 16),

          _ReportDetails(
            report: report,
          ),

          const SizedBox(height: 12),

          _ActionMenu(
            isResolved: report.status == 'Resolved',
            onResolve: () => _resolveReport(context),
            onDelete: () => _deleteDiscussion(
              context,
              discussion,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RESOLVE REPORT
  // ==========================================================

  Future<void> _resolveReport(
    BuildContext context,
  ) async {
    final confirmed = await _showConfirmation(
      context,
      title: 'Resolve Report?',
      message:
          'Are you sure you want to mark this report as resolved?',
      confirmText: 'Resolve',
    );

    if (confirmed != true) return;

    final viewModel = context.read<ReportViewModel>();

    final success = await viewModel.resolveReport(report);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Report marked as resolved.'
              : viewModel.errorMessage ??
                  'Failed to resolve report.',
        ),
      ),
    );
  }

  // ==========================================================
  // DELETE VENDOR
  // ==========================================================

  Future<void> _deleteVendor(
    BuildContext context,
    VendorModel vendor,
  ) async {
    final confirmed = await _showConfirmation(
      context,
      title: 'Delete Vendor?',
      message:
          'Are you sure you want to delete "${vendor.name}"?\n\n'
          'The report will also be marked as resolved.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true) return;

    final vendorViewModel = context.read<VendorViewModel>();

    final success = await vendorViewModel.deleteVendor(
      vendor.vendorId,
    );

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vendorViewModel.errorMessage ??
                'Failed to delete vendor.',
          ),
        ),
      );

      return;
    }

    final reportViewModel = context.read<ReportViewModel>();

    final resolved = await reportViewModel.resolveReport(report);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resolved
              ? 'Vendor deleted and report resolved.'
              : 'Vendor deleted, but report could not be resolved.',
        ),
      ),
    );
  }

  // ==========================================================
  // DELETE MENU
  // ==========================================================

  Future<void> _deleteMenu(
    BuildContext context,
    MenuModel menu,
  ) async {
    final confirmed = await _showConfirmation(
      context,
      title: 'Delete Menu Item?',
      message:
          'Are you sure you want to delete "${menu.itemName}"?\n\n'
          'The report will also be marked as resolved.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true) return;

    final menuViewModel = context.read<MenuViewModel>();

    final success = await menuViewModel.deleteMenuItem(
      menu.menuId,
    );

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            menuViewModel.errorMessage ??
                'Failed to delete menu item.',
          ),
        ),
      );

      return;
    }

    final reportViewModel = context.read<ReportViewModel>();

    final resolved = await reportViewModel.resolveReport(report);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resolved
              ? 'Menu item deleted and report resolved.'
              : 'Menu item deleted, but report could not be resolved.',
        ),
      ),
    );
  }

  // ==========================================================
  // DELETE DISCUSSION
  // ==========================================================

  Future<void> _deleteDiscussion(
    BuildContext context,
    DiscussionModel discussion,
  ) async {
    final confirmed = await _showConfirmation(
      context,
      title: 'Delete Discussion?',
      message:
          'Are you sure you want to delete "${discussion.title}"?\n\n'
          'The report will also be marked as resolved.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true) return;

    final discussionViewModel =
        context.read<DiscussionViewModel>();

    final success = await discussionViewModel.deleteDiscussion(
      discussion.discussionId,
    );

    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            discussionViewModel.errorMessage ??
                'Failed to delete discussion.',
          ),
        ),
      );

      return;
    }

    final reportViewModel = context.read<ReportViewModel>();

    final resolved = await reportViewModel.resolveReport(report);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resolved
              ? 'Discussion deleted and report resolved.'
              : 'Discussion deleted, but report could not be resolved.',
        ),
      ),
    );
  }

  // ==========================================================
  // CONFIRMATION DIALOG
  // ==========================================================

  Future<bool?> _showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),

          content: Text(message),

          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isDestructive)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    child: Text(confirmText),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    child: Text(confirmText),
                  ),

                const SizedBox(height: 8),

                ElevatedButton(
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
}

// ==========================================================
// REPORT CARD CONTAINER
// ==========================================================

class _ReportCardContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _ReportCardContainer({
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// ==========================================================
// REPORT HEADER
// ==========================================================

class _ReportHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ReportHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// INFO ROW
// ==========================================================

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),

          const SizedBox(width: 8),

          Text(
            '$label: ',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// REPORT DETAILS
// ==========================================================

class _ReportDetails extends StatelessWidget {
  final ReportModel report;

  const _ReportDetails({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isResolved = report.status == 'Resolved';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Details',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            report.reason,
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  'Reported by: ${report.reportedBy}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                isResolved
                    ? Icons.check_circle_outline
                    : Icons.pending_outlined,
                size: 16,
                color: isResolved
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),

              const SizedBox(width: 6),

              Text(
                'Status: ${report.status}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ==========================================================
// ACTION MENU
// ==========================================================

class _ActionMenu extends StatelessWidget {
  final bool isResolved;
  final VoidCallback onResolve;
  final VoidCallback onDelete;

  const _ActionMenu({
    required this.isResolved,
    required this.onResolve,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isResolved) {
      return Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 18,
              color: colorScheme.primary,
            ),

            const SizedBox(width: 6),

            Text(
              'Resolved',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<String>(
        tooltip: 'Report actions',
        icon: Icon(
          Icons.more_vert,
          color: colorScheme.onSurface,
        ),

        onSelected: (value) {
          if (value == 'resolve') {
            onResolve();
          } else if (value == 'delete') {
            onDelete();
          }
        },

        itemBuilder: (context) {
          return [
            PopupMenuItem<String>(
              value: 'resolve',
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: colorScheme.onSurface,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    'Resolve Report',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),

                  const SizedBox(width: 10),

                  Text(
                    'Delete & Resolve',
                    style: TextStyle(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}
