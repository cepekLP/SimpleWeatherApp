import 'package:flutter/foundation.dart';

import '../../location/data/device_location_service.dart';
import '../../location/data/location_models.dart';
import '../../location/data/location_storage.dart';
import '../data/open_weather_service.dart';
import '../domain/models/daily_forecast.dart';
import '../domain/models/weather.dart';

enum WeatherViewStatus { idle, loading, success, error }

abstract class WeatherControllerBase extends ChangeNotifier {
  WeatherViewStatus get status;
  String? get errorMessage;
  String get locationLabel;
  Weather? get weather;
  List<LocationCandidate> get cityResults;

  List<DailyForecast> get forecast;

  Future<void> initialize();

  Future<void> searchCity(String query);

  Future<void> chooseLocation(LocationCandidate candidate);

  Future<void> useCurrentLocation();
}

class WeatherController extends ChangeNotifier implements WeatherControllerBase {
  final WeatherService _weatherService;
  final DeviceLocationService _locationService;
  final LocationStorage _storage;

  WeatherViewStatus _status = WeatherViewStatus.idle;
  String? _errorMessage;
  String _locationLabel = 'No location selected';
  Weather? _weather;
  List<LocationCandidate> _cityResults = const <LocationCandidate>[];

  WeatherController({
    required WeatherService weatherService,
    required DeviceLocationService locationService,
    required LocationStorage storage,
  }) : _weatherService = weatherService,
       _locationService = locationService,
       _storage = storage;

  @override
  WeatherViewStatus get status => _status;

  @override
  String? get errorMessage => _errorMessage;

  @override
  String get locationLabel => _locationLabel;

  @override
  Weather? get weather => _weather;

  @override
  List<LocationCandidate> get cityResults => _cityResults;

  @override
  List<DailyForecast> get forecast => _weather?.forecast ?? const <DailyForecast>[];

  @override
  Future<void> initialize() async {
    final saved = await _storage.load();
    if (saved == null) {
      return;
    }

    _locationLabel = saved.label;
    await _fetchWeather(saved.coordinates);
  }

  @override
  Future<void> searchCity(String query) async {
    _setLoading();
    try {
      _cityResults = await _weatherService.searchCity(query);
      _status = WeatherViewStatus.idle;
      if (_cityResults.isEmpty) {
        _errorMessage = 'No matching city found.';
        _status = WeatherViewStatus.error;
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  @override
  Future<void> chooseLocation(LocationCandidate candidate) async {
    _locationLabel = candidate.label;
    _cityResults = const <LocationCandidate>[];
    await _fetchWeather(Coordinates(lat: candidate.lat, lon: candidate.lon));
  }

  @override
  Future<void> useCurrentLocation() async {
    _setLoading();
    try {
      final coords = await _locationService.getCurrentCoordinates();
      _locationLabel = 'Current location (${coords.lat.toStringAsFixed(2)}, ${coords.lon.toStringAsFixed(2)})';
      await _fetchWeather(coords, shouldNotifyLoading: false);
    } on LocationException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _fetchWeather(
    Coordinates coordinates, {
    bool shouldNotifyLoading = true,
  }) async {
    if (shouldNotifyLoading) {
      _setLoading();
    }

    try {
      _weather = await _weatherService.fetchWeather(
        lat: coordinates.lat,
        lon: coordinates.lon,
      );
      _status = WeatherViewStatus.success;
      _errorMessage = null;
      notifyListeners();
      await _storage.save(label: _locationLabel, coordinates: coordinates);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading() {
    _status = WeatherViewStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = WeatherViewStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}
