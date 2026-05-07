import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:simple_weather_app/features/weather/data/open_weather_service.dart';

void main() {
  test('searchCity returns empty list when API returns no matches', () async {
    final client = MockClient((_) async => http.Response('[]', 200));
    final service = OpenWeatherService(client: client, apiKey: 'test-key');

    final result = await service.searchCity('UnknownCity');

    expect(result, isEmpty);
  });
}
