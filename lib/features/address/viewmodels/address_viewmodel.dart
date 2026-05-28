import 'package:dokomandu/features/address/models/address_form_model.dart';
import 'package:dokomandu/features/address/services/address_service.dart';
import 'package:dokomandu/features/location/viewmodels/location_viewmodel.dart';
import 'package:dokomandu/shared/models/address_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressViewModel extends AsyncNotifier<List<AddressModel>> {
  AddressService get _service => ref.read(addressServiceProvider);

  @override
  Future<List<AddressModel>> build() {
    return _service.fetchAddresses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> addAddress(AddressFormModel form) async {
    final current = state.valueOrNull ?? <AddressModel>[];

    final latitude = 27.7172 + (current.length * 0.0015);
    final longitude = 85.3240 + (current.length * 0.0012);

    final created = await _service.addAddress(
      AddressModel(
        id: '',
        label: form.label,
        fullAddress: form.fullAddress,
        latitude: latitude,
        longitude: longitude,
        landmark: form.landmark,
      ),
    );

    state = AsyncData([...current, created]);
    ref.invalidate(locationViewModelProvider);
  }

  Future<void> removeAddress(String id) async {
    final current = state.valueOrNull ?? <AddressModel>[];
    final updated = current.where((address) => address.id != id).toList();
    await _service.saveAddresses(updated);
    state = AsyncData(updated);
    ref.invalidate(locationViewModelProvider);
  }
}

final addressViewModelProvider =
    AsyncNotifierProvider<AddressViewModel, List<AddressModel>>(
      AddressViewModel.new,
    );
