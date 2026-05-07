import 'package:flutter/material.dart';

import 'weather_controller.dart';

class WeatherScreen extends StatefulWidget {
  final WeatherControllerBase controller;

  const WeatherScreen({super.key, required this.controller});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    _cityController.dispose();
    super.dispose();
  }

  void _listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SearchBar(
                controller: _cityController,
                onSearch: () => widget.controller.searchCity(_cityController.text),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('useCurrentLocationButton'),
                  onPressed: widget.controller.useCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use current location'),
                ),
              ),
              const SizedBox(height: 8),
              if (widget.controller.status == WeatherViewStatus.loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(key: Key('loadingIndicator')),
                  ),
                )
              else if (widget.controller.status == WeatherViewStatus.error)
                Expanded(
                  child: Center(
                    child: Text(
                      widget.controller.errorMessage ?? 'Unknown error',
                      key: const Key('errorMessage'),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                )
              else if (widget.controller.cityResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    key: const Key('cityResultsList'),
                    itemCount: widget.controller.cityResults.length,
                    itemBuilder: (context, index) {
                      final city = widget.controller.cityResults[index];
                      return ListTile(
                        title: Text(city.label),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => widget.controller.chooseLocation(city),
                      );
                    },
                  ),
                )
              else
                Expanded(child: _WeatherContent(controller: widget.controller)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('cityInput'),
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: 'Search city',
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          key: const Key('searchCityIconButton'),
          onPressed: onSearch,
          icon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherControllerBase controller;

  const _WeatherContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final weather = controller.weather;
    if (weather == null) {
      return const Center(child: Text('Select a city or use current location.'));
    }

    final current = weather.current;
    final nextThreeDays = controller.forecast.take(3).toList(growable: false);

    return Column(
      key: const Key('weatherContentList'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          controller.locationLabel,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature.round()} C  ${_titleCase(current.description)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text('Humidity: ${current.humidity}%'),
                  Text('Sunrise: ${_formatTime(current.sunrise)}'),
                  Text('Sunset: ${_formatTime(current.sunset)}'),
                ],
              ),
            ),
            _WeatherIcon(iconCode: current.iconCode, size: 88),
          ],
        ),
        const Spacer(),
        Row(
          key: const Key('next3DaysRow'),
          children: nextThreeDays
              .map(
                (day) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_weekday(day.date)),
                          const SizedBox(height: 4),
                          _WeatherIcon(iconCode: day.iconCode, size: 42),
                          const SizedBox(height: 4),
                          Text(
                            '${day.maxTemp.round()} / ${day.minTemp.round()} C',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  static String _weekday(DateTime date) {
    const names = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }
}

class _WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const _WeatherIcon({required this.iconCode, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://openweathermap.org/img/wn/$iconCode@2x.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.cloud, size: size * 0.75),
    );
  }
}
