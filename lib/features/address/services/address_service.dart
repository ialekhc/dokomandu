import 'package:dokomandu/features/location/services/location_service.dart';
import 'package:dokomandu/features/location/viewmodels/location_viewmodel.dart';
import 'package:dokomandu/shared/models/address_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressService {
  const AddressService(this._locationService);

  final LocationService _locationService;

  Future<List<AddressModel>> fetchAddresses() =>
      _locationService.fetchSavedAddresses();

  Future<AddressModel> addAddress(AddressModel address) =>
      _locationService.addAddress(address);

  Future<void> saveAddresses(List<AddressModel> addresses) =>
      _locationService.saveAddressesForDemo(addresses);
}

final addressServiceProvider = Provider<AddressService>(
  (ref) => AddressService(ref.watch(locationServiceProvider)),
);
