class Env {
  static const openWeatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY');

  static bool get hasApiKey => openWeatherApiKey.trim().isNotEmpty;
}
