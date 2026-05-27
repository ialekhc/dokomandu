import 'package:dokomandu/shared/models/address_model.dart';

class CheckoutSummaryModel {
  const CheckoutSummaryModel({
    required this.address,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.paymentMethod,
  });

  final AddressModel address;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final String paymentMethod;

  Map<String, dynamic> toJson() {
    return {
      'addressId': address.id,
      'address': address.toJson(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'paymentMethod': paymentMethod,
    };
  }
}
