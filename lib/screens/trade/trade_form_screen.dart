import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../dashboard/dashboard_screen.dart';

// ── Constants matching Tradexa web app ──────────────────────────────────────

const List<String> _pairOptions = [
  'EUR/USD',
  'GBP/USD',
  'USD/JPY',
  'AUD/USD',
  'USD/CAD',
  'USD/CHF',
  'NZD/USD',
  'GBP/JPY',
  'XAU/USD',
  'BTC/USD',
  'ETH/USD',
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
    setState(() => _isLoadingTrade = true);
    try {
      final api = ApiService();
      final response = await api.get('/trades/${widget.tradeId}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Support both { "trade": { ... } } and direct { ... }
        final Map<String, dynamic> tradeJson =
            decoded is Map<String, dynamic> && decoded.containsKey('trade')
            ? decoded['trade']
            : decoded;

        // Wait for the form to be built before patching
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final date = tradeJson['date'] != null
              ? DateTime.parse(tradeJson['date']).toLocal()
              : DateTime.now();

          _formKey.currentState?.patchValue({
            'pair': tradeJson['pair']?.toString() ?? '',
            'date': date,
            'session': tradeJson['session']?.toString(),
            'direction': tradeJson['direction']?.toString(),
            'entryTF': tradeJson['entryTF']?.toString() ?? '',
            'emotion': tradeJson['emotion']?.toString(),
            'notes': tradeJson['notes']?.toString() ?? '',
          });

          _isSyncing = true;
          _pnlController.text = (tradeJson['pnl'] ?? 0).toString();
          _rrController.text = (tradeJson['rr'] ?? 0).toString();
          _isSyncing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load trade: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingTrade = false);
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
      'pair': values['pair'],
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
      final api = ApiService();
      if (!_isEditing) {
        await api.post('/trades', body);
      } else {
        body['id'] = widget.tradeId;
        await api.put('/trades', body);
      }

      ref.refresh(tradesProvider);
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
                    // ── Pair ───────────────────────────────────────────
                    FormBuilderDropdown<String>(
                      name: 'pair',
                      decoration: const InputDecoration(
                        labelText: 'Pair / Symbol',
                      ),
                      items: _pairOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 16),

                    // ── Date & Time ───────────────────────────────────
                    FormBuilderDateTimePicker(
                      name: 'date',
                      inputType: InputType.both,
                      decoration: const InputDecoration(
                        labelText: 'Date & Time',
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
                      decoration: const InputDecoration(labelText: 'Emotion'),
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
                      decoration: const InputDecoration(labelText: 'Notes'),
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
