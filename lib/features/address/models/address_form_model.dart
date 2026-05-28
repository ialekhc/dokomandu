class AddressFormModel {
  const AddressFormModel({
    required this.label,
    required this.fullAddress,
    this.landmark,
  });

  final String label;
  final String fullAddress;
  final String? landmark;
}
