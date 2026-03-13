import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/trade_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradesAsync = ref.watch(tradesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Center')),
      body: tradesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (trades) {
          if (trades.isEmpty) {
            return const Center(
              child: Text('Not enough data to generate analytics.'),
            );
          }

          // Sort trades chronologically
          final sortedTrades = [...trades]
            ..sort((a, b) => a.date.compareTo(b.date));

          // Calculate PnL Curve Data
          double currentPnl = 0;
          final List<FlSpot> spots = [];
          for (int i = 0; i < sortedTrades.length; i++) {
            currentPnl += sortedTrades[i].pnl;
            spots.add(FlSpot(i.toDouble(), currentPnl));
          }

          // Calculate Session Avg RR Data
          final Map<String, List<double>> sessionRRs = {
            'London': [],
            'New York': [],
            'Asian': [],
            'Frankfurt': [],
          };
          for (var t in trades) {
            if (sessionRRs.containsKey(t.session)) {
              sessionRRs[t.session]!.add(t.rr);
            }
          }

          final List<BarChartGroupData> barGroups = [];
          int xIndex = 0;
          sessionRRs.forEach((session, rrs) {
            double avg = rrs.isNotEmpty
                ? rrs.reduce((a, b) => a + b) / rrs.length
                : 0;
            barGroups.add(
              BarChartGroupData(
                x: xIndex,
                barRods: [
                  BarChartRodData(
                    toY: avg,
                    color: avg >= 2
                        ? AppColors.successLight
                        : AppColors.textMuted,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
            xIndex++;
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cumulative PnL',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          titlesData: const FlTitlesData(
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.brandPrimary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.brandPrimary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Average RR by Session',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final sessions = sessionRRs.keys.toList();
                                  if (val.toInt() >= 0 &&
                                      val.toInt() < sessions.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        sessions[val.toInt()],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: barGroups,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
