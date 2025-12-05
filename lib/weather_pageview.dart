import 'package:flutter/material.dart';
import 'package:weather_appv4/database_helper.dart';
import 'package:weather_appv4/settings.dart';
import 'package:weather_appv4/weather_screen.dart';
import 'package:weather_appv4/location_helper.dart'; // 👈 add this import

class WeatherPageView extends StatefulWidget {
  const WeatherPageView({super.key});

  @override
  State<WeatherPageView> createState() => _WeatherPageViewState();
}

class _WeatherPageViewState extends State<WeatherPageView> {
  final DBHelper db = DBHelper.getInstance;

  late Future<List<Map<String, dynamic>>> _locationsFuture;
  final PageController _controller = PageController();
  //###########################################################
  Future<List<Map<String, dynamic>>> _loadLocations({
    bool seedIfEmpty = false,
  }) async {
    var locations = await db.getAllLocations();

    // If there are already locations, just return them (including any manually added)
    if (locations.isNotEmpty || !seedIfEmpty) {
      return locations;
    }

    // Only reach here if:
    // - locations is empty AND
    // - seedIfEmpty == true
    //
    // So this is the "first-time" or "totally-empty" seed.

    String? cityFromGps = await LocationHelper.getCityFromDevice();
    final firstCity = cityFromGps ?? 'London';

    await db.addLocation(mTitle: firstCity);
    locations = await db.getAllLocations();

    return locations;
  }

  //###########################################################
  @override
  void initState() {
    super.initState();
    _locationsFuture = _loadLocations(
      seedIfEmpty: true,
    ); // first-time boot logic
  }

  // Future<List<Map<String, dynamic>>> _getOrCreateLocations() async {
  //   // 1. Try existing locations
  //   var locations = await db.getAllLocations();
  //   if (locations.isNotEmpty) return locations;

  //   // 2. DB empty -> try device location
  //   String? cityFromGps = await LocationHelper.getCityFromDevice();

  //   // 3. Fallback if GPS fails or user denies permission
  //   final firstCity = cityFromGps ?? 'London';

  //   // 4. Insert into DB
  //   await db.addLocation(mTitle: firstCity);

  //   // 5. Return updated list
  //   locations = await db.getAllLocations();
  //   return locations;
  // }
  Future<void> _openSettingsAndReload() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MySettings()),
    );

    // After returning from Settings, re-read DB
    setState(() {
      _locationsFuture = _loadLocations(seedIfEmpty: false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _locationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text(snapshot.error.toString())));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Should rarely happen now, but keep a safety net
          return const Scaffold(
            body: Center(child: Text('No locations found')),
          );
        }

        final locations = snapshot.data!;
        return PageView.builder(
          controller: _controller,
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final city = locations[index][DBHelper.columnTitle] as String;
            return WeatherScreen(
              cityName: city,
              onOpenSettings: _openSettingsAndReload, // 👈 important
            );
          },
        );
      },
    );
  }
}
