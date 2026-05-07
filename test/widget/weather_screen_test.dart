import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_weather_app/features/location/data/location_models.dart';
import 'package:simple_weather_app/features/weather/domain/models/current_weather.dart';
import 'package:simple_weather_app/features/weather/domain/models/daily_forecast.dart';
import 'package:simple_weather_app/features/weather/domain/models/weather.dart';
import 'package:simple_weather_app/features/weather/presentation/weather_controller.dart';
import 'package:simple_weather_app/features/weather/presentation/weather_screen.dart';

class TestWeatherController extends ChangeNotifier implements WeatherControllerBase {
  @override
  List<LocationCandidate> cityResults = const <LocationCandidate>[];

  @override
  String? errorMessage;

  @override
  List<DailyForecast> forecast = const <DailyForecast>[];

  @override
  String locationLabel = 'No location selected';

  @override
  WeatherViewStatus status = WeatherViewStatus.idle;

  @override
  Weather? weather;

  bool searchCalled = false;
  String lastSearchQuery = '';

  @override
  Future<void> chooseLocation(LocationCandidate candidate) async {
    locationLabel = candidate.label;
    notifyListeners();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> searchCity(String query) async {
    searchCalled = true;
    lastSearchQuery = query;
    cityResults = [
      const LocationCandidate(
        name: 'London',
        country: 'GB',
        state: null,
        lat: 51.5074,
        lon: -0.1278,
      ),
    ];
    notifyListeners();
  }

  @override
  Future<void> useCurrentLocation() async {}
}

Widget wrap(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('shows loading indicator for loading state', (tester) async {
    final controller = TestWeatherController()..status = WeatherViewStatus.loading;

    await tester.pumpWidget(wrap(WeatherScreen(controller: controller)));

    expect(find.byKey(const Key('loadingIndicator')), findsOneWidget);
  });

  testWidgets('shows current weather and forecast in success state', (tester) async {
    final controller = TestWeatherController()
      ..status = WeatherViewStatus.success
      ..weather = Weather(
        current: CurrentWeather(
          temperature: 20,
          feelsLike: 19,
          humidity: 60,
          windSpeed: 3,
          description: 'clear sky',
          sunrise: DateTime.fromMillisecondsSinceEpoch(1714722000000),
          sunset: DateTime.fromMillisecondsSinceEpoch(1714771200000),
          iconCode: '01d',
        ),
        forecast: [
          DailyForecast(
            date: DateTime.fromMillisecondsSinceEpoch(1714809600000),
            dayTemp: 22,
            minTemp: 16,
            maxTemp: 24,
            description: 'sunny',
            iconCode: '01d',
          ),
        ],
      )
      ..forecast = [
        DailyForecast(
          date: DateTime.fromMillisecondsSinceEpoch(1714809600000),
          dayTemp: 22,
          minTemp: 16,
          maxTemp: 24,
          description: 'sunny',
          iconCode: '01d',
        ),
      ];

    await tester.pumpWidget(wrap(WeatherScreen(controller: controller)));

    expect(find.textContaining('Humidity:'), findsOneWidget);
    expect(find.textContaining('Sunrise:'), findsOneWidget);
    expect(find.byKey(const Key('next3DaysRow')), findsOneWidget);
  });

  testWidgets('city search triggers query and renders results', (tester) async {
    final controller = TestWeatherController();

    await tester.pumpWidget(wrap(WeatherScreen(controller: controller)));

    await tester.enterText(find.byKey(const Key('cityInput')), 'London');
    await tester.tap(find.byKey(const Key('searchCityIconButton')));
    await tester.pump();

    expect(controller.searchCalled, isTrue);
    expect(controller.lastSearchQuery, 'London');
    expect(find.byKey(const Key('cityResultsList')), findsOneWidget);
    expect(find.text('London, GB'), findsOneWidget);
  });
}
