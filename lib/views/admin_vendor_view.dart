import 'package:flutter/material.dart';
import 'package:fyp_application/views/vendor_view.dart';

class AdminVendorManagementView
    extends StatelessWidget {
  const AdminVendorManagementView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const VendorHomeView(
      adminMode: true,
    );
  }
}