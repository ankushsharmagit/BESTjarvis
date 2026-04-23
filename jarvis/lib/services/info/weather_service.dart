// lib/services/info/weather_service.dart
// Weather Information Service with OpenWeatherMap API

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../config/constants.dart';
import '../../utils/logger.dart';
import '../../utils/error_handler.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();
  
  final String _apiKey = AppConstants.weatherApiKey;
  WeatherData? _cachedWeather;
  DateTime? _lastFetch;
  final Duration _cacheDuration = const Duration(minutes: 30);
  
  Future<WeatherData> getCurrentWeather({double? lat, double? lon}) async {
    try {
      // Check cache
      if (_cachedWeather != null && _lastFetch != null) {
        if (DateTime.now().difference(_lastFetch!) < _cacheDuration) {
          Logger().info('Returning cached weather data', tag: 'WEATHER');
          return _cachedWeather!;
        }
      }
      
      // Get location if not provided
      Position? position;
      if (lat == null || lon == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        lat = position.latitude;
        lon = position.longitude;
      }
      
      final url = Uri.parse('${ApiEndpoints.weatherCurrent}?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedWeather = WeatherData.fromJson(data);
        _lastFetch = DateTime.now();
        Logger().info('Weather fetched for lat: $lat, lon: $lon', tag: 'WEATHER');
        return _cachedWeather!;
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
      
    } catch (e, stackTrace) {
      ErrorHandler().handleError(e, stackTrace, context: 'Weather Service');
      throw Exception('Weather service error: $e');
    }
  }
  
  Future<List<WeatherForecast>> getForecast({double? lat, double? lon, int days = 5}) async {
    try {
      // Get location if not provided
      if (lat == null || lon == null) {
        final position = await Geolocator.getCurrentPosition();
        lat = position.latitude;
        lon = position.longitude;
      }
      
      final url = Uri.parse('${ApiEndpoints.weatherForecast}?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final forecasts = <WeatherForecast>[];
        
        for (var item in data['list']) {
          forecasts.add(WeatherForecast.fromJson(item));
        }
        
        // Return unique days
        final uniqueForecasts = <WeatherForecast>[];
        final seenDates = <String>{};
        
        for (var forecast in forecasts) {
          final dateKey = forecast.date.toIso8601String().split('T')[0];
          if (!seenDates.contains(dateKey)) {
            seenDates.add(dateKey);
            uniqueForecasts.add(forecast);
            if (uniqueForecasts.length >= days) break;
          }
        }
        
        Logger().info('Forecast fetched for ${uniqueForecasts.length} days', tag: 'WEATHER');
        return uniqueForecasts;
      } else {
        throw Exception('Failed to load forecast');
      }
      
    } catch (e) {
      Logger().error('Forecast error', tag: 'WEATHER', error: e);
      return [];
    }
  }
  
  Future<String> getWeatherAlert() async {
    try {
      final weather = await getCurrentWeather();
      
      if (weather.temperature > 40) {
        return '⚠️ Extreme heat alert! Temperature is ${weather.temperature.toStringAsFixed(0)}°C. Stay hydrated!';
      } else if (weather.temperature < 5) {
        return '❄️ Cold weather alert! Temperature is ${weather.temperature.toStringAsFixed(0)}°C. Bundle up!';
      } else if (weather.rain > 0) {
        return '☔ Rain expected! Don\'t forget your umbrella.';
      } else if (weather.windSpeed > 30) {
        return '💨 Strong winds! Wind speed is ${weather.windSpeed.toStringAsFixed(0)} km/h.';
      }
      
      return '';
      
    } catch (e) {
      return '';
    }
  }
  
  Future<String> getWeatherDescription() async {
    try {
      final weather = await getCurrentWeather();
      final alert = await getWeatherAlert();
      
      String description = '🌤️ Current weather: ${weather.description}\n';
      description += '🌡️ Temperature: ${weather.temperature.toStringAsFixed(0)}°C (Feels like ${weather.feelsLike.toStringAsFixed(0)}°C)\n';
      description += '💧 Humidity: ${weather.humidity}%\n';
      description += '💨 Wind: ${weather.windSpeed.toStringAsFixed(0)} km/h\n';
      description += '🌅 Sunrise: ${_formatTime(weather.sunrise)}\n';
      description += '🌇 Sunset: ${_formatTime(weather.sunset)}';
      
      if (alert.isNotEmpty) {
        description += '\n\n$alert';
      }
      
      return description;
      
    } catch (e) {
      return 'Sir, weather information lene mein problem hai. Thodi der mein try karo. 🌤️';
    }
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  String getWeatherEmoji(String condition) {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) return '☀️';
    if (lowerCondition.contains('cloud')) return '☁️';
    if (lowerCondition.contains('rain')) return '🌧️';
    if (lowerCondition.contains('thunder')) return '⛈️';
    if (lowerCondition.contains('snow')) return '❄️';
    if (lowerCondition.contains('mist') || lowerCondition.contains('fog')) return '🌫️';
    return '🌤️';
  }
}

class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double pressure;
  final double windSpeed;
  final int windDirection;
  final double rain;
  final String description;
  final String icon;
  final DateTime sunrise;
  final DateTime sunset;
  final String cityName;
  final String country;
  
  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.rain,
    required this.description,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.cityName,
    required this.country,
  });
  
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      pressure: json['main']['pressure'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      windDirection: json['wind']['deg'] ?? 0,
      rain: json['rain']?['1h']?.toDouble() ?? 0,
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      cityName: json['name'],
      country: json['sys']['country'],
    );
  }
}

class WeatherForecast {
  final DateTime date;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String description;
  final String icon;
  final double rain;
  
  WeatherForecast({
    required this.date,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.rain,
  });
  
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['dt_txt']),
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      rain: json['rain']?['3h']?.toDouble() ?? 0,
    );
  }
  
  String getFormattedDate() {
    return '${date.day}/${date.month} ${date.hour}:00';
  }
  
  String getDayName() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }
}