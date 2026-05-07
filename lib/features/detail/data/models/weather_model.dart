class WeatherModel {
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final String timezone;

  const WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.timezone,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final c = json['current'] as Map<String, dynamic>;
    return WeatherModel(
      temperature: (c['temperature_2m'] as num).toDouble(),
      feelsLike: (c['apparent_temperature'] as num).toDouble(),
      windSpeed: (c['windspeed_10m'] as num).toDouble(),
      humidity: (c['relativehumidity_2m'] as num).toInt(),
      weatherCode: (c['weathercode'] as num).toInt(),
      timezone: json['timezone'] as String? ?? 'UTC',
    );
  }

  // WMO weather codes → human-readable label
  String get condition {
    if (weatherCode == 0) return 'Clear Sky';
    if (weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    if (weatherCode <= 82) return 'Showers';
    return 'Thunderstorm';
  }

  // Returns an icon that matches the condition
  String get emoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '🌨️';
    if (weatherCode <= 82) return '🌦️';
    return '⛈️';
  }
}
