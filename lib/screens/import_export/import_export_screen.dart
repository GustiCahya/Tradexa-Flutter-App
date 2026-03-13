import 'package:flutter/material.dart';

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💾 Data Management: MT5 XML',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your data belongs to you. The Data Management page allows for seamless transitions between devices and platforms. Whether you are migrating from MetaTrader 5 or backing up your local journal, our "Offline-First" approach ensures your sensitive data never touches a cloud server without your consent.',
            ),
            const SizedBox(height: 24),
            _buildFeatureSection(
              context,
              'MetaTrader 5 (MT5) Integration',
              '• Native XML Support: Directly import your trading history exported from the MetaTrader 5 desktop platform.\n'
                  '• Smart Mapping: The app automatically maps MT5 fields (Symbol, Type, Volume, Open/Close Time, Profit) into the local Isar database.\n'
                  '• Duplicate Protection: Our algorithm detects and skips trades that have already been imported to prevent data clutter.',
            ),
            const Divider(height: 48),
            Text(
              'Export Features',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureSection(
              context,
              '1. Universal XML Export (Premium)',
              '• Spreadsheet Ready: Export your entire journal into a .xml file compatible with Microsoft Excel, Google Sheets, or Numbers.\n'
                  '• Full Data Points: Includes all recorded fields, including your custom notes, emotions, and R:R ratios.',
            ),
            _buildFeatureSection(
              context,
              '2. Local Backup Container (.zip)',
              '• Complete Migration: Export a single encrypted package containing your database (XML) and all attached HTF/LTF chart images.\n'
                  '• Device-to-Device Transfer: Simply move this file to a new device and use the "Restore" function to populate your entire journal, including visual attachments.',
            ),
            const Divider(height: 48),
            Text(
              'How to Import from MT5',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Open your MT5 Desktop Terminal.\n'
              '2. Go to the History tab.\n'
              '3. Right-click anywhere and select Report > XML (HTML).\n'
              '4. Transfer the file to your mobile device.\n'
              '5. Select the file via the Import button in this app.',
            ),
            const SizedBox(height: 32),
            const Text(
              '*Premium Benefit: Unlimited XML imports and XML exporting are part of the Pro/Lifetime plan.*',
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
