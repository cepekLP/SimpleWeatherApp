import 'package:shared_preferences/shared_preferences.dart';

import 'location_models.dart';

class SavedLocation {
  final String label;
  final Coordinates coordinates;

  const SavedLocation({
    required this.label,
    required this.coordinates,
  });
}

class LocationStorage {
  static const _labelKey = 'saved_label';
  static const _latKey = 'saved_lat';
  static const _lonKey = 'saved_lon';

  Future<void> save({required String label, required Coordinates coordinates}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_labelKey, label);
    await prefs.setDouble(_latKey, coordinates.lat);
    await prefs.setDouble(_lonKey, coordinates.lon);
  }

  Future<SavedLocation?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final label = prefs.getString(_labelKey);
    final lat = prefs.getDouble(_latKey);
    final lon = prefs.getDouble(_lonKey);

    if (label == null || lat == null || lon == null) {
      return null;
    }

    return SavedLocation(
      label: label,
      coordinates: Coordinates(lat: lat, lon: lon),
    );
  }
}
