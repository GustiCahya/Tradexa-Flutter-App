import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/trade.dart';
import '../../providers/trade_provider.dart';

// ── Constants matching Tradexa web app ──────────────────────────────────────

const List<String> _pairOptions = [
  'EURUSD',
  'GBPUSD',
  'USDJPY',
  'AUDUSD',
  'USDCAD',
  'USDCHF',
  'NZDUSD',
  'GBPJPY',
  'XAUUSD',
  'XAGUSD',
  'BTCUSD',
  'ETHUSD',
  'SPX500',
  'NAS100',
  'US30',
  'US2000',
  'USTEC',
];

const List<String> _sessionOptions = ['London', 'New York', 'Asian', 'Overlap'];

const List<String> _directionOptions = ['LONG', 'SHORT'];

const List<String> _emotionOptions = [
  'Neutral',
  'Disciplined',
  'Confident',
  'Greedy',
  'Fearful',
  'Anxious',
  'Frustrated',
];

// ── Screen ──────────────────────────────────────────────────────────────────

class TradeFormScreen extends ConsumerStatefulWidget {
  final String? tradeId;

  const TradeFormScreen({super.key, this.tradeId});

  @override
  ConsumerState<TradeFormScreen> createState() => _TradeFormScreenState();
}

class _TradeFormScreenState extends ConsumerState<TradeFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _pnlController = TextEditingController();
  final _rrController = TextEditingController();
  final _pairController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingTrade = false;
  bool _isSyncing = false;

  bool get _isEditing => widget.tradeId != null;

  @override
  void initState() {
    super.initState();
    _pnlController.addListener(_syncMinusPnlToRr);
    _rrController.addListener(_syncMinusRrToPnl);
    if (_isEditing) {
      _loadTrade();
    }
  }

  @override
  void dispose() {
    _pnlController.dispose();
    _rrController.dispose();
    _pairController.dispose();
    super.dispose();
  }

  // ── PNL / RR sign-sync (guarded) ────────────────────────────────────────

  void _syncMinusPnlToRr() {
    if (_isSyncing) return;
    _isSyncing = true;
    final pnlText = _pnlController.text;
    final rrText = _rrController.text;
    if (pnlText.startsWith('-') &&
        !rrText.startsWith('-') &&
        rrText.isNotEmpty) {
      _rrController.text = '-$rrText';
    } else if (!pnlText.startsWith('-') && rrText.startsWith('-')) {
      _rrController.text = rrText.substring(1);
    }
    _isSyncing = false;
  }

  void _syncMinusRrToPnl() {
    if (_isSyncing) return;
    _isSyncing = true;
    final rrText = _rrController.text;
    final pnlText = _pnlController.text;
    if (rrText.startsWith('-') &&
        !pnlText.startsWith('-') &&
        pnlText.isNotEmpty) {
      _pnlController.text = '-$pnlText';
    } else if (!rrText.startsWith('-') && pnlText.startsWith('-')) {
      _pnlController.text = pnlText.substring(1);
    }
    _isSyncing = false;
  }

  // ── Load existing trade for editing ─────────────────────────────────────

  Future<void> _loadTrade() async {
    // Attempt to load from Riverpod / Isar cache instantly without loading spinner
    final trades = ref.read(tradesProvider).value;
    final trade = trades?.where((t) => t.id == widget.tradeId).firstOrNull;

    if (trade != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _formKey.currentState?.patchValue({
          'pair': trade.pair,
          'date': trade.date,
          'session': trade.session,
          'direction': trade.direction,
          'entryTF': trade.entryTF,
          'emotion': trade.emotion,
          'notes': trade.notes ?? '',
        });

        _pairController.text = trade.pair;

        _isSyncing = true;
        _pnlController.text = trade.pnl.toString();
        _rrController.text = trade.rr.toString();
        _isSyncing = false;
      });
      return;
    }

    setState(() => _isLoadingTrade = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trade not found locally. Please ensure it synced.'),
        ),
      );
    }
  }

  // ── Day helper ──────────────────────────────────────────────────────────

  String _dayFromDate(DateTime date) => DateFormat('EEEE').format(date);

  // ── Submit ──────────────────────────────────────────────────────────────

  void _submit() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() => _isLoading = true);
    final values = _formKey.currentState!.value;
    final date = values['date'] as DateTime;

    // Clean standalone '-' from PNL / RR
    String pnlRaw = _pnlController.text.trim();
    String rrRaw = _rrController.text.trim();
    if (pnlRaw == '-') pnlRaw = '0';
    if (rrRaw == '-') rrRaw = '0';

    final body = <String, dynamic>{
      'pair': _pairController.text.trim(),
      'date': date.toUtc().toIso8601String(),
      'session': values['session'],
      'entryTF': values['entryTF'],
      'direction': values['direction'],
      'pnl': double.tryParse(pnlRaw) ?? 0,
      'rr': double.tryParse(rrRaw) ?? 0,
      'day': _dayFromDate(date),
      'emotion': values['emotion'],
      'notes': values['notes'],
    };

    try {
      final newTrade = Trade.create(
        id: _isEditing
            ? widget.tradeId!
            : DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '', // Optional depending on how your API manages users locally
        pair: body['pair'] as String,
        date: date,
        session: body['session'] as String,
        entryTF: body['entryTF'] as String,
        direction: body['direction'] as String,
        pnl: body['pnl'] as double,
        rr: body['rr'] as double,
        day: body['day'] as String,
        emotion: body['emotion'] as String,
        notes: body['notes'] as String?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (!_isEditing) {
        // addTrade will save to Isar -> UI updates instantly, syncs via background API
        await ref.read(tradesProvider.notifier).addTrade(newTrade);
      } else {
        await ref.read(tradesProvider.notifier).updateTrade(newTrade);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Trade' : 'Log Trade')),
      body: _isLoadingTrade
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Pair / Symbol (Autocomplete) ───────────────────
                    Autocomplete<String>(
                      initialValue: TextEditingValue(
                        text: _pairController.text,
                      ),
                      optionsBuilder: (textEditingValue) {
                        final query = textEditingValue.text.toUpperCase();
                        if (query.isEmpty) return _pairOptions;
                        return _pairOptions.where(
                          (p) => p.toUpperCase().contains(query),
                        );
                      },
                      onSelected: (selected) {
                        _pairController.text = selected;
                        _formKey.currentState?.fields['pair']?.didChange(
                          selected,
                        );
                      },
                      fieldViewBuilder:
                          (
                            context,
                            textEditingController,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            // Keep our controller in sync with the autocomplete controller
                            textEditingController.addListener(() {
                              _pairController.text = textEditingController.text;
                            });
                            if (_pairController.text.isNotEmpty &&
                                textEditingController.text.isEmpty) {
                              textEditingController.text = _pairController.text;
                            }
                            return FormBuilderTextField(
                              name: 'pair',
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Pair / Symbol',
                                hintText: 'e.g. EURUSD, XAUUSD, BTCUSD',
                              ),
                              textCapitalization: TextCapitalization.characters,
                              validator: FormBuilderValidators.required(
                                errorText: 'Pair is required',
                              ),
                              onChanged: (val) =>
                                  _pairController.text = val ?? '',
                            );
                          },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).canvasColor,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                                maxWidth: 300,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    dense: true,
                                    title: Text(option),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Date & Time ───────────────────────────────────
                    FormBuilderDateTimePicker(
                      name: 'date',
                      inputType: InputType.both,
                      decoration: const InputDecoration(
                        labelText: 'Date & Time',
                        hintText: 'Select date and time of the trade',
                      ),
                      initialValue: DateTime.now(),
                    ),
                    const SizedBox(height: 16),

                    // ── Session + Direction row ───────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderDropdown<String>(
                            name: 'session',
                            decoration: const InputDecoration(
                              labelText: 'Session',
                            ),
                            initialValue: 'London',
                            items: _sessionOptions
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormBuilderDropdown<String>(
                            name: 'direction',
                            decoration: const InputDecoration(
                              labelText: 'Direction',
                            ),
                            items: _directionOptions
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── PnL + RR row ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            name: 'pnl',
                            controller: _pnlController,
                            decoration: const InputDecoration(
                              labelText: 'PnL (\$)',
                              hintText: 'e.g. 150 or -75',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                              decimal: true,
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FormBuilderTextField(
                            name: 'rr',
                            controller: _rrController,
                            decoration: const InputDecoration(
                              labelText: 'Risk / Reward',
                              hintText: 'e.g. 2 or -1.5',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: true,
                              decimal: true,
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Entry Timeframe ───────────────────────────────
                    FormBuilderTextField(
                      name: 'entryTF',
                      decoration: const InputDecoration(
                        labelText: 'Entry Timeframe',
                        hintText: 'e.g. 1m, 5m',
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 16),

                    // ── Emotion ───────────────────────────────────────
                    FormBuilderDropdown<String>(
                      name: 'emotion',
                      decoration: const InputDecoration(
                        labelText: 'Emotion',
                        hintText: 'How did you feel during this trade?',
                      ),
                      initialValue: 'Neutral',
                      items: _emotionOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // ── Notes ─────────────────────────────────────────
                    FormBuilderTextField(
                      name: 'notes',
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText:
                            'Describe your setup, mistakes, or reflections...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // ── Submit ─────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(_isEditing ? 'Update Trade' : 'Save Trade'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
