import 'package:flutter/material.dart';
import 'package:fyp_application/constants/lists.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/utils/points_animation_utils.dart';
import 'package:fyp_application/viewmodels/menu_viewmodel.dart';
import 'package:fyp_application/views/add_menu_view.dart';
import 'package:fyp_application/widgets/vendor_menu_itemcard.dart';
import 'package:provider/provider.dart';

class VendorMenuSection extends StatefulWidget {
  final String vendorId;
  final bool adminMode;

  const VendorMenuSection({
    super.key,
    required this.vendorId,
    this.adminMode = false,
  });

  @override
  State<VendorMenuSection> createState() => _VendorMenuSectionState();
}

class _VendorMenuSectionState extends State<VendorMenuSection> {
  // ==========================================================
  // FILTER VALUES
  // ==========================================================

  String _selectedCategory = 'All';

  // User-entered maximum price
  double? _maxPrice;

  final TextEditingController _priceController =
      TextEditingController();

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // ==========================================================
  // FILTER MENU ITEMS
  // ==========================================================

  List<MenuModel> _filterMenuItems(List<MenuModel> menuItems) {
    return menuItems.where((item) {
      // ------------------------------------------------------
      // CATEGORY
      // ------------------------------------------------------

      final categoryMatches =
          _selectedCategory == 'All' ||
          item.category == _selectedCategory;

      // ------------------------------------------------------
      // PRICE
      // ------------------------------------------------------

      final priceMatches =
          _maxPrice == null ||
          (item.price != null && item.price! <= _maxPrice!);

      return categoryMatches && priceMatches;
    }).toList();
  }

  // ==========================================================
  // FILTER ACTIVE?
  // ==========================================================

  bool get _hasActiveFilters {
    return _selectedCategory != 'All' || _maxPrice != null;
  }

  // ==========================================================
  // CLEAR FILTERS
  // ==========================================================

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _maxPrice = null;
      _priceController.clear();
    });
  }

  // ==========================================================
  // APPLY PRICE FILTER
  // ==========================================================

  void _applyPriceFilter() {
    final text = _priceController.text.trim();

    // No price entered
    if (text.isEmpty) {
      setState(() {
        _maxPrice = null;
      });
      return;
    }

    final price = double.tryParse(text);

    // Invalid number
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price.'),
        ),
      );
      return;
    }

    setState(() {
      _maxPrice = price;
    });
  }

  // ==========================================================
  // PRICE FILTER DIALOG
  // ==========================================================

  void _showPriceFilterDialog() {
    // Put current value into the field
    if (_maxPrice != null) {
      _priceController.text = _maxPrice!.toStringAsFixed(
        _maxPrice! % 1 == 0 ? 0 : 2,
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Filter by Price'),
          content: TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Maximum price',
              hintText: 'e.g. 150',
              prefixText: 'MVR ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                _priceController.clear();

                setState(() {
                  _maxPrice = null;
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Clear'),
            ),

            const SizedBox(height: 10),

            FilledButton(
              onPressed: () {
                final text = _priceController.text.trim();

                if (text.isEmpty) {
                  setState(() {
                    _maxPrice = null;
                  });

                  Navigator.pop(dialogContext);
                  return;
                }

                final price = double.tryParse(text);

                if (price == null || price < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid price.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  _maxPrice = price;
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<MenuViewModel>(
      builder: (context, viewModel, child) {
        final filteredItems =
            _filterMenuItems(viewModel.menuItems);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // MENU HEADING + ADD BUTTON
            // ========================================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menu',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (!widget.adminMode)
                  IconButton(
                    onPressed: () async {
                      final added = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddMenuView(
                            vendorId: widget.vendorId,
                          ),
                        ),
                      );

                      if (added == true && context.mounted) {
                        showPointsAnimation(context, 5);
                      }

                      if (context.mounted) {
                        context
                            .read<MenuViewModel>()
                            .loadMenu(widget.vendorId);
                      }
                    },
                    icon: const Icon(Icons.add),
                    tooltip: 'Add menu item',
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // ========================================================
            // FILTERS
            // ========================================================

            if (viewModel.menuItems.isNotEmpty) ...[
              Row(
                children: [
                  // --------------------------------------------------
                  // CATEGORY DROPDOWN
                  // --------------------------------------------------

                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(
                          Icons.category_outlined,
                        ),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: 'All',
                          child: Text('All'),
                        ),

                        ...AppLists.menuCategories.map(
                          (category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          },
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  // --------------------------------------------------
                  // PRICE BUTTON
                  // --------------------------------------------------

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showPriceFilterDialog,
                      icon: const Icon(
                        Icons.payments_outlined,
                      ),
                      label: Text(
                        _maxPrice == null
                            ? 'Any Price'
                            : 'Up to MVR ${_maxPrice!.toStringAsFixed(
                                _maxPrice! % 1 == 0 ? 0 : 2,
                              )}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ------------------------------------------------------
              // ACTIVE FILTERS
              // ------------------------------------------------------

              if (_hasActiveFilters) ...[
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredItems.length} '
                      '${filteredItems.length == 1 ? 'item' : 'items'} found',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(
                        Icons.clear,
                        size: 18,
                      ),
                      label: const Text('Clear filters'),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
            ],

            // ========================================================
            // LOADING
            // ========================================================

            if (viewModel.isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )

            // ========================================================
            // ERROR
            // ========================================================

            else if (viewModel.errorMessage != null)
              Text(viewModel.errorMessage!)

            // ========================================================
            // EMPTY MENU
            // ========================================================

            else if (viewModel.menuItems.isEmpty)
              const Text(
                'No menu items available.',
              )

            // ========================================================
            // NO FILTER RESULTS
            // ========================================================

            else if (filteredItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.5),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.filter_alt_off_outlined,
                      size: 36,
                      color:
                          colorScheme.onSurfaceVariant,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'No menu items match your filters.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 4),

                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        'Clear filters',
                      ),
                    ),
                  ],
                ),
              )

            // ========================================================
            // MENU ITEMS
            // ========================================================

            else
              ...filteredItems.map(
                (item) => VendorMenuItemCard(
                  menuItem: item,
                  adminMode: widget.adminMode,
                ),
              ),
          ],
        );
      },
    );
  }
}
