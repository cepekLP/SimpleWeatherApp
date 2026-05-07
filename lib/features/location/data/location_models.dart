class Coordinates {
  final double lat;
  final double lon;

  const Coordinates({
    required this.lat,
    required this.lon,
  });
}

class LocationCandidate {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  const LocationCandidate({
    required this.name,
    required this.country,
    required this.state,
    required this.lat,
    required this.lon,
  });

  String get label {
    if (state != null && state!.isNotEmpty) {
      return '$name, $state, $country';
    }
    return '$name, $country';
  }
}
