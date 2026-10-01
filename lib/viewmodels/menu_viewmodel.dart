import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/services/user_service.dart';
import '../repositories/menu_repository.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuRepository _repository;
  final UserService _userService = UserService();

  MenuViewModel(this._repository);

  List<MenuModel> _menuItems = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<MenuModel> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMenu(String vendorId) async {
    _setLoading(true);

    try {
      _menuItems = await _repository.getMenuForVendor(vendorId);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load menu.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addMenuItem(MenuModel menuItem) async {
    _setLoading(true);

    try {
      await _repository.addMenuItem(menuItem);

      _menuItems.add(menuItem);

      await _userService.addPoints(menuItem.createdBy, 5);

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add menu item.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateMenuItem(MenuModel menuItem) async {
    _setLoading(true);

    try {
      await _repository.updateMenuItem(menuItem);

      final index = _menuItems.indexWhere(
        (item) => item.menuId == menuItem.menuId,
      );

      if (index != -1) {
        _menuItems[index] = menuItem;
      }

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update menu item.';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  // =====================================================
  // DELETE IMAGE
  // =====================================================

  Future<bool> deleteImage({
    required String menuId,
    required String imageUrl,
  }) async {
    _setLoading(true);

    try {
      // Delete image from Firebase Storage
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

      await storageRef.delete();

      // Find the menu item
      MenuModel? menuItem;

      try {
        menuItem = _menuItems.firstWhere((item) => item.menuId == menuId);
      } catch (_) {
        menuItem = await _repository.getMenuItem(menuId);
      }

      if (menuItem == null) {
        _errorMessage = 'Menu item not found.';
        return false;
      }

      // Remove image URL
      final updatedImages = List<String>.from(menuItem.imageUrls);

      updatedImages.remove(imageUrl);

      // Update menu item
      final updatedMenu = menuItem.copyWith(
        imageUrls: updatedImages,
        lastUpdated: DateTime.now(),
      );

      await _repository.updateMenuItem(updatedMenu);

      // Update local list
      final index = _menuItems.indexWhere((item) => item.menuId == menuId);

      if (index != -1) {
        _menuItems[index] = updatedMenu;
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

  Future<bool> deleteMenuItem(String menuId) async {
    _setLoading(true);

    try {
      await _repository.deleteMenuItem(menuId);

      _menuItems.removeWhere((item) => item.menuId == menuId);

      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete menu item.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<MenuModel?> getMenuItem(String menuId) {
    return _repository.getMenuItem(menuId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
