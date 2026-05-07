class DailyForecast {
  final DateTime date;
  final double dayTemp;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String iconCode;

  const DailyForecast({
    required this.date,
    required this.dayTemp,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.iconCode,
  });
}
