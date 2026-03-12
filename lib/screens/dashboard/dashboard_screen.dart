import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/trade.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

final tradesProvider = FutureProvider<List<Trade>>((ref) async {
  final api = ApiService();
  final response = await api.get('/trades');
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((e) => Trade.fromJson(e)).toList();
  }
  return []; // return empty or handle error
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradesAsync = ref.watch(tradesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tradexa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => context.push('/trade-input'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.barChart2),
            onPressed: () => context.push('/summary'),
          ),
        ],
      ),
      body: tradesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (trades) {
          final totalTrades = trades.length;
          final winningTrades = trades.where((t) => t.pnl > 0).length;
          final winRate = totalTrades > 0
              ? (winningTrades / totalTrades) * 100
              : 0.0;
          final totalPnl = trades.fold(0.0, (sum, t) => sum + t.pnl);
          final avgRr = totalTrades > 0
              ? trades.fold(0.0, (sum, t) => sum + t.rr) / totalTrades
              : 0.0;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(tradesProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      title: 'Total PnL',
                      value: '\$${totalPnl.toStringAsFixed(2)}',
                      valueColor: totalPnl >= 0
                          ? AppColors.successLight
                          : AppColors.dangerLight,
                    ),
                    _StatCard(
                      title: 'Win Rate',
                      value: '${winRate.toStringAsFixed(1)}%',
                    ),
                    _StatCard(title: 'Total Trades', value: '$totalTrades'),
                    _StatCard(
                      title: 'Average RR',
                      value: '${avgRr.toStringAsFixed(2)}R',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Recent Trades',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (trades.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No trades yet. Add one!'),
                    ),
                  )
                else
                  ...trades.map((trade) => _TradeRow(trade: trade)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _StatCard({required this.title, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradeRow extends ConsumerWidget {
  final Trade trade;

  const _TradeRow({required this.trade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWin = trade.pnl > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/trade-input?id=${trade.id}'),
        onLongPress: () {
          // Implement delete
          showDialog(
            context: context,
            builder: (c) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Delete Trade?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(c);
                    await ApiService().delete('/trades/${trade.id}');
                    ref.refresh(tradesProvider);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.dangerLight),
                  ),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trade.pair,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${trade.session} • ${trade.entryTF}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${trade.pnl.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isWin
                          ? AppColors.successLight
                          : AppColors.dangerLight,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    '${trade.rr}R',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
