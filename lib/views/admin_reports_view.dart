import 'package:flutter/material.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/models/report.dart';
import 'package:fyp_application/viewmodels/report_viewmodel.dart';
import 'package:fyp_application/widgets/admin_report_card.dart';
import 'package:fyp_application/widgets/all_images_viewer.dart';
import 'package:provider/provider.dart';

class AdminReportsView extends StatefulWidget {
  const AdminReportsView({super.key});

  @override
  State<AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<AdminReportsView> {
  String _selectedStatus = 'Pending';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportViewModel>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 4,

      child: Column(
        children: [

          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(text: 'Vendors'),
              Tab(text: 'Menus'),
              Tab(text: 'Posts'),
              Tab(text: 'Images'),
            ],
          ),

          const SizedBox(height: 16),

          _ReportStatusToggle(
            selectedStatus: _selectedStatus,
            onChanged: (status) {
              setState(() {
                _selectedStatus = status;
              });
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              children: [
                _VendorReportsTab(
                  status: _selectedStatus,
                ),

                _MenuReportsTab(
                  status: _selectedStatus,
                ),

                _DiscussionReportsTab(
                  status: _selectedStatus,
                ),

                _ReportedImagesTab(
                  status: _selectedStatus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportStatusToggle extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  const _ReportStatusToggle({
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: 'Pending',
              icon: Icon(Icons.pending_outlined),
              label: Text('Pending'),
            ),
            ButtonSegment<String>(
              value: 'Resolved',
              icon: Icon(Icons.check_circle_outline),
              label: Text('Resolved'),
            ),
          ],

          selected: {selectedStatus},

          onSelectionChanged: (selection) {
            onChanged(selection.first);
          },
        ),
      ),
    );
  }
}

class _VendorReportsTab extends StatelessWidget {
  final String status;

