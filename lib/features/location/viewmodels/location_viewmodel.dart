import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/features/location/services/location_service.dart';
import 'package:dokomandu/shared/models/address_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationState {
  const LocationState({
    this.currentPosition,
    this.selectedPoint,
    this.savedAddresses = const [],
    this.withinServiceRadius = true,
    this.message,
  });

  final Position? currentPosition;
  final LatLng? selectedPoint;
  final List<AddressModel> savedAddresses;
  final bool withinServiceRadius;
  final String? message;

  LocationState copyWith({
    Position? currentPosition,
    LatLng? selectedPoint,
    List<AddressModel>? savedAddresses,
    bool? withinServiceRadius,
    String? message,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      selectedPoint: selectedPoint ?? this.selectedPoint,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      withinServiceRadius: withinServiceRadius ?? this.withinServiceRadius,
      message: message,
    );
  }
}

class LocationViewModel extends AsyncNotifier<LocationState> {
  LocationService get _service => ref.read(locationServiceProvider);

  @override
  Future<LocationState> build() async {
    return _initialize();
  }

  Future<LocationState> _initialize() async {
    final permission = await _service.ensurePermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return const LocationState(
        message: 'Location permission is required to continue.',
      );
    }

    final position = await _service.getCurrentPosition();

    List<AddressModel> addresses;
    try {
      addresses = await _service.fetchSavedAddresses();
    } catch (_) {
      addresses = const [];
    }

    return LocationState(
      currentPosition: position,
      selectedPoint: LatLng(position.latitude, position.longitude),
      savedAddresses: addresses,
    );
  }

  void updateSelectedPoint(LatLng point) {
    final current = state.valueOrNull;
    if (current == null || current.currentPosition == null) return;

    final distance = _service.distanceInKm(
      startLat: current.currentPosition!.latitude,
      startLng: current.currentPosition!.longitude,
      endLat: point.latitude,
      endLng: point.longitude,
    );

    final isAllowed = distance <= AppConfig.serviceRadiusInKm;

    state = AsyncData(
      current.copyWith(
        selectedPoint: point,
        withinServiceRadius: isAllowed,
        message: isAllowed
            ? null
            : 'Selected location is outside our 3 km service zone.',
      ),
    );
  }

  void selectSavedAddress(AddressModel address) {
    updateSelectedPoint(LatLng(address.latitude, address.longitude));
  }

  Future<void> refreshLocation() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_initialize);
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(ref.watch(baseApiServiceProvider)),
);

final locationViewModelProvider =
    AsyncNotifierProvider<LocationViewModel, LocationState>(
      LocationViewModel.new,
    );
