import 'package:flutter/material.dart';
import 'package:fyp_application/constants/lists.dart';
import 'package:fyp_application/utils/time_utils.dart';

class VendorFilterResult {
  final List<String> selectedTags;
  final String hours;
  final String priceRange;
  final String sortBy;

  const VendorFilterResult({
    this.selectedTags = const [],
    this.hours = 'Any',
    this.priceRange = 'Any',
    this.sortBy = 'Default',
  });
}

class VendorFilter extends StatefulWidget {
  final VendorFilterResult? initialFilter;

  const VendorFilter({super.key, this.initialFilter});

  @override
  State<VendorFilter> createState() => _VendorFilterState();
}

class _VendorFilterState extends State<VendorFilter> {
  late List<String> _selectedTags;

  TimeOfDay? _selectedTime;

  late String _priceRange;
  late String _sortBy;

  @override
  void initState() {
    super.initState();

    _selectedTags = List<String>.from(widget.initialFilter?.selectedTags ?? []);

    _priceRange = widget.initialFilter?.priceRange ?? 'Any';

    _sortBy = widget.initialFilter?.sortBy ?? 'Default';

    final savedHours = widget.initialFilter?.hours;

    if (savedHours != null && savedHours != 'Any') {
      _selectedTime = TimeUtils.parseTime(savedHours);
    }
  }

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  void _clearFilters() {
    setState(() {
      _selectedTags.clear();
      _selectedTime = null;
      _priceRange = 'Any';
      _sortBy = 'Default';
    });
  }

  // ============================================================
  // SELECT TIME
  // ============================================================

  Future<void> _selectTime() async {
    final time = await TimeUtils.selectTime(
      context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 12, minute: 0),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  // ============================================================
  // APPLY FILTERS
  // ============================================================

  void _applyFilters() {
    Navigator.pop(
      context,
      VendorFilterResult(
        selectedTags: List<String>.from(_selectedTags),

        hours: _selectedTime == null
            ? 'Any'
            : TimeUtils.formatTime(_selectedTime!),

        priceRange: _priceRange,

        sortBy: _sortBy,
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  // ============================================================
  // FIELD DECORATION
  // ============================================================

  InputDecoration _fieldDecoration({required IconData icon}) {
    final colorScheme = Theme.of(context).colorScheme;

    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),

      filled: true,

      fillColor: colorScheme.surfaceContainerHighest,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter & Sort',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: _clearFilters,

                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),

                    child: const Text('Clear'),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ==================================================
              // TAGS
              // ==================================================
              _sectionTitle(context, 'Tags'),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: AppLists.vendorTags.map((tag) {
                  final selected = _selectedTags.contains(tag);

                  return FilterChip(
                    label: Text(tag),

                    selected: selected,

                    showCheckmark: true,

                    onSelected: (value) {
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

              const SizedBox(height: 26),

              // ==================================================
              // HOURS
              // ==================================================
              _sectionTitle(context, 'Hours'),

              const SizedBox(height: 10),

              InkWell(
                onTap: _selectTime,

                borderRadius: BorderRadius.circular(12),

                child: InputDecorator(
                  decoration: _fieldDecoration(icon: Icons.access_time_rounded),

                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedTime == null
                              ? 'Any time'
                              : 'Open at ${TimeUtils.formatTime(_selectedTime!)}',
                        ),
                      ),

                      if (_selectedTime != null)
                        IconButton(
                          tooltip: 'Clear time',

                          padding: EdgeInsets.zero,

                          constraints: const BoxConstraints(),

                          icon: Icon(
                            Icons.close_rounded,
                            size: 19,
                            color: colorScheme.onSurfaceVariant,
                          ),

                          onPressed: () {
                            setState(() {
                              _selectedTime = null;
                            });
                          },
                        ),

                      const SizedBox(width: 8),

                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ==================================================
              // PRICE
              // ==================================================
              _sectionTitle(context, 'Price'),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _priceRange,

                decoration: _fieldDecoration(icon: Icons.attach_money_rounded),

                items: [
                  const DropdownMenuItem<String>(
                    value: 'Any',
                    child: Text('Any price'),
                  ),

                  ...AppLists.priceRanges.map(
                    (price) => DropdownMenuItem<String>(
                      value: price,
                      child: Text(price),
                    ),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _priceRange = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 26),

              // ==================================================
              // SORT
              // ==================================================
              _sectionTitle(context, 'Sort by'),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _sortBy,

                decoration: _fieldDecoration(icon: Icons.sort_rounded),
                items: AppLists.sortOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortBy = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 30),

              // ==================================================
              // APPLY
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 52,

                child: FilledButton(
                  onPressed: _applyFilters,

                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
