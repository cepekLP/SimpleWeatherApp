import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get openWeatherApiKey =>
      dotenv.maybeGet('OPENWEATHER_API_KEY') ?? '';

  static bool get hasApiKey => openWeatherApiKey.trim().isNotEmpty;
}
