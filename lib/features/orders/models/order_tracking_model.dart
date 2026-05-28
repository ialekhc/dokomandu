import 'package:dokomandu/shared/models/order_model.dart';

class OrderTrackingModel {
  const OrderTrackingModel({
    required this.order,
    required this.riderName,
    required this.riderPhone,
    required this.riderVehicle,
    required this.riderLatitude,
    required this.riderLongitude,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.etaMinutes,
    required this.distanceKm,
    required this.progress,
    required this.lastUpdated,
    required this.canTrackLive,
  });

  final OrderModel order;
  final String riderName;
  final String riderPhone;
  final String riderVehicle;
  final double riderLatitude;
  final double riderLongitude;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final int etaMinutes;
  final double distanceKm;
  final double progress;
  final DateTime lastUpdated;
  final bool canTrackLive;

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    final orderJson = json['order'] as Map<String, dynamic>? ?? const {};

    return OrderTrackingModel(
      order: OrderModel.fromJson(orderJson),
      riderName: json['riderName']?.toString() ?? 'Delivery Rider',
      riderPhone: json['riderPhone']?.toString() ?? '',
      riderVehicle: json['riderVehicle']?.toString() ?? 'Bike',
      riderLatitude: (json['riderLatitude'] as num?)?.toDouble() ?? 0,
      riderLongitude: (json['riderLongitude'] as num?)?.toDouble() ?? 0,
      pickupLatitude: (json['pickupLatitude'] as num?)?.toDouble() ?? 0,
      pickupLongitude: (json['pickupLongitude'] as num?)?.toDouble() ?? 0,
      destinationLatitude:
          (json['destinationLatitude'] as num?)?.toDouble() ?? 0,
      destinationLongitude:
          (json['destinationLongitude'] as num?)?.toDouble() ?? 0,
      etaMinutes: (json['etaMinutes'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      lastUpdated:
          DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ??
          DateTime.now(),
      canTrackLive: json['canTrackLive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order.toJson(),
      'riderName': riderName,
      'riderPhone': riderPhone,
      'riderVehicle': riderVehicle,
      'riderLatitude': riderLatitude,
      'riderLongitude': riderLongitude,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'destinationLatitude': destinationLatitude,
      'destinationLongitude': destinationLongitude,
      'etaMinutes': etaMinutes,
      'distanceKm': distanceKm,
      'progress': progress,
      'lastUpdated': lastUpdated.toIso8601String(),
      'canTrackLive': canTrackLive,
    };
  }
}
