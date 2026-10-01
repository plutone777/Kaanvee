import 'package:flutter/material.dart';
import 'package:fyp_application/viewmodels/vendor_viewmodel.dart';
import 'package:fyp_application/viewmodels/menu_viewmodel.dart';
import 'package:provider/provider.dart';

class RecommendationSelector extends StatefulWidget {
  final String? selectedVendorId;
  final String? selectedMenuId;

  final Function(String?) onVendorSelected;
  final Function(String?) onMenuSelected;

  const RecommendationSelector({
    super.key,
    required this.selectedVendorId,
    required this.selectedMenuId,
    required this.onVendorSelected,
    required this.onMenuSelected,
  });

  @override
  State<RecommendationSelector> createState() =>
      _RecommendationSelectorState();
}

class _RecommendationSelectorState
    extends State<RecommendationSelector> {
  String _type = 'None';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Optionally recommend a vendor or menu item.',
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: _type,
          decoration: const InputDecoration(
            labelText: 'Recommendation Type',
            prefixIcon: Icon(Icons.recommend_outlined),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'None',
              child: Text('No recommendation'),
            ),
            DropdownMenuItem(
              value: 'Vendor',
              child: Text('Vendor'),
            ),
            DropdownMenuItem(
              value: 'Menu',
              child: Text('Menu Item'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _type = value ?? 'None';

              if (_type != 'Vendor') {
                widget.onVendorSelected(null);
              }

              if (_type != 'Menu') {
                widget.onMenuSelected(null);
              }
            });
          },
        ),

        if (_type == 'Vendor') ...[
          const SizedBox(height: 16),

          Consumer<VendorViewModel>(
            builder: (context, viewModel, child) {
              final vendors = viewModel.vendors;

              return DropdownButtonFormField<String>(
                value: widget.selectedVendorId,
                decoration: const InputDecoration(
                  labelText: 'Select Vendor',
                  prefixIcon:
                      Icon(Icons.store_outlined),
                  border: OutlineInputBorder(),
                ),
                items: vendors.map((vendor) {
                  return DropdownMenuItem<String>(
                    value: vendor.vendorId,
                    child: Text(vendor.name),
                  );
                }).toList(),
                onChanged: widget.onVendorSelected,
              );
            },
          ),
        ],

        if (_type == 'Menu') ...[
          const SizedBox(height: 16),

          Consumer<VendorViewModel>(
            builder: (context, vendorViewModel, child) {
              final vendors = vendorViewModel.vendors;

              return DropdownButtonFormField<String>(
                value: widget.selectedVendorId,
                decoration: const InputDecoration(
                  labelText: 'Select Vendor',
                  prefixIcon: Icon(Icons.store_outlined),
                  border: OutlineInputBorder(),
                ),
                items: vendors.map((vendor) {
                  return DropdownMenuItem<String>(
                    value: vendor.vendorId,
                    child: Text(vendor.name),
                  );
                }).toList(),
                onChanged: (value) {
                  widget.onVendorSelected(value);

                  // Clear previous menu selection
                  widget.onMenuSelected(null);

                  if (value != null) {
                    context.read<MenuViewModel>().loadMenu(value);
                  }
                },
              );
            },
          ),

          const SizedBox(height: 16),

          Consumer<MenuViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final menuItems = viewModel.menuItems;

              if (widget.selectedVendorId == null) {
                return const Text(
                  'Select a vendor first.',
                );
              }

              if (menuItems.isEmpty) {
                return const Text(
                  'No menu items found for this vendor.',
                );
              }

              return DropdownButtonFormField<String>(
                value: widget.selectedMenuId,
                decoration: const InputDecoration(
                  labelText: 'Select Menu Item',
                  prefixIcon: Icon(Icons.restaurant_menu),
                  border: OutlineInputBorder(),
                ),
                items: menuItems.map((menu) {
                  return DropdownMenuItem<String>(
                    value: menu.menuId,
                    child: Text(menu.itemName),
                  );
                }).toList(),
                onChanged: widget.onMenuSelected,
              );
            },
          ),
        ],
      ],
    );
  }
}