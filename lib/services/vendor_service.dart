import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_application/models/vendor.dart';

class VendorService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vendors =>
      _firestore.collection('Vendors');

  Future<List<VendorModel>> getVendors() async {
    final snapshot = await _vendors.get();

    return snapshot.docs
        .map((doc) => VendorModel.fromFirestore(doc))
        .toList();
  }

  Future<VendorModel?> getVendor(String vendorId) async {
    final document = await _vendors.doc(vendorId).get();

    if (!document.exists) {
      return null;
    }

    return VendorModel.fromFirestore(document);
  }

  Future<void> addVendor(VendorModel vendor) async {
    await _vendors.doc(vendor.vendorId).set(
      vendor.toFirestore(),
    );
  }

  Future<void> updateVendor(VendorModel vendor) async {
    await _vendors.doc(vendor.vendorId).update(
      vendor.toFirestore(),
    );
  }

  Future<void> deleteVendor(String vendorId) async {
    await _vendors.doc(vendorId).delete();
  }

  Stream<List<VendorModel>> watchVendors() {
    return _vendors.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => VendorModel.fromFirestore(doc))
          .toList(),
    );
  }
}