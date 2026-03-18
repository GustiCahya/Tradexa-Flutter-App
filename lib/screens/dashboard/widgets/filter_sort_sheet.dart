import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/trade_filter_provider.dart';

class FilterSortSheet extends ConsumerStatefulWidget {
  const FilterSortSheet({super.key});

  @override
  ConsumerState<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends ConsumerState<FilterSortSheet> {
  // Options constants
  static const List<String> _sessionOptions = [
    'All',
    'London',
    'New York',
    'Asian',
    'Overlap',
  ];
  static const List<String> _directionOptions = ['All', 'LONG', 'SHORT'];
  static const List<String> _emotionOptions = [
    'All',
    'Neutral',
    'Disciplined',
    'Confident',
    'Greedy',
    'Fearful',
    'Anxious',
    'Frustrated',
  ];

  // Local state to hold selections before applying
  late String _selectedSession;
  late String _selectedDirection;
  late String _selectedEmotion;
  late String _selectedPair;

  late TradeSortField _selectedSortField;
  late bool _sortAscending;

  final _pairController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(tradeFilterNotifierProvider);
    _selectedSession = currentFilter.session ?? 'All';
    _selectedDirection = currentFilter.direction ?? 'All';
    _selectedEmotion = currentFilter.emotion ?? 'All';
    _selectedSortField = currentFilter.sortField;
    _sortAscending = currentFilter.sortAscending;
    _selectedPair = currentFilter.pair ?? 'All';

    if (_selectedPair != 'All' && _selectedPair.isNotEmpty) {
      _pairController.text = _selectedPair;
    }
  }

  @override
  void dispose() {
    _pairController.dispose();
    super.dispose();
  }

  void _apply() {
    final pair = _pairController.text.trim();

    ref
        .read(tradeFilterNotifierProvider.notifier)
        .updateFilter(
          session: _selectedSession,
          direction: _selectedDirection,
          emotion: _selectedEmotion,
          pair: pair.isEmpty ? 'All' : pair,
          sortField: _selectedSortField,
          sortAscending: _sortAscending,
        );
    Navigator.pop(context);
  }

  void _reset() {
    ref.read(tradeFilterNotifierProvider.notifier).reset();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filter & Sort',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Sort Options
            Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TradeSortField>(
                    value: _selectedSortField,
                    decoration: const InputDecoration(labelText: 'Field'),
                    items: TradeSortField.values.map((field) {
                      return DropdownMenuItem(
                        value: field,
                        child: Text(field.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSortField = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<bool>(
                    value: _sortAscending,
                    decoration: const InputDecoration(labelText: 'Order'),
                    items: const [
                      DropdownMenuItem(value: false, child: Text('Descending')),
                      DropdownMenuItem(value: true, child: Text('Ascending')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortAscending = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Options
            Text('Filters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _pairController,
              decoration: const InputDecoration(
                labelText: 'Pair (e.g. EURUSD)',
                hintText: 'Leave empty for all',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDirection,
              decoration: const InputDecoration(labelText: 'Direction'),
              items: _directionOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDirection = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSession,
              decoration: const InputDecoration(labelText: 'Session'),
              items: _sessionOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSession = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEmotion,
              decoration: const InputDecoration(labelText: 'Emotion'),
              items: _emotionOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedEmotion = val);
              },
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset All'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
