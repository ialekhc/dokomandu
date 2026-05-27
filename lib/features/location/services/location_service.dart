import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/app/constants/api_endpoints.dart';
import 'package:dokomandu/core/api/base_api_service.dart';
import 'package:dokomandu/core/utils/dummy_data.dart';
import 'package:dokomandu/shared/models/address_model.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService(this._apiService);

  final BaseApiService _apiService;

  Future<LocationPermission> ensurePermission() async {
    if (AppConfig.useStaticContent) {
      return LocationPermission.always;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  Future<Position> getCurrentPosition() {
    if (AppConfig.useStaticContent) {
      return Future<Position>.value(
        Position(
          longitude: 85.3240,
          latitude: 27.7172,
          timestamp: DateTime.now(),
          accuracy: 5,
          altitude: 1300,
          altitudeAccuracy: 3,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<List<AddressModel>> fetchSavedAddresses() {
    if (AppConfig.useStaticContent) {
      return _fetchSavedAddressesStatic();
    }

    return _apiService.get<List<AddressModel>>(
      ApiEndpoints.addresses,
      parser: (data) {
        final list = data as List<dynamic>? ?? const [];
        return list
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<AddressModel> addAddress(AddressModel address) {
    if (AppConfig.useStaticContent) {
      return Future<AddressModel>.value(
        AddressModel(
          id: address.id.isEmpty
              ? 'addr_temp_${DateTime.now().millisecondsSinceEpoch}'
              : address.id,
          label: address.label,
          fullAddress: address.fullAddress,
          latitude: address.latitude,
          longitude: address.longitude,
          landmark: address.landmark,
          isDefault: address.isDefault,
        ),
      );
    }

    return _apiService.post<AddressModel>(
      ApiEndpoints.addresses,
      data: address.toJson(),
      parser: (data) => AddressModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<AddressModel>> _fetchSavedAddressesStatic() async {
    await DummyData.delay();
    return DummyData.addresses();
  }

  double distanceInKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return distanceInMeters / 1000;
  }
}
