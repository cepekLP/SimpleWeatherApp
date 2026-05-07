import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../location/data/location_models.dart';
import '../domain/models/weather.dart';
import 'weather_mapper.dart';

abstract class WeatherService {
  Future<Weather> fetchWeather({
    required double lat,
    required double lon,
  });

  Future<List<LocationCandidate>> searchCity(String query);
}

class OpenWeatherService implements WeatherService {
  final http.Client _client;
  final String _apiKey;

  OpenWeatherService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? Env.openWeatherApiKey;

  @override
  Future<Weather> fetchWeather({required double lat, required double lon}) async {
    _requireApiKey();

    final uri = Uri.https('api.openweathermap.org', '/data/3.0/onecall', {
      'lat': '$lat',
      'lon': '$lon',
      'units': 'metric',
      'exclude': 'minutely,alerts',
      'appid': _apiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Failed to fetch weather. HTTP ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherMapper.fromOneCallJson(body);
  }

  @override
  Future<List<LocationCandidate>> searchCity(String query) async {
    _requireApiKey();

    if (query.trim().isEmpty) {
      return const <LocationCandidate>[];
    }

    final uri = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
      'q': query.trim(),
      'limit': '5',
      'appid': _apiKey,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherApiException(
        'Failed to search city. HTTP ${response.statusCode}',
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(
          (item) => LocationCandidate(
            name: item['name'] as String,
            country: item['country'] as String,
            state: item['state'] as String?,
            lat: (item['lat'] as num).toDouble(),
            lon: (item['lon'] as num).toDouble(),
          ),
        )
        .toList(growable: false);
  }

  void _requireApiKey() {
    if (_apiKey.trim().isEmpty) {
      throw const WeatherApiException(
        'Missing OPENWEATHER_API_KEY. Pass it via --dart-define.',
      );
    }
  }
}

class WeatherApiException implements Exception {
  final String message;

  const WeatherApiException(this.message);

  @override
  String toString() => message;
}
