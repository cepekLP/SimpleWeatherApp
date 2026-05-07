import '../domain/models/current_weather.dart';
import '../domain/models/daily_forecast.dart';
import '../domain/models/weather.dart';

class WeatherMapper {
  static Weather fromOneCallJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final currentWeather = (current['weather'] as List<dynamic>).first
        as Map<String, dynamic>;
    final daily = (json['daily'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    return Weather(
      current: CurrentWeather(
        temperature: (current['temp'] as num).toDouble(),
        feelsLike: (current['feels_like'] as num).toDouble(),
        humidity: (current['humidity'] as num).toInt(),
        windSpeed: (current['wind_speed'] as num).toDouble(),
        description: currentWeather['description'] as String,
        sunrise: DateTime.fromMillisecondsSinceEpoch(
          ((current['sunrise'] as num).toInt()) * 1000,
        ),
        sunset: DateTime.fromMillisecondsSinceEpoch(
          ((current['sunset'] as num).toInt()) * 1000,
        ),
        iconCode: currentWeather['icon'] as String,
      ),
      forecast: daily
          .take(7)
          .map((day) {
            final dayWeather = (day['weather'] as List<dynamic>).first
                as Map<String, dynamic>;
            return DailyForecast(
              date: DateTime.fromMillisecondsSinceEpoch(
                ((day['dt'] as num).toInt()) * 1000,
              ),
              dayTemp: ((day['temp'] as Map<String, dynamic>)['day'] as num)
                  .toDouble(),
              minTemp: ((day['temp'] as Map<String, dynamic>)['min'] as num)
                  .toDouble(),
              maxTemp: ((day['temp'] as Map<String, dynamic>)['max'] as num)
                  .toDouble(),
              description: dayWeather['description'] as String,
              iconCode: dayWeather['icon'] as String,
            );
          })
          .toList(growable: false),
    );
  }
}
