import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_application/models/menu.dart';

class MenuService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _menu =>
      _firestore.collection('Menu');

  Future<List<MenuModel>> getMenuForVendor(
    String vendorId,
  ) async {
    final snapshot = await _menu
        .where('vendorID', isEqualTo: vendorId)
        .get();

    return snapshot.docs
        .map((doc) => MenuModel.fromFirestore(doc))
        .toList();
  }

  Future<MenuModel?> getMenuItem(String menuId) async {
    final document = await _menu.doc(menuId).get();

    if (!document.exists) {
      return null;
    }

    return MenuModel.fromFirestore(document);
  }

  Future<void> addMenuItem(MenuModel menuItem) async {
    await _menu.doc(menuItem.menuId).set(
      menuItem.toFirestore(),
    );
  }

  Future<void> updateMenuItem(MenuModel menuItem) async {
    await _menu.doc(menuItem.menuId).update(
      menuItem.toFirestore(),
    );
  }

  Future<void> deleteMenuItem(String menuId) async {
    await _menu.doc(menuId).delete();
  }
}