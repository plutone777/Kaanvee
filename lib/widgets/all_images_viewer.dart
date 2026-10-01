import 'package:flutter/material.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/models/report.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/viewmodels/menu_viewmodel.dart';
import 'package:fyp_application/viewmodels/report_viewmodel.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';
import 'package:fyp_application/widgets/report_dialog.dart';
import 'package:provider/provider.dart';

enum ImageType { vendorImages, menuImages, menuItemImages }

class AllImagesViewer extends StatefulWidget {
  final MenuModel? menuItem;
  final VendorModel? vendor;
  final ImageType imageType;

  final bool adminMode;

  final String? initialImageUrl;

  final ReportModel? report;

  const AllImagesViewer({
    super.key,
    this.menuItem,
    this.vendor,
    required this.imageType,
    this.adminMode = false,
    this.initialImageUrl,
    this.report,
  }) : assert(
         menuItem != null || vendor != null,
         'Either menuItem or vendor must be provided.',
       ),
       assert(
         menuItem == null || vendor == null,
         'Only one model can be provided.',
       );

  @override
  State<AllImagesViewer> createState() => _AllImagesViewerState();
}

class _AllImagesViewerState extends State<AllImagesViewer> {
  late final PageController _pageController;

  int _currentIndex = 0;
  bool _isLoading = false;

  List<String> get imageUrls {
    switch (widget.imageType) {
      case ImageType.vendorImages:
        return widget.vendor!.imageUrls;

      case ImageType.menuImages:
        return widget.vendor!.menuImageUrls;

      case ImageType.menuItemImages:
        return widget.menuItem!.imageUrls;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get targetId {
    switch (widget.imageType) {
      case ImageType.vendorImages:
      case ImageType.menuImages:
        return widget.vendor!.vendorId;

      case ImageType.menuItemImages:
        return widget.menuItem!.menuId;
    }
  }

  String get reportType {
    switch (widget.imageType) {
      case ImageType.vendorImages:
        return 'Vendor Image';

      case ImageType.menuImages:
        return 'Menu Image';

      case ImageType.menuItemImages:
        return 'Menu Item Image';
    }
  }

  @override
  void initState() {
    super.initState();

    int initialIndex = 0;

    if (widget.initialImageUrl != null) {
      final index = imageUrls.indexOf(widget.initialImageUrl!);

      if (index != -1) {
        initialIndex = index;
      }
    }

    _currentIndex = initialIndex;

    _pageController = PageController(initialPage: initialIndex);
  }

  // ==========================================================
  // SET AS COVER
  // ==========================================================

  Future<void> _setAsCover() async {
    if (_currentIndex == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This image is already the cover image.')),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedImages = List<String>.from(imageUrls);

    final selectedImage = updatedImages.removeAt(_currentIndex);

    updatedImages.insert(0, selectedImage);

    bool success;

    switch (widget.imageType) {
      case ImageType.vendorImages:
        final updatedVendor = widget.vendor!.copyWith(
          imageUrls: updatedImages,
          lastUpdated: DateTime.now(),
        );

        success = await context.read<VendorViewModel>().updateVendor(
          updatedVendor,
        );

        break;

      case ImageType.menuImages:
        final updatedVendor = widget.vendor!.copyWith(
          menuImageUrls: updatedImages,
          lastUpdated: DateTime.now(),
        );

        success = await context.read<VendorViewModel>().updateVendor(
          updatedVendor,
        );

        break;

      case ImageType.menuItemImages:
        final updatedMenu = widget.menuItem!.copyWith(
          imageUrls: updatedImages,
          lastUpdated: DateTime.now(),
        );

        success = await context.read<MenuViewModel>().updateMenuItem(
          updatedMenu,
        );

        break;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $reportType cover image.')),
      );
    }
  }

  // ==========================================================
  // REPORT IMAGE
  // ==========================================================

  void _reportImage() {
    showDialog(
      context: context,
      builder: (_) => ReportDialog(
        reportType: reportType,
        targetId: targetId,
        imageUrl: imageUrls[_currentIndex],
      ),
    );
  }

  // ==========================================================
  // DELETE IMAGE
  // ==========================================================

  Future<void> _deleteImage() async {
    if (imageUrls.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the only image.')),
      );

      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

          const SizedBox(height: 10),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    final imageUrl = imageUrls[_currentIndex];

    bool success;

    switch (widget.imageType) {
      case ImageType.vendorImages:
      case ImageType.menuImages:
        success = await context.read<VendorViewModel>().deleteImage(
          vendorId: widget.vendor!.vendorId,
          imageUrl: imageUrl,
          isMenuImage: widget.imageType == ImageType.menuImages,
        );
        break;

      case ImageType.menuItemImages:
        success = await context.read<MenuViewModel>().deleteImage(
          menuId: widget.menuItem!.menuId,
          imageUrl: imageUrl,
        );
        break;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Resolve the report after successfully deleting the image
      if (widget.adminMode && widget.report != null) {
        await context.read<ReportViewModel>().resolveReport(widget.report!);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete $reportType.')));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No images available.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,

        title: Text('${_currentIndex + 1} / ${imageUrls.length}'),

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),

            onSelected: (value) {
              if (value == 'report') {
                _reportImage();
              }

              if (value == 'delete') {
                _deleteImage();
              }

              if (value == 'cover') {
                _setAsCover();
              }
            },

            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: widget.adminMode ? 'delete' : 'report',

                child: Row(
                  children: [
                    Icon(
                      widget.adminMode
                          ? Icons.delete_outline
                          : Icons.flag_outlined,
                    ),

                    const SizedBox(width: 8),

                    Text(widget.adminMode ? 'Delete Image' : 'Report Image'),
                  ],
                ),
              ),

              const PopupMenuItem<String>(
                value: 'cover',

                child: Row(
                  children: [
                    Icon(Icons.image_outlined),

                    SizedBox(width: 8),

                    Text('Set as Cover'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Stack(
        children: [
          // ==========================================================
          // IMAGES
          // ==========================================================
          PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,

            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },

            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.contain,

                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 60,
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // ==========================================================
          // DATE AT BOTTOM
          // ==========================================================
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatDate(
                    widget.imageType == ImageType.menuItemImages
                        ? widget.menuItem!.createdDate
                        : widget.vendor!.createdDate,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // ==========================================================
          // LOADING
          // ==========================================================
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
