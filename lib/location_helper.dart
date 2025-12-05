import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  /// Returns city name from device location,
  /// or null if permission denied / error.
  static Future<String?> getCityFromDevice() async {
    try {
      // 1. Check if location is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // User has GPS off
        return null;
      }

      // 2. Check & request permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // User said no
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // User permanently denied
        return null;
      }

      // 3. Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 4. Reverse geocode -> placemark
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      // Try locality (city), fall back to subAdministrativeArea, then admin area
      final city = place.locality?.trim();
      if (city != null && city.isNotEmpty) return city;

      final altCity = place.subAdministrativeArea?.trim();
      if (altCity != null && altCity.isNotEmpty) return altCity;

      final region = place.administrativeArea?.trim();
      if (region != null && region.isNotEmpty) return region;

      return null;
    } catch (e) {
      // In case of any error, just return null; caller will use fallback.
      return null;
    }
  }
}
