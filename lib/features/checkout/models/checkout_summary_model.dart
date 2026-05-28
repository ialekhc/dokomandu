import 'package:dokomandu/shared/models/address_model.dart';

class CheckoutSummaryModel {
  const CheckoutSummaryModel({
    required this.address,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.deliveryType,
    this.scheduledFor,
  });

  final AddressModel address;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final String paymentMethod;
  final String deliveryType;
  final DateTime? scheduledFor;

  bool get isScheduled => deliveryType == 'SCHEDULE';

  Map<String, dynamic> toJson() {
    return {
      'addressId': address.id,
      'address': address.toJson(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
      'deliveryType': deliveryType,
      'scheduledFor': scheduledFor?.toIso8601String(),
    };
  }
}
