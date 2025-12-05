import 'package:flutter/material.dart';
import 'package:weather_appv4/weather_pageview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData.light(),
      home: const WeatherPageView(), // 👈 start here
    );
  }
}
