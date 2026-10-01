import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  final double fontSize;
  final bool showTagline;

  const Logo({
    super.key,
    this.fontSize = 60,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Kaanvee',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: -0.8,
          ),
        ),

        if (showTagline) ...[
          const SizedBox(height: 6),

          Text(
            'Community guide to great food',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

