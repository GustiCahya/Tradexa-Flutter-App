import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trades Calendar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 Trades Calendar Performance',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'The Trades Calendar provides a visual bird\'s-eye view of your trading activity. It helps traders identify behavioral patterns, such as overtrading on specific days or performance streaks, by mapping daily PnL directly onto a monthly calendar grid.',
            ),
            const SizedBox(height: 24),
            _buildFeatureSection(
              context,
              '1. Monthly Performance Grid',
              '• Visual PnL Indicators: Each day cell displays a color-coded indicator (Green for Profit, Red for Loss, Grey for Break-even/No Trades).\n'
                  '• Daily Summary: Hover or tap on a specific date to see the total realized PnL and the number of trades executed that day.',
            ),
            _buildFeatureSection(
              context,
              '2. Interactive Date Selection',
              '• Detailed Daily View: Selecting a date will populate a list of all trades executed within that 24-hour window below the calendar.\n'
                  '• Quick Navigation: Jump between months and years to review long-term historical data.',
            ),
            _buildFeatureSection(
              context,
              '3. Performance Insights (Premium)',
              '• Equity Heatmap: Darker shades of green/red represent higher magnitude of wins or losses, allowing for instant identification of "Big Win" or "Big Loss" days.\n'
                  '• Daily Statistics: View specific stats for the selected day, including:\n'
                  '    - Win Rate %\n'
                  '    - Average Risk/Reward (R:R)\n'
                  '    - Total pips/points gained.',
            ),
            const SizedBox(height: 32),
            const Text(
              '*Note: The basic calendar view is available for all users. Full trade details and deep analytics per date are exclusive to Premium subscribers.*',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(
    BuildContext context,
    String title,
    String content,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}
