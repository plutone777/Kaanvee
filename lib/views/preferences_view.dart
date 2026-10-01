import 'package:flutter/material.dart';
import 'package:fyp_application/constants/lists.dart';
import 'package:fyp_application/models/preferences.dart';
import 'package:fyp_application/models/user.dart';
import 'package:fyp_application/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

class PreferencesView extends StatefulWidget {
  final UserModel user;

  const PreferencesView({
    super.key,
    required this.user,
  });

  @override
  State<PreferencesView> createState() =>
      _PreferencesViewState();
}

class _PreferencesViewState extends State<PreferencesView> {
  late List<String> _selectedTags;
  late List<String> _selectedPriceRanges;

  @override
  void initState() {
    super.initState();

    _selectedTags = List<String>.from(
      widget.user.preferences.preferredTags,
    );

    _selectedPriceRanges = List<String>.from(
      widget.user.preferences.preferredPriceRanges,
    );
  }

  Future<void> _savePreferences() async {
    final updatedPreferences = UserPreferences(
      darkMode: widget.user.preferences.darkMode,
      preferredTags: _selectedTags,
      preferredPriceRanges: _selectedPriceRanges,
    );

    final updatedUser = widget.user.copyWith(
      preferences: updatedPreferences,
    );

    final viewModel = context.read<UserViewModel>();

    final success = await viewModel.updateUser(
      updatedUser,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved successfully.'),
        ),
      );

      Navigator.pop(context, updatedUser);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ??
                'Failed to save preferences.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<UserViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          24,
          16,
          32,
        ),

        children: [
          // =========================================================
          // HEADER
          // =========================================================

          Center(
            child: Column(
              children: [
            

                const SizedBox(height: 12),

                Text(
                  'Tell us what you like so we can personalize '
                  'your recommendations.',
                  textAlign: TextAlign.left,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // =========================================================
          // PREFERRED TAGS
          // =========================================================

          Text(
            'Preferred Tags',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppLists.vendorTags.map((tag) {
              final selected =
                  _selectedTags.contains(tag);

              return FilterChip(
                label: Text(tag),
                selected: selected,
                showCheckmark: true,
                onSelected: viewModel.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          if (value) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // =========================================================
          // PRICE RANGE
          // =========================================================

          Text(
            'Preferred Price Range',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppLists.priceRanges.map((price) {
              final selected =
                  _selectedPriceRanges.contains(price);

              return FilterChip(
                label: Text(price),
                selected: selected,
                showCheckmark: true,
                onSelected: viewModel.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          if (value) {
                            _selectedPriceRanges.add(price);
                          } else {
                            _selectedPriceRanges.remove(price);
                          }
                        });
                      },
              );
            }).toList(),
          ),

          const SizedBox(height: 36),

          // =========================================================
          // SAVE BUTTON
          // =========================================================

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : _savePreferences,

              child: viewModel.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Preferences',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
