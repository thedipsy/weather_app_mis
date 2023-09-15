import 'dart:convert';

import 'package:location/location.dart';
import 'package:weatherapp/const/const.dart';
import 'package:weatherapp/models/forecast_response.dart';
import 'package:weatherapp/models/weather_response.dart';
import 'package:http/http.dart' as http;

class OpenWeatherMapClient {
  Future<WeatherResponse> getWeather(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/weather?lat=${locationData.latitude}&long=${locationData.longitude}&units=metrics&appid=$apiKey'));
      if (res.statusCode == 200) {
        return WeatherResponse.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Bad Request.');
      }
    } else {
      throw Exception('Wrong Location.');
    }
  }

  Future<ForecastResponse> getForecast(LocationData locationData) async {
    if (locationData.latitude != null && locationData.longitude != null) {
      final res = await http.get(Uri.parse(
          '$apiEndpoint/forecast?lat=${locationData.latitude}&long=${locationData.longitude}&units=metrics&appid=$apiKey'));
      if (res.statusCode == 200) {
        return ForecastResponse.fromJson(jsonDecode(res.body));
      } else {
        throw Exception('Bad Request.');
      }
    } else {
      throw Exception('Wrong Location.');
    }
  }
}
