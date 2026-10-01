import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/services/user_service.dart';
import 'package:fyp_application/services/image_upload_service.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/vendor_repository.dart';

class VendorViewModel extends ChangeNotifier {
  final VendorRepository _repository;
  final UserService _userService = UserService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  VendorViewModel(this._repository);

  List<VendorModel> _vendors = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<VendorModel> get vendors => _filteredApprovedVendors;
  List<VendorModel> get allVendors => _filteredAllVendors;

  List<VendorModel> get pendingVendors {
    return _vendors
        .where((vendor) => vendor.approvalStatus == 'Pending')
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadVendors() async {
    _setLoading(true);

    try {
      _vendors = await _repository.getVendors();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load vendors.';
    } finally {
      _setLoading(false);
    }
  }

  void searchVendors(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<VendorModel> get _filteredApprovedVendors {
    final query = _searchQuery.trim().toLowerCase();

    return _vendors.where((vendor) {
      if (vendor.approvalStatus != 'Approved') {
        return false;
      }

      if (query.isNotEmpty && !vendor.name.toLowerCase().contains(query)) {
        return false;
      }

      return true;
    }).toList();
  }

  List<VendorModel> get _filteredAllVendors {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return List<VendorModel>.from(_vendors);
    }

    return _vendors.where((vendor) {
      return vendor.name.toLowerCase().contains(query);
    }).toList();
  }

  Future<bool> addVendor(
    VendorModel vendor, {
    List<XFile>? vendorImages,
    List<XFile>? menuImages,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<String> imageUrls = [];
      List<String> menuImageUrls = [];

      if (vendorImages != null && vendorImages.isNotEmpty) {
        imageUrls = await _imageUploadService.uploadImages(
          images: vendorImages,
          folder: 'Vendors/${vendor.vendorId}/vendorImages',
        );
      }

      if (menuImages != null && menuImages.isNotEmpty) {
        menuImageUrls = await _imageUploadService.uploadImages(
          images: menuImages,
          folder: 'Vendors/${vendor.vendorId}/menuImages',
        );
      }

      final updatedVendor = vendor.copyWith(
        imageUrls: imageUrls,
        menuImageUrls: menuImageUrls,
      );

      await _repository.addVendor(updatedVendor);
      _vendors.add(updatedVendor);
      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add vendor: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVendor(
    VendorModel vendor, {
    List<XFile>? vendorImages,
    List<XFile>? menuImages,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<String> imageUrls = List<String>.from(vendor.imageUrls);
      List<String> menuImageUrls = List<String>.from(vendor.menuImageUrls);

      if (vendorImages != null && vendorImages.isNotEmpty) {
        final newImages = await _imageUploadService.uploadImages(
          images: vendorImages,
          folder: 'Vendors/${vendor.vendorId}/vendorImages',
        );

        imageUrls.addAll(newImages);
      }

      if (menuImages != null && menuImages.isNotEmpty) {
        final newImages = await _imageUploadService.uploadImages(
          images: menuImages,
          folder: 'Vendors/${vendor.vendorId}/menuImages',
        );

        menuImageUrls.addAll(newImages);
      }

      final updatedVendor = vendor.copyWith(
        imageUrls: imageUrls,
        menuImageUrls: menuImageUrls,
        lastUpdated: DateTime.now(),
      );

      await _repository.updateVendor(updatedVendor);

      final index = _vendors.indexWhere(
        (item) => item.vendorId == vendor.vendorId,
      );

      if (index != -1) {
        _vendors[index] = updatedVendor;
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update vendor: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveVendor(String vendorId) async {
    final vendor = _findVendor(vendorId);

    if (vendor == null) {
      _errorMessage = 'Vendor not found.';
      notifyListeners();
      return false;
    }

    final updatedVendor = vendor.copyWith(approvalStatus: 'Approved');
    final success = await updateVendor(updatedVendor);

    if (success) {
      await _userService.addPoints(vendor.createdBy, 10);
    }

    return success;
  }

  Future<bool> rejectVendor(String vendorId) async {
    final vendor = _findVendor(vendorId);

    if (vendor == null) {
      _errorMessage = 'Vendor not found.';
      notifyListeners();
      return false;
    }

    final updatedVendor = vendor.copyWith(approvalStatus: 'Rejected');
    return updateVendor(updatedVendor);
  }

  Future<bool> deleteImage({
    required String vendorId,
    required String imageUrl,
    required bool isMenuImage,
  }) async {
    _setLoading(true);

    try {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();

      final vendor = _findVendor(vendorId) ??
          await _repository.getVendor(vendorId);

      if (vendor == null) {
        _errorMessage = 'Vendor not found.';
        return false;
      }

      final updatedImages = isMenuImage
          ? List<String>.from(vendor.menuImageUrls)
          : List<String>.from(vendor.imageUrls);

      updatedImages.remove(imageUrl);

      final updatedVendor = isMenuImage
          ? vendor.copyWith(
              menuImageUrls: updatedImages,
              lastUpdated: DateTime.now(),
            )
          : vendor.copyWith(
              imageUrls: updatedImages,
              lastUpdated: DateTime.now(),
            );

      await _repository.updateVendor(updatedVendor);

      final index = _vendors.indexWhere(
        (item) => item.vendorId == vendorId,
      );

      if (index != -1) {
        _vendors[index] = updatedVendor;
      }

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete image: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteVendor(String vendorId) async {
    _setLoading(true);

    try {
      await _repository.deleteVendor(vendorId);
      _vendors.removeWhere((vendor) => vendor.vendorId == vendorId);
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete vendor.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<VendorModel?> getVendor(String vendorId) {
    return _repository.getVendor(vendorId);
  }

  VendorModel? _findVendor(String vendorId) {
    try {
      return _vendors.firstWhere((vendor) => vendor.vendorId == vendorId);
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
