import 'package:flutter/material.dart';
import 'package:fyp_application/models/vendor.dart';
import 'info_row.dart';

class VendorInfoSection extends StatelessWidget {
  final VendorModel vendor;

  const VendorInfoSection({
    super.key,
    required this.vendor,
  });

  // ==========================================================
  // CHECK WHETHER THE VENDOR IS CURRENTLY OPEN
  // ==========================================================

  bool _isCurrentlyOpen() {
    if (vendor.operatingHours.isEmpty) {
      return false;
    }

    try {
      // Expected format:
      // "9:00 AM - 10:00 PM"
      final parts = vendor.operatingHours.split('-');

      if (parts.length != 2) {
        return false;
      }

      final openingTime = _parseTime(parts[0].trim());
      final closingTime = _parseTime(parts[1].trim());

      if (openingTime == null || closingTime == null) {
        return false;
      }

      final now = TimeOfDay.now();

      final currentMinutes =
          now.hour * 60 + now.minute;

      final openingMinutes =
          openingTime.hour * 60 + openingTime.minute;

      final closingMinutes =
          closingTime.hour * 60 + closingTime.minute;

      // Normal opening hours
      // Example: 9:00 AM - 10:00 PM
      if (closingMinutes > openingMinutes) {
        return currentMinutes >= openingMinutes &&
            currentMinutes < closingMinutes;
      }

      // Overnight opening hours
      // Example: 6:00 PM - 2:00 AM
      if (closingMinutes < openingMinutes) {
        return currentMinutes >= openingMinutes ||
            currentMinutes < closingMinutes;
      }

      // Same opening and closing time
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================
  // PARSE TIME
  // ==========================================================

  TimeOfDay? _parseTime(String time) {
    try {
      final match = RegExp(
        r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
        caseSensitive: false,
      ).firstMatch(time);

      if (match == null) {
        return null;
      }

      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();

      if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
        return null;
      }

      // Convert 12-hour time to 24-hour time.
      if (period == 'AM') {
        if (hour == 12) {
          hour = 0;
        }
      } else {
        if (hour != 12) {
          hour += 12;
        }
      }

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isOpen = _isCurrentlyOpen();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // BASIC INFORMATION
        // ==========================================

        InfoRow(
          icon: Icons.location_on_outlined,
          text: vendor.location,
        ),

        InfoRow(
          icon: Icons.store_outlined,
          text: vendor.vendorType,
        ),

        if (vendor.operatingHours.isNotEmpty)
          InfoRow(
            icon: Icons.access_time_outlined,
            text: vendor.operatingHours,
          ),

        if (vendor.priceRange.isNotEmpty)
          InfoRow(
            icon: Icons.payments_outlined,
            text: vendor.priceRange,
          ),

        // ==========================================
        // OPEN / CLOSED STATUS
        // ==========================================

        const SizedBox(height: 8),

        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOpen
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              isOpen ? 'Open' : 'Closed',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isOpen
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),

        // ==========================================
        // ABOUT
        // ==========================================

        if (vendor.description.isNotEmpty) ...[
          const SizedBox(height: 24),

          Text(
            'About',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            vendor.description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],

        // ==========================================
        // TAGS
        // ==========================================

        if (vendor.tags.isNotEmpty) ...[
          const SizedBox(height: 24),

          Text(
            'Tags',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: vendor.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
