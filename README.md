# simple_weather_app

## Getting Started

SimpleWeatherApp is a Flutter weather project that uses OpenWeather API, device location, and local storage.

## Application Architecture

The project follows a simple layered architecture with clear responsibilities.

### 1) Presentation layer (UI + state orchestration)

- `lib/features/weather/presentation/weather_screen.dart`
	- Renders UI states: loading, error, city search results, and weather content.
	- Sends user actions to controller (search city, use current location, choose result).
- `lib/features/weather/presentation/weather_controller.dart`
	- Acts as the state manager (`ChangeNotifier`).
	- Coordinates calls to services and storage.
	- Exposes view state (`status`, `errorMessage`, `weather`, `cityResults`, `locationLabel`).

### 2) Data layer (external integrations and mapping)

- `lib/features/weather/data/open_weather_service.dart`
	- Calls OpenWeather endpoints:
		- geocoding for city search
		- One Call API for weather by coordinates
- `lib/features/weather/data/weather_mapper.dart`
	- Converts raw API JSON payloads into typed domain models.
- `lib/features/location/data/device_location_service.dart`
	- Retrieves device coordinates and handles permission/service checks.
- `lib/features/location/data/location_storage.dart`
	- Persists and restores the last selected location via `shared_preferences`.

### 3) Domain layer (app data models)

- `lib/features/weather/domain/models/current_weather.dart`
- `lib/features/weather/domain/models/daily_forecast.dart`
- `lib/features/weather/domain/models/weather.dart`
- `lib/features/location/data/location_models.dart`

These classes represent weather and location data in a framework-agnostic way.


## Prerequisites

Install and verify:

1. Flutter SDK (project uses Dart SDK 3.11.x)
2. One device target:
   - Android emulator, or
   - physical Android/iOS device, or
   - Chrome for web
3. OpenWeather API key

Check your Flutter setup:

	flutter --version
	flutter doctor

## 1) Configure environment variables

Create a file named .env in the project root and add:

	OPENWEATHER_API_KEY=your_api_key_here

Important:

1. Do not add quotes around the key.
2. Keep .env in the root folder (same level as pubspec.yaml).

## 2) Install dependencies

From the project root run:

	flutter pub get

## 3) Start a device

If you use Android emulator:

	flutter emulators
	flutter emulators --launch <emulator_id>

Then confirm visible devices:

	flutter devices

## 4) Run the app

Default run (uses selected device):

	flutter run

Run on a specific device:

	flutter run -d <device_id>

Run in Chrome:

	flutter run -d chrome

## 5) Quality checks

Run static analysis:

	flutter analyze

Run tests:

	flutter test

## 6) Clean and rebuild (optional)

If you hit build/cache issues:

	flutter clean
	flutter pub get
	flutter run

## VS Code Tasks

This workspace already includes tasks for:

1. Flutter: pub get
2. Flutter: run
3. Flutter: analyze
4. Flutter: test
5. Flutter: clean build artifacts

Open Command Palette, choose Tasks: Run Task, then pick one of the Flutter tasks.
