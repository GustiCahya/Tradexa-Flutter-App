import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../dashboard/dashboard_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _pnlController.addListener(_syncMinusPnlToRr);
    _rrController.addListener(_syncMinusRrToPnl);
    if (widget.tradeId != null) {
      _loadTrade();
    }
  }

  void _syncMinusPnlToRr() {
    final pnlText = _pnlController.text;
    final rrText = _rrController.text;
    if (pnlText.startsWith('-') && !rrText.startsWith('-')) {
      _rrController.text = '-$rrText';
    } else if (!pnlText.startsWith('-') && rrText.startsWith('-')) {
      _rrController.text = rrText.substring(1);
    }
  }

  void _syncMinusRrToPnl() {
    final rrText = _rrController.text;
    final pnlText = _pnlController.text;
    if (rrText.startsWith('-') && !pnlText.startsWith('-')) {
      _pnlController.text = '-$pnlText';
    } else if (!rrText.startsWith('-') && pnlText.startsWith('-')) {
      _pnlController.text = pnlText.substring(1);
    }
  }

  Future<void> _loadTrade() async {
    // Implement fetch logic to populate form for editing
  }

  void _submit() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    setState(() => _isLoading = true);
    final values = _formKey.currentState!.value;

    final body = {
      'pair': values['pair'],
      'date': (values['date'] as DateTime).toUtc().toIso8601String(),
      'session': values['session'],
      'entryTF': values['entryTF'],
      'direction': values['direction'],
      'pnl': double.tryParse(_pnlController.text) ?? 0,
      'rr': double.tryParse(_rrController.text) ?? 0,
      'day': 'Monday', // Compute from date or add field
      'emotion': values['emotion'],
      'notes': values['notes'],
    };

    try {
      final api = ApiService();
      if (widget.tradeId == null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tradeId == null ? 'Log Trade' : 'Edit Trade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'pair',
                decoration: const InputDecoration(
                  labelText: 'Pair (e.g., EUR/USD)',
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderDateTimePicker(
                name: 'date',
                inputType: InputType.both,
                decoration: const InputDecoration(labelText: 'Date & Time'),
                initialValue: DateTime.now(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'session',
                      decoration: const InputDecoration(labelText: 'Session'),
                      items: ['London', 'New York', 'Asian', 'Frankfurt']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderDropdown<String>(
                      name: 'direction',
                      decoration: const InputDecoration(labelText: 'Direction'),
                      items: ['LONG', 'SHORT']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'pnl',
                      controller: _pnlController,
                      decoration: const InputDecoration(labelText: 'PnL (\$)'),
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
                        labelText: 'Risk/Reward',
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
              FormBuilderTextField(
                name: 'entryTF',
                decoration: const InputDecoration(
                  labelText: 'Timeframe (e.g., 5m)',
                ),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'emotion',
                decoration: const InputDecoration(labelText: 'Emotion'),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          widget.tradeId == null
                              ? 'Save Trade'
                              : 'Update Trade',
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
