import 'package:geolocator/geolocator.dart';

import 'location_models.dart';

abstract class DeviceLocationService {
  Future<Coordinates> getCurrentCoordinates();
}

class GeolocatorDeviceLocationService implements DeviceLocationService {
  @override
  Future<Coordinates> getCurrentCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException('Location permission denied forever.');
    }

    final position = await Geolocator.getCurrentPosition();
    return Coordinates(lat: position.latitude, lon: position.longitude);
  }
}

class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => message;
}
