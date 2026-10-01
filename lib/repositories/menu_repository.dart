import 'package:fyp_application/models/menu.dart';
import '../services/menu_service.dart';

class MenuRepository {
  final MenuService _service;

  MenuRepository(this._service);

  Future<List<MenuModel>> getMenuForVendor(
    String vendorId,
  ) {
    return _service.getMenuForVendor(vendorId);
  }

  Future<MenuModel?> getMenuItem(String menuId) {
    return _service.getMenuItem(menuId);
  }

  Future<void> addMenuItem(MenuModel menuItem) {
    return _service.addMenuItem(menuItem);
  }

  Future<void> updateMenuItem(MenuModel menuItem) {
    return _service.updateMenuItem(menuItem);
  }

  Future<void> deleteMenuItem(String menuId) {
    return _service.deleteMenuItem(menuId);
  }
}