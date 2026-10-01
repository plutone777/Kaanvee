import 'package:flutter/material.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/viewmodels/like_viewmodel.dart';
import 'package:fyp_application/viewmodels/menu_viewmodel.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';
import 'package:fyp_application/views/add_vendor_view.dart';
import 'package:fyp_application/widgets/all_images_viewer.dart';
import 'package:fyp_application/widgets/report_dialog.dart';
import 'package:fyp_application/widgets/vendor_contact.dart';
import 'package:fyp_application/widgets/vendor_info.dart';
import 'package:fyp_application/widgets/vendor_menu.dart';
import 'package:fyp_application/widgets/vendor_reviews.dart';
import 'package:provider/provider.dart';

class VendorDetailsView extends StatefulWidget {
  final VendorModel vendor;
  final bool adminMode;

  const VendorDetailsView({
    super.key,
    required this.vendor,
    this.adminMode = false,
  });

  @override
  State<VendorDetailsView> createState() => _VendorDetailsViewState();
}

class _VendorDetailsViewState extends State<VendorDetailsView> {
  late VendorModel _vendor;

  @override
  void initState() {
    super.initState();
    _vendor = widget.vendor;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<MenuViewModel>().loadMenu(_vendor.vendorId);

      if (!widget.adminMode) {
        context.read<LikeViewModel>().loadLikeStatus(_vendor.vendorId);
      }

      await _refreshVendor();
    });
  }

  Future<void> _refreshVendor() async {
    final updatedVendor = await context.read<VendorViewModel>().getVendor(
      _vendor.vendorId,
    );

    if (!mounted || updatedVendor == null) return;

    setState(() {
      _vendor = updatedVendor;
    });
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Vendor?'),
          content: Text('Are you sure you want to delete ${_vendor.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final viewModel = context.read<VendorViewModel>();
    final success = await viewModel.deleteVendor(_vendor.vendorId);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Failed to delete vendor.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = _vendor;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!widget.adminMode)
            Consumer<LikeViewModel>(
              builder: (context, likeViewModel, child) {
                final isLiked = likeViewModel.isLiked(vendor.vendorId);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: isLiked ? 'Unlike vendor' : 'Like vendor',
                      onPressed: likeViewModel.isLoading
                          ? null
                          : () async {
                              final wasLiked = isLiked;

                              setState(() {
                                _vendor = _vendor.copyWith(
                                  likeCount: wasLiked
                                      ? _vendor.likeCount - 1
                                      : _vendor.likeCount + 1,
                                );
                              });

                              final success = await likeViewModel.toggleLike(
                                vendor.vendorId,
                              );

                              if (!success && mounted) {
                                setState(() {
                                  _vendor = _vendor.copyWith(
                                    likeCount: wasLiked
                                        ? _vendor.likeCount + 1
                                        : _vendor.likeCount - 1,
                                  );
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      likeViewModel.errorMessage ??
                                          'Failed to update like.',
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                      ),
                    ),
                    Text(
                      '${vendor.likeCount}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              },
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVendorView(
                      vendor: vendor,
                      adminMode: widget.adminMode,
                    ),
                  ),
                ).then((result) {
                  if (result != null && mounted) {
                    setState(() {
                      _vendor = result;
                    });
                  }
                });
              }

              if (value == 'report') {
                showDialog(
                  context: context,
                  builder: (_) => ReportDialog(
                    reportType: 'Vendor',
                    targetId: vendor.vendorId,
                  ),
                );
              }

              if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text('Edit Vendor'),
                  ],
                ),
              ),
              if (widget.adminMode)
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline),
                      const SizedBox(width: 10),
                      Text(
                        'Delete Vendor',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!widget.adminMode)
                const PopupMenuItem<String>(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined),
                      SizedBox(width: 10),
                      Text('Report Vendor'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VendorHeroSection(
              vendor: vendor,
              onImagesUpdated: _refreshVendor,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VendorInfoSection(vendor: vendor),
                  const SizedBox(height: 28),
                  VendorContactSection(vendor: vendor),
                  const SizedBox(height: 28),
                  VendorReviewsSection(
                    vendorId: vendor.vendorId,
                    adminMode: widget.adminMode,
                  ),
                  const SizedBox(height: 28),
                  _MenuImagesSection(
                    vendor: vendor,
                    onImagesUpdated: _refreshVendor,
                  ),
                  const SizedBox(height: 28),
                  VendorMenuSection(
                    vendorId: vendor.vendorId,
                    adminMode: widget.adminMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorHeroSection extends StatelessWidget {
  final VendorModel vendor;
  final Future<void> Function() onImagesUpdated;

  const _VendorHeroSection({
    required this.vendor,
    required this.onImagesUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (vendor.imageUrls.isEmpty) {
      return _buildPlaceholder(colorScheme);
    }

    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AllImagesViewer(
              vendor: vendor,
              imageType: ImageType.vendorImages,
            ),
          ),
        );

        if (updated == true) {
          await onImagesUpdated();
        }
      },
      child: SizedBox(
        height: 270,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              vendor.imageUrls.first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _buildPlaceholder(colorScheme);
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Text(
                vendor.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
            if (vendor.imageUrls.length > 1)
              Positioned(
                right: 16,
                bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${vendor.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 270,
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.restaurant_rounded,
        size: 80,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MenuImagesSection extends StatelessWidget {
  final VendorModel vendor;
  final Future<void> Function() onImagesUpdated;

  const _MenuImagesSection({
    required this.vendor,
    required this.onImagesUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Photos',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (vendor.menuImageUrls.isEmpty)
          _buildPlaceholder(colorScheme)
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: vendor.menuImageUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllImagesViewer(
                          vendor: vendor,
                          imageType: ImageType.menuImages,
                        ),
                      ),
                    );

                    if (updated == true) {
                      await onImagesUpdated();
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vendor.menuImageUrls[index],
                      width: 160,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          width: 160,
                          height: 120,
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.restaurant_menu,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 6),
          Text(
            'No menu images available',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
