import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/developer_contact.dart';
import '../../core/theme/app_theme.dart';

/// Help & Support — developer contact email and quick mail action.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _mailTo(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: kDeveloperSupportEmail,
      queryParameters: const {
        'subject': 'Smart Travel Companion — Help',
      },
    );
    final ok =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No mail app configured on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Need help?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Reach out to the developer of this app:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              color: AppColors.primary.withValues(alpha: 0.08),
              child: ListTile(
                leading: Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                title: SelectableText(
                  kDeveloperSupportEmail,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                subtitle: const Text('Official support inbox'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy email'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: kDeveloperSupportEmail),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email copied to clipboard')),
                );
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.outgoing_mail),
              label: const Text('Open mail app'),
              onPressed: () => _mailTo(context),
            ),
          ],
        ),
      ),
    );
  }
}
