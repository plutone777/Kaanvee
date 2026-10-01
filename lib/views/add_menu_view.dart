import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_application/constants/lists.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/services/image_upload_service.dart';
import 'package:fyp_application/viewmodels/menu_viewmodel.dart';
import 'package:fyp_application/widgets/multi_image_picker.dart';
import 'package:fyp_application/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class AddMenuView extends StatefulWidget {
  final String vendorId;
  final MenuModel? menuItem;

  const AddMenuView({
    super.key,
    required this.vendorId,
    this.menuItem,
  });

  @override
  State<AddMenuView> createState() => _AddMenuViewState();
}

class _AddMenuViewState extends State<AddMenuView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final List<XFile> _selectedImages = [];
  final ImageUploadService _imageUploadService = ImageUploadService();

  bool _isUploading = false;
  String _category = AppLists.menuCategories.first;

  bool get _isEditing => widget.menuItem != null;

  @override
  void initState() {
    super.initState();

    final menuItem = widget.menuItem;

    if (menuItem != null) {
      _nameController.text = menuItem.itemName;
      _descriptionController.text = menuItem.description;
      _priceController.text = menuItem.price?.toString() ?? '';
      _category = menuItem.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('You must be logged in to save a menu item.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final viewModel = context.read<MenuViewModel>();
      final now = DateTime.now();

      List<String> newImageUrls = [];

      // Upload newly selected images
      if (_selectedImages.isNotEmpty) {
        newImageUrls = await _imageUploadService.uploadImages(
          images: _selectedImages,
          folder: 'menu_images/${widget.vendorId}',
        );
      }

      final menuItem = MenuModel(
        menuId: widget.menuItem?.menuId ??
            FirebaseFirestore.instance.collection('Menu').doc().id,
        vendorId: widget.vendorId,
        itemName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        price: double.tryParse(_priceController.text.trim()),
        imageUrls: [
          ...(widget.menuItem?.imageUrls ?? []),
          ...newImageUrls,
        ],
        averageRating: widget.menuItem?.averageRating,
        createdBy: widget.menuItem?.createdBy ?? user.uid,
        createdDate: widget.menuItem?.createdDate ?? now,
        lastUpdated: now,
      );

      final success = _isEditing
          ? await viewModel.updateMenuItem(menuItem)
          : await viewModel.addMenuItem(menuItem);

      if (!mounted) return;

      if (success) {
        _showMessage(
          _isEditing
              ? 'Menu item updated successfully.'
              : 'Menu item added successfully.',
        );

        Navigator.pop(context, !_isEditing);
      } else {
        _showMessage(
          viewModel.errorMessage ?? 'Failed to save menu item.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to upload images. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Menu Item' : 'Add Menu Item',
        ),
      ),

      body: Consumer<MenuViewModel>(
        builder: (context, viewModel, child) {
          final isSaving = viewModel.isLoading || _isUploading;

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },

            child: Form(
              key: _formKey,

              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Basic Information',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ITEM NAME
                    AppTextField(
                      controller: _nameController,
                      label: 'Item Name',
                      hint: 'Enter menu item name',
                      icon: Icons.restaurant_menu_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an item name';
                        }

                        if (value.trim().length < 2) {
                          return 'Item name is too short';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // CATEGORY
                    DropdownButtonFormField<String>(
                      initialValue: _category,

                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(
                          Icons.category_outlined,
                        ),
                      ),

                      items: AppLists.menuCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),

                      onChanged: isSaving
                          ? null
                          : (value) {
                              if (value == null) return;

                              setState(() {
                                _category = value;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    // PRICE
                    TextFormField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),

                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: 'e.g. 85.00',
                        prefixText: 'MVR ',
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a price';
                        }

                        final price =
                            double.tryParse(value.trim());

                        if (price == null) {
                          return 'Please enter a valid price';
                        }

                        if (price < 0) {
                          return 'Price cannot be negative';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),


                    Text(
                      'Description',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 500,

                      decoration: const InputDecoration(
                        hintText: 'Describe the item',
                        prefixIcon: Icon(
                          Icons.description_outlined,
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Photos',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Submit up to 5 photos of this item.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 12),

                    MultiImagePicker(
                      selectedImages: _selectedImages,
                      maxImages: 5,

                      onImagesChanged: isSaving
                          ? (_) {}
                          : (images) {
                              setState(() {
                                _selectedImages
                                  ..clear()
                                  ..addAll(images);
                              });
                            },
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : _saveMenuItem,

                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'Update Menu Item'
                                    : 'Add Menu Item',
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // CANCEL
                    if (!isSaving)
                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: const Text('Cancel'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
