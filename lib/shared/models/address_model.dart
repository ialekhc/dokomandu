class AddressModel {
  const AddressModel({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.landmark,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? landmark;
  final bool isDefault;

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Home',
      fullAddress:
          json['fullAddress']?.toString() ?? json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      landmark: json['landmark']?.toString(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'isDefault': isDefault,
    };
  }
}
