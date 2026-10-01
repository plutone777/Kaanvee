import 'package:flutter/material.dart';
import 'package:fyp_application/models/menu.dart';
import 'package:fyp_application/views/add_menu_view.dart';
import 'package:fyp_application/widgets/all_images_viewer.dart';
import 'package:fyp_application/widgets/report_dialog.dart';
import 'package:fyp_application/viewmodels/menu_viewmodel.dart';
import 'package:provider/provider.dart';

class VendorMenuItemCard extends StatelessWidget {
  final MenuModel menuItem;
  final bool adminMode;

  const VendorMenuItemCard({
    super.key,
    required this.menuItem,
    this.adminMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (menuItem.imageUrls.isEmpty) return;

          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AllImagesViewer(
                menuItem: menuItem,
                imageType: ImageType.menuItemImages,
              ),
            ),
          );

          if (updated == true && context.mounted) {
            await context
                .read<MenuViewModel>()
                .loadMenu(menuItem.vendorId);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // IMAGE
              // ==========================================================

              _buildImage(),

              const SizedBox(width: 14),

              // ==========================================================
              // MENU INFORMATION
              // ==========================================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + popup menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            menuItem.itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        _buildPopupMenu(context),
                      ],
                    ),

                    // Category
                    if (menuItem.category.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),

                      Text(
                        menuItem.category,
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    // Description
                    if (menuItem.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),

                      Text(
                        menuItem.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Price + rating
                    Row(
                      children: [
                        if (menuItem.price != null)
                          Text(
                            'MVR ${menuItem.price!.toStringAsFixed(2)}',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        if (menuItem.price != null &&
                            menuItem.averageRating != null)
                          Container(
                            height: 18,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: theme.dividerColor,
                          ),

                        if (menuItem.averageRating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),

                              const SizedBox(width: 3),

                              Text(
                                menuItem.averageRating!.toStringAsFixed(1),
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // IMAGE
  // ==========================================================

  Widget _buildImage() {
    if (menuItem.imageUrls.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.restaurant_menu_outlined,
          size: 32,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        menuItem.imageUrls.first,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant_menu_outlined,
              size: 32,
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // POPUP MENU
  // ==========================================================

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 21,
      iconColor: Colors.grey,
      tooltip: 'More options',

      onSelected: (value) async {
        // ----------------------------------------------------------
        // EDIT
        // ----------------------------------------------------------

        if (value == 'edit') {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMenuView(
                vendorId: menuItem.vendorId,
                menuItem: menuItem,
              ),
            ),
          );

          if (!context.mounted) return;

          await context
              .read<MenuViewModel>()
              .loadMenu(menuItem.vendorId);
        }

        // ----------------------------------------------------------
        // REPORT
        // ----------------------------------------------------------

        if (value == 'report') {
          showDialog(
            context: context,
            builder: (_) => ReportDialog(
              reportType: 'Menu',
              targetId: menuItem.menuId,
            ),
          );
        }

        // ----------------------------------------------------------
        // DELETE
        // ----------------------------------------------------------

        if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Delete Menu Item?'),
                content: Text(
                  'Are you sure you want to delete '
                  '${menuItem.itemName}?',
                ),
                actions: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Cancel'),
                  ),

                  const SizedBox(height: 10,),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );

          if (confirm != true || !context.mounted) {
            return;
          }

          final success = await context
              .read<MenuViewModel>()
              .deleteMenuItem(menuItem.menuId);

          if (!context.mounted) return;

          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete menu item.'),
              ),
            );
          }
        }
      },

      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 10),
              Text('Edit'),
            ],
          ),
        ),

        if (adminMode)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
          ),

        if (!adminMode)
          const PopupMenuItem<String>(
            value: 'report',
            child: Row(
              children: [
                Icon(Icons.flag_outlined),
                SizedBox(width: 10),
                Text('Report'),
              ],
            ),
          ),
      ],
    );
  }
}
