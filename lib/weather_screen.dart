import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weather_appv4/additional_widget.dart';
import 'package:weather_appv4/hourly_forcast.dart';
import 'package:http/http.dart' as http;
import 'package:weather_appv4/secrets.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';
import 'package:weather_appv4/settings.dart';

class WeatherScreen extends StatefulWidget {
  final String cityName;
  final Future<void> Function()? onOpenSettings;

  const WeatherScreen({
    super.key,
    required this.cityName,
    this.onOpenSettings,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentForecast() async {
    final cityName = widget.cityName;
    try {
      final resultForecast = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey',
        ),
      );
      final dataForecast = jsonDecode(resultForecast.body);
      if (dataForecast['cod'] != '200') {
        throw 'Some Error Occured getting forecast!';
      }
      return dataForecast;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    final cityName = widget.cityName;
    try {
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&APPID=$openWeatherApiKey',
        ),
      );
      final data = jsonDecode(result.body);
      if (data['cod'] != 200) {
        throw 'Some Error Occured getting current weather!';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Widget _fullScreenImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _currentWeathrer(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.yellow,
        fontSize: 40,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  String _convertVisibility(int visibilityInMeters) {
    if (visibilityInMeters >= 10000) {
      return "Excellent";
    } else if (visibilityInMeters >= 4000) {
      return "Good";
    } else if (visibilityInMeters >= 1000) {
      return "Moderate";
    } else if (visibilityInMeters >= 500) {
      return "Poor";
    } else {
      return "Very Poor";
    }
  }

  /// Converts OpenWeatherMap sunrise/sunset into formatted local city time.
  /// [unixTime] = sunrise or sunset unix timestamp (seconds)
  /// [timezoneOffset] = offset in seconds (from API)
  ///
  /// Example return: "06:48 AM"
  String formatSunTime(int unixTime, int timezoneOffset) {
    // Convert to UTC datetime
    final utcTime = DateTime.fromMillisecondsSinceEpoch(
      unixTime * 1000,
      isUtc: true,
    );

    // Apply city timezone offset
    final localTime = utcTime.add(Duration(seconds: timezoneOffset));

    // Format nicely
    return DateFormat('hh:mm a').format(localTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.cityName, // 👈 use passed city
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),

          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const MySettings()),
          //     );
          //   },
          //   icon: const Icon(Icons.pin_drop, color: Colors.white),
          // ),
          IconButton(
            onPressed: () async {
              // 👇 use callback if provided, otherwise fall back to old behavior
              if (widget.onOpenSettings != null) {
                await widget.onOpenSettings!();
              } else {
                // fallback, in case you ever reuse WeatherScreen alone
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MySettings()),
                );
              }
            },
            icon: const Icon(Icons.pin_drop, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([getCurrentForecast(), getCurrentWeather()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No Data Found!'));
          }

          final results = snapshot.data! as List<dynamic>;
          final data = results[0]; // forecast
          final weatherData = results[1]; // current weather

          // WEATHER DATA EXTRACTION STARTS
          final currentTemp = (weatherData['main']['temp'] - 273.15)
              .round()
              .toString();
          final currentSky = weatherData['weather'][0]['main'];
          final dayNight = weatherData['weather'][0]['icon'];
          final maxTemp = (weatherData['main']['temp_max'] - 273.15)
              .toStringAsFixed(2);
          final minTemp = (weatherData['main']['temp_min'] - 273.15)
              .toStringAsFixed(2);
          final humidity = weatherData['main']['humidity'].toString();
          final feelsLike = (weatherData['main']['feels_like'] - 273.15)
              .toStringAsFixed(2);
          final pressure = weatherData['main']['pressure'];
          final visibility = weatherData['visibility']; //visibilityInMeters

          int sunrise = weatherData['sys']['sunrise'];
          int sunset = weatherData['sys']['sunset'];
          int offset = weatherData['timezone'];
          String sunriseFormatted = formatSunTime(sunrise, offset);
          String sunsetFormatted = formatSunTime(sunset, offset);

          // FORECAST DATA EXTRACTION STARTS
          const String degreeSymbol = '°';
          final currentWeatherData = data['list'][0];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindspeed = currentWeatherData['wind']['speed'];
          final countItems = data['cnt'];
          // FORECAST DATA EXTRACTION ENDS

          return Stack(
            children: [
              Image.asset(
                dayNight.contains("n")
                    ? "assets/images/clear_night.jpg"
                    : "assets/images/clear_day.jpg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              if (currentSky == "Rain")
                _fullScreenImage("assets/images/rain_day_night.gif"),
              if (currentSky == "Clouds" && dayNight.contains("d"))
                _fullScreenImage("assets/images/couldy_day.jpg"),
              if (currentSky == "Clouds" && dayNight.contains("n"))
                _fullScreenImage("assets/images/cloudy_night.jpg"),
              if (currentSky == "Snow")
                _fullScreenImage("assets/images/snow_day_night.jpg"),
              if (currentSky == "Drizzle")
                _fullScreenImage("assets/images/drizzle_day_night.jpg"),

              SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MAIN CARD
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp°',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 72,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              dayNight.contains("n")
                                  ? const Text(
                                      'Night',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23,
                                      ),
                                    )
                                  : const Text(
                                      'Day',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23,
                                      ),
                                    ),
                              const SizedBox(height: 20),

                              if (currentSky == 'Snow')
                                _currentWeathrer('Snow')
                              else if (currentSky == 'Drizzle')
                                _currentWeathrer('Drizzle')
                              else if (currentSky == 'Rain')
                                _currentWeathrer('Rain')
                              else if (currentSky == 'Clouds')
                                _currentWeathrer('Clouds')
                              else if (currentSky == 'Clear')
                                _currentWeathrer('Clear')
                              else if (currentSky == 'Haze')
                                _currentWeathrer('Haze'),

                              const SizedBox(height: 20),
                              Text(
                                'Feels Like : $feelsLike$degreeSymbol',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 20),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      '$currentSky | ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Max  : $maxTemp° | ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Min  : $minTemp° | ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Humidity : $humidity |',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Feels Like  : $feelsLike° | ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Pressure  : $pressure',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // HOURLY FORECAST
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: countItems - 1,
                          itemBuilder: (context, index) {
                            final hourlyForecast = data['list'][index + 1];
                            final hourlySky =
                                hourlyForecast['weather'][0]['main'];
                            final time = DateTime.parse(
                              hourlyForecast['dt_txt'],
                            );
                            final tempreture =
                                (hourlyForecast['main']['temp'] - 273.15)
                                    .toStringAsFixed(2) +
                                degreeSymbol;
                            final icon =
                                hourlySky == 'Clouds' || hourlySky == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny;

                            return HourlyForcastWidget(
                              time: DateFormat.j().format(time).toString(),
                              tempreture: tempreture,
                              icon: icon,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ADDITIONAL INFO
                      Container(
                        //decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          // color: const Color.fromARGB(253, 1, 141, 255),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 34, 150, 244),
                              Color.fromARGB(255, 22, 82, 234),
                            ],
                          ),
                        ),

                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(10.0),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AdditionalWidget(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: currentHumidity.toString(),
                            ),
                            AdditionalWidget(
                              icon: Icons.air,
                              label: 'Wind Speed',
                              value: currentWindspeed.toString(),
                            ),
                            AdditionalWidget(
                              icon: WeatherIcons.barometer,
                              label: 'Pressure',
                              value: currentPressure.toString(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // HOURLY FORECAST
                      Container(
                        alignment: Alignment.center,

                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 130,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //SUNRISE----
                              Card(
                                color: const Color.fromARGB(255, 65, 155, 228),
                                // Sets the background color to blue
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color.fromARGB(255, 198, 253, 0),
                                        const Color.fromARGB(255, 243, 38, 2),
                                      ], // Define your gradient colors
                                      begin: Alignment
                                          .topLeft, // Start point of the gradient
                                      end: Alignment
                                          .bottomRight, // End point of the gradient
                                    ),
                                  ),

                                  width: 110,
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Sunrise',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 7),
                                      Icon(
                                        Icons.sunny,
                                        size: 32,
                                        color: Colors.yellow,
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        sunriseFormatted,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              //SUNSET----
                              Card(
                                color: const Color.fromARGB(
                                  255,
                                  65,
                                  155,
                                  228,
                                ), // Sets the background color to blue
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color.fromARGB(255, 198, 253, 0),
                                        const Color.fromARGB(255, 243, 38, 2),
                                      ], // Define your gradient colors
                                      begin: Alignment
                                          .topLeft, // Start point of the gradient
                                      end: Alignment
                                          .bottomRight, // End point of the gradient
                                    ),
                                  ),

                                  width: 110,
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Sunset',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 7),
                                      Icon(
                                        Icons.mode_night,
                                        size: 32,
                                        color: Colors.yellow,
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        sunsetFormatted,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              //VISIBILITY ----
                              Card(
                                color: const Color.fromARGB(
                                  255,
                                  65,
                                  155,
                                  228,
                                ), // Sets the background color to blue
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color.fromARGB(255, 198, 253, 0),
                                        const Color.fromARGB(255, 243, 38, 2),
                                      ], // Define your gradient colors
                                      begin: Alignment
                                          .topLeft, // Start point of the gradient
                                      end: Alignment
                                          .bottomRight, // End point of the gradient
                                    ),
                                  ),

                                  width: 110,
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Visibility',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 7),
                                      Icon(
                                        Icons.visibility,
                                        size: 32,
                                        color: Colors.yellow,
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        _convertVisibility(visibility),
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
