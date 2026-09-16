import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/models/weather_model.dart' show Weather;
import 'package:weather/service/weather_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //api key
  final _weatherService = WeatherService("28461507b080dff309b73015ad08ee80");
  Weather? _weather;
  String? _errorMessage;

  //fetch weather
  Future<void> _fetchWeather() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final weather = await _weatherService.getWeatherByCoords(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _weather = weather;
        _errorMessage = null;
      });
    } catch (e) {
      print(e);

      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  //weather animations
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sun.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/wind.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'clear':
        return 'assets/sun.json';
      default:
        return 'assets/sun.json';
    }
  }

  //initial state
  @override
  void initState() {
    super.initState();

    //fetch weather startup
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // display error message if any
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            //city name
            Text(_weather?.cityName ?? "Loading city..."),

            //animation
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),

            //temp
            Text('${_weather?.temperature.round()}˚C'),

            //condition
            Text(_weather?.mainCondition ?? ""),
          ],
        ),
      ),
    );
  }
}
