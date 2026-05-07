import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/weather_model.dart';

// WeatherCard — only renders weather data (SRP)
class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('weatherCard'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text('Current Weather', style: _white(context, 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accent, shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text('Live', style: _white(context, 11)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Text(
            '${weather.emoji} ${weather.temperature.toStringAsFixed(1)}°C',
            style: _white(context, 32, bold: true),
          ),
          const Spacer(),
          Text(weather.condition, style: _white(context, 14)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _chip(context, Icons.air, '${weather.windSpeed} km/h'),
          const SizedBox(width: 16),
          _chip(context, Icons.water_drop_outlined, '${weather.humidity}%'),
          const SizedBox(width: 16),
          _chip(context, Icons.thermostat, '${weather.feelsLike.toStringAsFixed(1)}°C'),
        ]),
      ]),
    );
  }

  Widget _chip(BuildContext ctx, IconData icon, String label) => Row(children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(label, style: _white(ctx, 12)),
      ]);

  TextStyle _white(BuildContext ctx, double size, {bool bold = false}) =>
      TextStyle(color: Colors.white, fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal);
}

// Skeleton shown while weather loads
class WeatherCardSkeleton extends StatelessWidget {
  const WeatherCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('weatherSkeleton'),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.textMuted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
