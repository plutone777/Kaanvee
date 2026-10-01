import 'package:flutter/material.dart';
import 'package:fyp_application/models/vendor.dart';
import 'package:fyp_application/views/vendor_details_view.dart';

// ============================================================
// VENDOR CARD
// ============================================================

class VendorCard extends StatelessWidget {
  final VendorModel vendor;

  final bool adminMode;

  final bool isRecommended;

  final double? matchPercentage;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.adminMode,
    required this.isRecommended,
    this.matchPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 1,
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorDetailsView(
                vendor: vendor,
                adminMode: adminMode,
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // VENDOR IMAGE
              // ==================================================

              _buildVendorImage(colorScheme),

              const SizedBox(width: 12),

              // ==================================================
              // VENDOR INFORMATION
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // NAME + RECOMMENDATION
                    // ==================================================

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: Text(
                            vendor.name,

                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        if (isRecommended &&
                            matchPercentage != null) ...[
                          const SizedBox(width: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),

                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                Icon(
                                  Icons.thumb_up_alt_rounded,
                                  size: 12,
                                  color: colorScheme
                                      .onPrimaryContainer,
                                ),

                                const SizedBox(width: 3),

                                Text(
                                  '${matchPercentage!.round()}%',

                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    // ==================================================
                    // LOCATION
                    // ==================================================

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: colorScheme.onSurfaceVariant,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            vendor.location,

                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: colorScheme
                                      .onSurfaceVariant,
                                ),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // PRICE + TAGS
                    // ==================================================

                    Row(
                      children: [
                        if (vendor.priceRange.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),

                            decoration: BoxDecoration(
                              color: colorScheme
                                  .surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),

                            child: Text(
                              vendor.priceRange,

                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),

                        if (vendor.tags.isNotEmpty) ...[
                          const SizedBox(width: 7),

                          Expanded(
                            child: Text(
                              vendor.tags
                                  .take(2)
                                  .join(' • '),

                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colorScheme
                                        .onSurfaceVariant,
                                  ),

                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 3),

            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VENDOR IMAGE
  // ============================================================

  Widget _buildVendorImage(ColorScheme colorScheme) {
    if (vendor.imageUrls.isEmpty) {
      return Container(
        width: 76,
        height: 76,

        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(13),
        ),

        child: Icon(
          Icons.restaurant_rounded,
          size: 34,
          color: colorScheme.onPrimaryContainer,
        ),
      );
    }

    final imageUrl = vendor.imageUrls.first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),

      child: Image.network(
        imageUrl,

        width: 76,
        height: 76,

        fit: BoxFit.cover,

        errorBuilder: (_, __, ___) {
          return Container(
            width: 76,
            height: 76,

            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),

            child: Icon(
              Icons.restaurant_rounded,
              size: 34,
              color: colorScheme.onPrimaryContainer,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// COLLABORATIVE RECOMMENDATION CARD
// ============================================================

class CollaborativeVendorCard extends StatelessWidget {
  final dynamic recommendation;

  final bool adminMode;

  const CollaborativeVendorCard({
    super.key,
    required this.recommendation,
    required this.adminMode,
  });

  @override
  Widget build(BuildContext context) {
    final vendor = recommendation.vendor;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 260,

      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        clipBehavior: Clip.antiAlias,

        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorDetailsView(
                  vendor: vendor,
                  adminMode: adminMode,
                ),
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // VENDOR IMAGE
                // ==================================================

                _buildCollaborativeImage(colorScheme),

                const SizedBox(width: 11),

                // ==================================================
                // VENDOR INFORMATION
                // ==================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // ==================================================
                      // VENDOR NAME
                      // ==================================================

                      Text(
                        vendor.name,

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 5),

                      // ==================================================
                      // REASON
                      // ==================================================

                      Text(
                        'Because you liked',

                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color:
                                  colorScheme.onSurfaceVariant,
                            ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        recommendation.basedOnVendorName,

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COLLABORATIVE VENDOR IMAGE
  // ============================================================

  Widget _buildCollaborativeImage(
    ColorScheme colorScheme,
  ) {
    if (recommendation.vendor.imageUrls.isEmpty) {
      return Container(
        width: 70,
        height: 70,

        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(11),
        ),

        child: Icon(
          Icons.restaurant_rounded,
          size: 30,
          color: colorScheme.onPrimaryContainer,
        ),
      );
    }

    final imageUrl =
        recommendation.vendor.imageUrls.first;

    return ClipRRect(
      borderRadius: BorderRadius.circular(11),

      child: Image.network(
        imageUrl,

        width: 70,
        height: 70,

        fit: BoxFit.cover,

        errorBuilder: (_, __, ___) {
          return Container(
            width: 70,
            height: 70,

            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(
              Icons.restaurant_rounded,
              size: 30,
              color: colorScheme.onPrimaryContainer,
            ),
          );
        },
      ),
    );
  }
}

