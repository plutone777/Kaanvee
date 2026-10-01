import 'package:fyp_application/models/vendor.dart';
import '../services/vendor_service.dart';

class VendorRepository {
  final VendorService _service;

  VendorRepository(this._service);

  Future<List<VendorModel>> getVendors() {
    return _service.getVendors();
  }

  Future<VendorModel?> getVendor(String vendorId) {
    return _service.getVendor(vendorId);
  }

  Future<void> addVendor(VendorModel vendor) {
    return _service.addVendor(vendor);
  }

  Future<void> updateVendor(VendorModel vendor) {
    return _service.updateVendor(vendor);
  }

  Future<void> deleteVendor(String vendorId) {
    return _service.deleteVendor(vendorId);
  }
}