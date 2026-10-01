import 'package:flutter/material.dart';
import 'package:fyp_application/models/collaborative_recommendation.dart';
import 'package:fyp_application/viewmodels/collaborative_recommendation_viewmodel.dart';
import 'package:fyp_application/views/vendor_details_view.dart';
import 'package:provider/provider.dart';

class CollaborativeRecommendationsSection
    extends StatelessWidget {
  final bool adminMode;

  const CollaborativeRecommendationsSection({
    super.key,
    this.adminMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (adminMode) {
      return const SizedBox.shrink();
    }

    return Consumer<CollaborativeRecommendationViewModel>(
      builder: (
        context,
        viewModel,
        child,
      ) {
        if (viewModel.isLoading ||
            viewModel.recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                8,
              ),
              child: Text(
                'You May Also Like',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount:
                    viewModel.recommendations.length,
                itemBuilder: (
                  context,
                  index,
                ) {
                  final recommendation =
                      viewModel.recommendations[
                          index];

                  return _CollaborativeVendorCard(
                    recommendation:
                        recommendation,
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _CollaborativeVendorCard
    extends StatelessWidget {
  final CollaborativeRecommendation
      recommendation;

  const _CollaborativeVendorCard({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final vendor =
        recommendation.vendor;

    return SizedBox(
      width: 250,
      child: Card(
        margin: const EdgeInsets.only(
          right: 12,
        ),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(12),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VendorDetailsView(
                  vendor: vendor,
                ),
              ),
            );
          },

          child: Padding(
            padding:
                const EdgeInsets.all(12),

            child: Row(
              children: [
                // Vendor image
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(8),
                  child: vendor.imageUrls.isNotEmpty
                      ? Image.network(
                          vendor.imageUrls.first,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                _,
                                __,
                                ___,
                              ) {
                            return _placeholder();
                          },
                        )
                      : _placeholder(),
                ),

                const SizedBox(width: 10),

                // Vendor information
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Because you liked '
                        '${recommendation.basedOnVendorName}',
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
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

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.restaurant,
        color: Colors.grey,
      ),
    );
  }
}
