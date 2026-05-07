import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/developer_contact.dart';
import '../../core/theme/app_theme.dart';

/// About Me — developer profile for the Smart Travel Companion app.
class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ClipOval(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Image.asset(
                  'lib/images/My Pic.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    child: Icon(Icons.person, size: 64, color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Muhammad Hunain',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Who I Am',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "I'm a Computer Science student at NUCES-FAST (Karachi) "
            ', passionate about building exceptional full-stack applications.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'My expertise spans the MERN stack, Next.js, and FAST API. I specialize in '
            'scalable web application development using MUI, Tailwind CSS, and Redux. '
            'Experienced in DevOps technologies including AWS, Docker, Kubernetes, and CI/CD pipelines.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'I believe great software is born from clean code, performance optimization, '
            'and agile development practices. Every project is an opportunity to push '
            'boundaries with microservices architecture, API development, and cloud computing.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            icon: const Icon(Icons.language),
            label: const Text('Portfolio website'),
            onPressed: () => _openUrl(context, kDeveloperPortfolioUrl),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.work_outline),
            label: const Text('LinkedIn'),
            onPressed: () => _openUrl(context, kDeveloperLinkedInUrl),
          ),
        ],
      ),
    );
  }
}
