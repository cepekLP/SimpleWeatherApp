import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/location/data/device_location_service.dart';
import 'features/location/data/location_storage.dart';
import 'features/weather/data/open_weather_service.dart';
import 'features/weather/presentation/weather_controller.dart';
import 'features/weather/presentation/weather_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final controller = WeatherController(
    weatherService: OpenWeatherService(),
    locationService: GeolocatorDeviceLocationService(),
    storage: LocationStorage(),
  );
  runApp(SimpleWeatherApp(controller: controller));
}

class SimpleWeatherApp extends StatelessWidget {
  final WeatherControllerBase controller;

  const SimpleWeatherApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: WeatherScreen(controller: controller),
    );
  }
}
