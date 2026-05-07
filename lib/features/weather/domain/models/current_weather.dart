class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final DateTime sunrise;
  final DateTime sunset;
  final String iconCode;

  const CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.sunrise,
    required this.sunset,
    required this.iconCode,
  });
}
