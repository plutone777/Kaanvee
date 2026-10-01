import 'package:flutter/material.dart';
import 'package:fyp_application/models/vendor.dart';

class VendorContactSection extends StatelessWidget {
  final VendorModel vendor;

  const VendorContactSection({
    super.key,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    final contacts = <_ContactItem>[
      if (_hasValue(vendor.phone))
        _ContactItem(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: vendor.phone!,
        ),

      if (_hasValue(vendor.whatsapp))
        _ContactItem(
          icon: Icons.chat_outlined,
          label: 'WhatsApp',
          value: vendor.whatsapp!,
        ),

      if (_hasValue(vendor.viber))
        _ContactItem(
          icon: Icons.call_outlined,
          label: 'Viber',
          value: vendor.viber!,
        ),

      if (_hasValue(vendor.instagram))
        _ContactItem(
          icon: Icons.camera_alt_outlined,
          label: 'Instagram',
          value: vendor.instagram!,
        ),

      if (_hasValue(vendor.facebook))
        _ContactItem(
          icon: Icons.facebook,
          label: 'Facebook',
          value: vendor.facebook!,
        ),
    ];

    if (contacts.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),

          child: Column(
            children: [
              for (int i = 0; i < contacts.length; i++) ...[
                _ContactRow(
                  contact: contacts[i],
                ),

                if (i < contacts.length - 1)
                  Divider(
                    height: 1,
                    indent: 52,
                    endIndent: 12,
                    color: colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

class _ContactItem {
  final IconData icon;
  final String label;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _ContactRow extends StatelessWidget {
  final _ContactItem contact;

  const _ContactRow({
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),

      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),

            child: Icon(
              contact.icon,
              size: 18,
              color: colorScheme.onPrimaryContainer,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  contact.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}