import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_application/constants/lists.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/utils/time_utils.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';
import 'package:fyp_application/widgets/multi_image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddVendorView extends StatefulWidget {
  final VendorModel? vendor;
  final bool adminMode;

  const AddVendorView({super.key, this.vendor, this.adminMode = false});

  @override
  State<AddVendorView> createState() => _AddVendorViewState();
}

class _AddVendorViewState extends State<AddVendorView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instagramController = TextEditingController();
  final _viberController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _facebookController = TextEditingController();
  final _phoneController = TextEditingController();

  String _vendorType = AppLists.vendorTypes.first;
  String _location = AppLists.locations.first;
  String _priceRange = AppLists.priceRanges.first;

  final List<String> _tags = [];

  final List<XFile> _vendorImages = [];
  final List<XFile> _menuImages = [];

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  bool get _isEditing => widget.vendor != null;

  @override
  void initState() {
    super.initState();

    final vendor = widget.vendor;

    if (vendor != null) {
      _nameController.text = vendor.name;
      _descriptionController.text = vendor.description;

      _instagramController.text = vendor.instagram ?? '';
      _viberController.text = vendor.viber ?? '';
      _whatsappController.text = vendor.whatsapp ?? '';
      _facebookController.text = vendor.facebook ?? '';
      _phoneController.text = vendor.phone ?? '';

      _vendorType = AppLists.vendorTypes.contains(vendor.vendorType)
          ? vendor.vendorType
          : AppLists.vendorTypes.first;

      _location = AppLists.locations.contains(vendor.location)
          ? vendor.location
          : AppLists.locations.first;

      _priceRange = AppLists.priceRanges.contains(vendor.priceRange)
          ? vendor.priceRange
          : AppLists.priceRanges.first;
      _tags.addAll(vendor.tags);

      final operatingHours = TimeUtils.parseOperatingHours(
        vendor.operatingHours,
      );

      if (operatingHours != null) {
        _openingTime = operatingHours.$1;
        _closingTime = operatingHours.$2;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _viberController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _saveVendor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tags.isEmpty) {
      _showMessage('Please select at least one cuisine or tag.');
      return;
    }

    if (_openingTime == null || _closingTime == null) {
      _showMessage('Please select opening and closing times.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('You must be logged in to save a vendor.');
      return;
    }

    final viewModel = context.read<VendorViewModel>();

    final now = DateTime.now();

    try {
      late VendorModel vendor;

      if (_isEditing) {
        final oldVendor = widget.vendor!;

        vendor = VendorModel(
          vendorId: oldVendor.vendorId,
          vendorType: _vendorType,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _location,
          tags: List<String>.from(_tags),
          operatingHours: TimeUtils.formatOperatingHours(
            _openingTime!,
            _closingTime!,
          ),
          openClosedStatus: oldVendor.openClosedStatus,
          priceRange: _priceRange,
          averagePrice: oldVendor.averagePrice,
          createdBy: oldVendor.createdBy,
          createdDate: oldVendor.createdDate,
          lastUpdated: now,
          instagram: _instagramController.text.trim(),
          viber: _viberController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
          facebook: _facebookController.text.trim(),
          phone: _phoneController.text.trim(),
          imageUrls: oldVendor.imageUrls,
          menuImageUrls: oldVendor.menuImageUrls,
          approvalStatus: oldVendor.approvalStatus,
        );

        final success = await viewModel.updateVendor(
          vendor,
          vendorImages: _vendorImages,
          menuImages: _menuImages,
        );

        if (!mounted) return;

        if (success) {
          _showMessage('Vendor updated successfully.');
          Navigator.pop(context, vendor);
        } else {
          _showMessage(viewModel.errorMessage ?? 'Failed to update vendor.');
        }
      } else {
        final vendorId = FirebaseFirestore.instance
            .collection('Vendors')
            .doc()
            .id;

        vendor = VendorModel(
          vendorId: vendorId,
          vendorType: _vendorType,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _location,
          tags: List<String>.from(_tags),
          operatingHours: TimeUtils.formatOperatingHours(
            _openingTime!,
            _closingTime!,
          ),
          openClosedStatus: false,
          priceRange: _priceRange,
          averagePrice: null,
          createdBy: user.uid,
          createdDate: now,
          lastUpdated: now,
          instagram: _instagramController.text.trim(),
          viber: _viberController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
          facebook: _facebookController.text.trim(),
          phone: _phoneController.text.trim(),
          imageUrls: [],
          menuImageUrls: [],
          approvalStatus: widget.adminMode ? 'Approved' : 'Pending',
        );

        final success = await viewModel.addVendor(
          vendor,
          vendorImages: _vendorImages,
          menuImages: _menuImages,
        );

        if (!mounted) return;

        if (success) {
          _showMessage(
            widget.adminMode
                ? 'Vendor added successfully.'
                : 'Vendor submitted for approval.',
          );

          Navigator.pop(context, vendor);
        } else {
          _showMessage(viewModel.errorMessage ?? 'Failed to add vendor.');
        }
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to save vendor. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Vendor' : 'Add Vendor')),

      body: Consumer<VendorViewModel>(
        builder: (context, viewModel, child) {
          final isSaving = viewModel.isLoading;

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

                    // VENDOR NAME
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,

                      decoration: const InputDecoration(
                        labelText: 'Vendor Name',
                        hintText: 'Enter vendor name',
                        prefixIcon: Icon(Icons.restaurant_outlined),
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a vendor name';
                        }

                        if (value.trim().length < 2) {
                          return 'Vendor name is too short';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // VENDOR TYPE
                    DropdownButtonFormField<String>(
                      initialValue: _vendorType,

                      decoration: const InputDecoration(
                        labelText: 'Vendor Type',
                        prefixIcon: Icon(Icons.store_outlined),
                      ),

                      items: AppLists.vendorTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),

                      onChanged: isSaving
                          ? null
                          : (value) {
                              if (value == null) return;

                              setState(() {
                                _vendorType = value;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    // LOCATION
                    DropdownButtonFormField<String>(
                      initialValue: _location,

                      decoration: const InputDecoration(
                        labelText: 'Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),

                      items: AppLists.locations.map((location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),

                      onChanged: isSaving
                          ? null
                          : (value) {
                              if (value == null) return;

                              setState(() {
                                _location = value;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    // PRICE RANGE
                    DropdownButtonFormField<String>(
                      initialValue: _priceRange,

                      decoration: const InputDecoration(
                        labelText: 'Price Range',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),

                      items: AppLists.priceRanges.map((price) {
                        return DropdownMenuItem<String>(
                          value: price,
                          child: Text(price),
                        );
                      }).toList(),

                      onChanged: isSaving
                          ? null
                          : (value) {
                              if (value == null) return;

                              setState(() {
                                _priceRange = value;
                              });
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
                      textCapitalization: TextCapitalization.sentences,

                      decoration: const InputDecoration(
                        hintText: 'Describe the vendor',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Cuisine / Tags',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,

                      children: AppLists.vendorTags.map((tag) {
                        final selected = _tags.contains(tag);

                        return FilterChip(
                          label: Text(tag),
                          selected: selected,

                          onSelected: isSaving
                              ? null
                              : (value) {
                                  setState(() {
                                    if (value) {
                                      _tags.add(tag);
                                    } else {
                                      _tags.remove(tag);
                                    }
                                  });
                                },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Operating Hours',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final time = await TimeUtils.selectTime(
                                      context,
                                      initialTime:
                                          _openingTime ??
                                          const TimeOfDay(hour: 10, minute: 0),
                                    );

                                    if (time != null) {
                                      setState(() {
                                        _openingTime = time;
                                      });
                                    }
                                  },

                            child: Text(
                              _openingTime == null
                                  ? 'Opening Time'
                                  : TimeUtils.formatTime(_openingTime!),
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('-'),
                        ),

                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final time = await TimeUtils.selectTime(
                                      context,
                                      initialTime:
                                          _closingTime ??
                                          const TimeOfDay(hour: 22, minute: 0),
                                    );

                                    if (time != null) {
                                      setState(() {
                                        _closingTime = time;
                                      });
                                    }
                                  },

                            child: Text(
                              _closingTime == null
                                  ? 'Closing Time'
                                  : TimeUtils.formatTime(_closingTime!),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Contact & Social Media',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PHONE
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,

                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        hintText: 'Enter phone number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // WHATSAPP
                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,

                      decoration: const InputDecoration(
                        labelText: 'WhatsApp',
                        hintText: 'Enter WhatsApp number',
                        prefixIcon: Icon(Icons.chat_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // VIBER
                    TextFormField(
                      controller: _viberController,
                      keyboardType: TextInputType.phone,

                      decoration: const InputDecoration(
                        labelText: 'Viber',
                        hintText: 'Enter Viber number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // INSTAGRAM
                    TextFormField(
                      controller: _instagramController,

                      decoration: const InputDecoration(
                        labelText: 'Instagram',
                        hintText: 'Instagram profile URL',
                        prefixIcon: Icon(Icons.camera_alt_outlined),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // FACEBOOK
                    TextFormField(
                      controller: _facebookController,

                      decoration: const InputDecoration(
                        labelText: 'Facebook',
                        hintText: 'Facebook profile URL',
                        prefixIcon: Icon(Icons.facebook),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Vendor Photos',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    MultiImagePicker(
                      selectedImages: _vendorImages,
                      maxImages: 5,

                      onImagesChanged: isSaving
                          ? (_) {}
                          : (images) {
                              setState(() {
                                _vendorImages
                                  ..clear()
                                  ..addAll(images);
                              });
                            },
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Menu Card Photos',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    MultiImagePicker(
                      selectedImages: _menuImages,
                      maxImages: 5,

                      onImagesChanged: isSaving
                          ? (_) {}
                          : (images) {
                              setState(() {
                                _menuImages
                                  ..clear()
                                  ..addAll(images);
                              });
                            },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveVendor,

                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_isEditing ? 'Update Vendor' : 'Add Vendor'),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (!isSaving)
                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },

                          child: const Text('Cancel'),
                        ),
                      ),

                    if (!_isEditing && !isSaving) ...[
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          widget.adminMode
                              ? 'The vendor will be added directly.'
                              : 'The vendor will be submitted for admin approval.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
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
