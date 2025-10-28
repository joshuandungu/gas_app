import 'package:geolocator/geolocator.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/user.dart';

class LocationFilterService {
  /// Filters vendors based on buyer's current location within [radiusInMeters].
  Future<List<User>> filterVendorsByLocation({
    required Position buyerPosition,
    required List<User> vendors,
    double radiusInMeters = 10000, // default 10km radius
  }) async {
    List<User> nearbyVendors = [];

    for (var vendor in vendors) {
      // Assuming vendor has latitude and longitude fields (you need to add these to User model)
      double distance = Geolocator.distanceBetween(
        buyerPosition.latitude,
        buyerPosition.longitude,
        vendor.latitude,
        vendor.longitude,
      );

      if (distance <= radiusInMeters) {
        nearbyVendors.add(vendor);
      }
    }

    return nearbyVendors;
  }
}
