import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temperature = 0.0;
  double windSpeed = 0;
  int pressure = 0;
  int humidity = 0;
  String description = '';
  List<Map<String, dynamic>> forecast = [];

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future getCurrentWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherapikey',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'unexpected error';
      }
      setState(() {
        temperature = (data['list'][0]['main']['temp']);
        windSpeed = data['list'][0]['wind']['speed'];
        pressure = data['list'][0]['main']['pressure'];
        humidity = data['list'][0]['main']['humidity'];
        description = data['list'][0]['weather'][0]['main'];
        forecast = List.generate(5, (index) {
          final item = data['list'][index];
          return {
            'time': item['dt_txt'].toString().substring(11, 16),
            'temp': item['main']['temp'],
            'weather': item['weather'][0]['main'],
          };
        });
      });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather app',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: getCurrentWeather, icon: Icon(Icons.refresh)),
        ],
      ),
      body: temperature == 0
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 20,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${(temperature - 273.15).toStringAsFixed(1)}°C',

                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.cloud, size: 64),
                                Text(
                                  description,
                                  style: TextStyle(fontSize: 32),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ), //main card
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Weather Forecast',
                      style: TextStyle(fontSize: 32.0),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: forecast.map((item) {
                        IconData icon;
                        String weather = item['weather'].toLowerCase();
                        if (weather.contains('cloud')) {
                          icon = Icons.cloud;
                        } else if (weather.contains('rain')) {
                          icon = Icons.water_drop;
                        } else {
                          icon = Icons.sunny;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            width: 100,
                            child: Card(
                              elevation: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      item['time'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(icon, size: 32),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(item['temp'] - 273.15).toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Additional Information',
                      style: TextStyle(fontSize: 32.0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.water_drop, size: 32),
                          const SizedBox(height: 8),
                          Text('Humidity'),
                          const SizedBox(height: 8),
                          Text(
                            '$humidity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.wind_power, size: 32),
                          const SizedBox(height: 8),
                          Text('Wind Speed'),
                          const SizedBox(height: 8),
                          Text(
                            '$windSpeed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.beach_access, size: 32),
                          const SizedBox(height: 8),
                          Text('Pressure'),
                          const SizedBox(height: 8),
                          Text(
                            '$pressure',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
