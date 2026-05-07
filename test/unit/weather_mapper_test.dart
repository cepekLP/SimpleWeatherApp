import 'package:flutter_test/flutter_test.dart';
import 'package:simple_weather_app/features/weather/data/weather_mapper.dart';

void main() {
  test('maps One Call payload to domain weather model', () {
    final json = <String, dynamic>{
      'current': {
        'temp': 20.5,
        'feels_like': 19.8,
        'humidity': 77,
        'wind_speed': 3.2,
        'sunrise': 1714722000,
        'sunset': 1714771200,
        'weather': [
          {'description': 'clear sky', 'icon': '01d'},
        ],
      },
      'daily': [
        {
          'dt': 1714809600,
          'temp': {'day': 21.0, 'min': 15.0, 'max': 23.0},
          'weather': [
            {'description': 'few clouds', 'icon': '02d'},
          ],
        },
      ],
    };

    final weather = WeatherMapper.fromOneCallJson(json);

    expect(weather.current.temperature, 20.5);
    expect(weather.current.feelsLike, 19.8);
    expect(weather.current.humidity, 77);
    expect(weather.current.windSpeed, 3.2);
    expect(weather.current.description, 'clear sky');
    expect(weather.current.iconCode, '01d');
    expect(weather.current.sunrise.hour, isNotNull);
    expect(weather.current.sunset.hour, isNotNull);
    expect(weather.forecast.length, 1);
    expect(weather.forecast.first.date.year, 2024);
    expect(weather.forecast.first.dayTemp, 21.0);
    expect(weather.forecast.first.minTemp, 15.0);
    expect(weather.forecast.first.maxTemp, 23.0);
    expect(weather.forecast.first.description, 'few clouds');
    expect(weather.forecast.first.iconCode, '02d');
  });
}