  const _VendorReportsTab({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, viewModel, child) {
        final reports = viewModel.reports
            .where(
              (report) =>
                  report.reportType == 'Vendor' &&
                  report.status == status,
            )
            .toList();

        return _ReportListState(
          isLoading: viewModel.isLoading,
          errorMessage: viewModel.errorMessage,
          isEmpty: reports.isEmpty,
          emptyMessage: status == 'Pending'
              ? 'No pending vendor reports.'
              : 'No resolved vendor reports.',
          onRefresh: viewModel.loadReports,

          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: reports.length,

            itemBuilder: (context, index) {
              final report = reports[index];

              return FutureBuilder(
                future: viewModel.getReportedVendor(report.targetId),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingCard();
                  }

                  if (snapshot.hasError) {
                    return _ErrorCard(
                      message: 'Unable to load vendor information.',
                    );
                  }

                  final vendor = snapshot.data;

                  if (vendor == null) {
                    return _ErrorCard(
                      message: 'Vendor was deleted.',
                    );
                  }

                  return AdminReportCard(
                    report: report,
                    data: vendor,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _MenuReportsTab extends StatelessWidget {
  final String status;

  const _MenuReportsTab({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, viewModel, child) {
        final reports = viewModel.reports
            .where(
              (report) =>
                  report.reportType == 'Menu' &&
                  report.status == status,
            )
            .toList();

        return _ReportListState(
          isLoading: viewModel.isLoading,
          errorMessage: viewModel.errorMessage,
          isEmpty: reports.isEmpty,
          emptyMessage: status == 'Pending'
              ? 'No pending menu reports.'
              : 'No resolved menu reports.',
          onRefresh: viewModel.loadReports,

          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: reports.length,

            itemBuilder: (context, index) {
              final report = reports[index];

              return FutureBuilder<MenuModel?>(
                future: viewModel.getReportedMenu(report.targetId),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingCard();
                  }

                  if (snapshot.hasError) {
                    return const _ErrorCard(
                      message: 'Unable to load menu information.',
                    );
                  }

                  final menu = snapshot.data;

                  if (menu == null) {
                    return const _ErrorCard(
                      message: 'Item was deleted',
                    );
                  }

                  return AdminReportCard(
                    report: report,
                    data: menu,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _DiscussionReportsTab extends StatelessWidget {
  final String status;

  const _DiscussionReportsTab({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, viewModel, child) {
        final reports = viewModel.reports
            .where(
              (report) =>
                  report.reportType == 'Discussion' &&
                  report.status == status,
            )
            .toList();

        return _ReportListState(
          isLoading: viewModel.isLoading,
          errorMessage: viewModel.errorMessage,
          isEmpty: reports.isEmpty,
          emptyMessage: status == 'Pending'
              ? 'No pending discussion reports.'
              : 'No resolved discussion reports.',
          onRefresh: viewModel.loadReports,

          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: reports.length,

            itemBuilder: (context, index) {
              final report = reports[index];

              return FutureBuilder(
                future: viewModel.getReportedDiscussion(report.targetId),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _LoadingCard();
                  }

                  if (snapshot.hasError) {
                    return const _ErrorCard(
                      message: 'Unable to load discussion information.',
                    );
                  }

                  final discussion = snapshot.data;

                  if (discussion == null) {
                    return const _ErrorCard(
                      message: 'Post was deleted.',
                    );
                  }

                  return AdminReportCard(
                    report: report,
                    data: discussion,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ReportedImagesTab extends StatelessWidget {
  final String status;

  const _ReportedImagesTab({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportViewModel>(
      builder: (context, viewModel, child) {
        final reports = viewModel.reports.where((report) {
          return report.status == status &&
              [
                'Vendor Image',
                'Menu Image',
                'Menu Item Image',
              ].contains(report.reportType);
        }).toList();

        return _ReportListState(
          isLoading: viewModel.isLoading,
          errorMessage: viewModel.errorMessage,
          isEmpty: reports.isEmpty,
          emptyMessage: status == 'Pending'
              ? 'No pending image reports.'
              : 'No resolved image reports.',
          onRefresh: viewModel.loadReports,

          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: reports.length,

            itemBuilder: (context, index) {
              return _ReportedImageCard(
                report: reports[index],
              );
            },
          ),
        );
      },
    );
  }
}

class _ReportedImageCard extends StatelessWidget {
  final ReportModel report;

  const _ReportedImageCard({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasImage =
        report.imageUrl != null && report.imageUrl!.isNotEmpty;

    final isResolved = report.status == 'Resolved';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (hasImage)
            InkWell(
              onTap: () {
                _viewReportedImage(context);
              },

              child: Image.network(
                report.imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,

                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: colorScheme.surfaceContainerHighest,

                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: colorScheme.outline,
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.reportType,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'view') {
                          await _viewReportedImage(context);
                        }

                        if (value == 'resolve') {
                          await _resolveReport(context);
                        }
                      },

                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.image_outlined),
                            title: Text('View Image'),
                          ),
                        ),

                        if (!isResolved)
                          const PopupMenuItem(
                            value: 'resolve',
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.check_circle_outline,
                              ),
                              title: Text('Mark as Resolved'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _InfoRow(
                  icon: Icons.warning_amber_outlined,
                  text: report.reason,
                ),

                const SizedBox(height: 8),

                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: 'Reported ${_formatDate(report.createdDate)}',
                  muted: true,
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveReport(BuildContext context) async {
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

  Future<void> _viewReportedImage(BuildContext context) async {
    final viewModel = context.read<ReportViewModel>();

    if (report.reportType == 'Vendor Image') {
      final vendor = await viewModel.getReportedVendor(
        report.targetId,
      );

      if (vendor == null || !context.mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllImagesViewer(
            vendor: vendor,
            imageType: ImageType.vendorImages,
            adminMode: true,
            initialImageUrl: report.imageUrl,
            report: report,
          ),
        ),
      );
    }

    if (report.reportType == 'Menu Image') {
      final vendor = await viewModel.getReportedVendor(
        report.targetId,
      );

      if (vendor == null || !context.mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllImagesViewer(
            vendor: vendor,
            imageType: ImageType.menuImages,
            adminMode: true,
            initialImageUrl: report.imageUrl,
            report: report,
          ),
        ),
      );
    }

    if (report.reportType == 'Menu Item Image') {
      final menu = await viewModel.getReportedMenu(
        report.targetId,
      );

      if (menu == null || !context.mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AllImagesViewer(
            menuItem: menu,
            imageType: ImageType.menuItemImages,
            adminMode: true,
            initialImageUrl: report.imageUrl,
            report: report,
          ),
        ),
      );
    }
  }
}

class _ReportListState extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget child;

  const _ReportListState({
    required this.isLoading,
    required this.errorMessage,
    required this.isEmpty,
    required this.emptyMessage,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return _ErrorState(
        message: errorMessage!,
        onRetry: onRefresh,
      );
    }

    if (isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 260,
              child: _EmptyState(
                message: emptyMessage,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 52,
              color: colorScheme.outline,
            ),

            const SizedBox(height: 14),

            Text(
              message,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

            const SizedBox(height: 12),

            Text(
              'Unable to load reports',
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

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: EdgeInsets.all(24),

        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: colorScheme.error,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool muted;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: muted
              ? colorScheme.onSurfaceVariant
              : colorScheme.primary,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: muted
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}