import 'current_weather.dart';
import 'daily_forecast.dart';

class Weather {
  final CurrentWeather current;
  final List<DailyForecast> forecast;

  const Weather({
    required this.current,
    required this.forecast,
  });
}
