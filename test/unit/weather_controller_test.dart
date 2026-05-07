import 'package:flutter_test/flutter_test.dart';
import 'package:simple_weather_app/features/location/data/device_location_service.dart';
import 'package:simple_weather_app/features/location/data/location_models.dart';
import 'package:simple_weather_app/features/location/data/location_storage.dart';
import 'package:simple_weather_app/features/weather/data/open_weather_service.dart';
import 'package:simple_weather_app/features/weather/domain/models/current_weather.dart';
import 'package:simple_weather_app/features/weather/domain/models/daily_forecast.dart';
import 'package:simple_weather_app/features/weather/domain/models/weather.dart';
import 'package:simple_weather_app/features/weather/presentation/weather_controller.dart';

class FakeWeatherService implements WeatherService {
  bool shouldThrow = false;

  @override
  Future<Weather> fetchWeather({required double lat, required double lon}) async {
    if (shouldThrow) {
      throw const WeatherApiException('boom');
    }

    return Weather(
      current: CurrentWeather(
        temperature: 22,
        feelsLike: 21,
        humidity: 50,
        windSpeed: 2,
        description: 'sunny',
        sunrise: DateTime.fromMillisecondsSinceEpoch(1714722000000),
        sunset: DateTime.fromMillisecondsSinceEpoch(1714771200000),
        iconCode: '01d',
      ),
      forecast: [
        DailyForecast(
          date: DateTime.fromMillisecondsSinceEpoch(1714809600000),
          dayTemp: 23,
          minTemp: 19,
          maxTemp: 24,
          description: 'clear',
          iconCode: '01d',
        ),
      ],
    );
  }

  @override
  Future<List<LocationCandidate>> searchCity(String query) async =>
      const <LocationCandidate>[];
}

class FakeLocationService implements DeviceLocationService {
  @override
  Future<Coordinates> getCurrentCoordinates() async =>
      const Coordinates(lat: 50.1, lon: 19.9);
}

class InMemoryLocationStorage extends LocationStorage {
  SavedLocation? value;

  @override
  Future<SavedLocation?> load() async => value;

  @override
  Future<void> save({
    required String label,
    required Coordinates coordinates,
  }) async {
    value = SavedLocation(label: label, coordinates: coordinates);
  }
}

void main() {
  test('controller sets success state when current location weather fetch succeeds', () async {
    final controller = WeatherController(
      weatherService: FakeWeatherService(),
      locationService: FakeLocationService(),
      storage: InMemoryLocationStorage(),
    );

    await controller.useCurrentLocation();

    expect(controller.status, WeatherViewStatus.success);
    expect(controller.weather, isNotNull);
  });

  test('controller sets error state when weather fetch fails', () async {
    final service = FakeWeatherService()..shouldThrow = true;
    final controller = WeatherController(
      weatherService: service,
      locationService: FakeLocationService(),
      storage: InMemoryLocationStorage(),
    );

    await controller.useCurrentLocation();

    expect(controller.status, WeatherViewStatus.error);
    expect(controller.errorMessage, contains('boom'));
  });
}
