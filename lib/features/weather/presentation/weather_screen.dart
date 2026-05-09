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
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.2)),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6996CD), Color(0xFF000761)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchBar(
                    controller: _cityController,
                    onSearch: () =>
                        widget.controller.searchCity(_cityController.text),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('useCurrentLocationButton'),
                      onPressed: widget.controller.useCurrentLocation,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.18),
                        side: const BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.my_location),
                      label: const Text(
                        'Use current location',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.controller.status == WeatherViewStatus.loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          key: Key('loadingIndicator'),
                        ),
                      ),
                    )
                  else if (widget.controller.status == WeatherViewStatus.error)
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.controller.errorMessage ?? 'Unknown error',
                          key: const Key('errorMessage'),
                          style: const TextStyle(color: Colors.white),
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
                            title: Text(
                              city.label,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                            onTap: () => widget.controller.chooseLocation(city),
                          );
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: _WeatherContent(controller: widget.controller),
                    ),
                ],
              ),
            ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
      return const Center(
        child: Text(
          'Select a city or use current location.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final current = weather.current;
    final nextThreeDays = controller.forecast.take(3).toList(growable: false);

    return SingleChildScrollView(
      child: Column(
        key: const Key('weatherContentList'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            controller.locationLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize:
                  (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24) +
                  6,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${current.temperature.round()} C  ${_titleCase(current.description)}',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Humidity: ${current.humidity}%',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Sunrise: ${_formatTime(current.sunrise)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Sunset: ${_formatTime(current.sunset)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              _WeatherIcon(iconCode: current.iconCode, size: 176),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            key: const Key('next3DaysRow'),
            children: nextThreeDays
                .map(
                  (day) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _weekday(day.date),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.maxTemp.round()} C',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.minTemp.round()} C',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            _WeatherIcon(iconCode: day.iconCode, size: 84),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
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
  static const double _layoutHeightFactor = 0.7;

  const _WeatherIcon({required this.iconCode, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * _layoutHeightFactor,
      child: ClipRect(
        child: OverflowBox(
          minWidth: size,
          maxWidth: size,
          minHeight: size,
          maxHeight: size,
          alignment: Alignment.center,
          child: Image.network(
            'https://openweathermap.org/img/wn/$iconCode@4x.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.cloud, size: size * 0.75),
          ),
        ),
      ),
    );
  }
}
