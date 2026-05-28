enum OrderStatus {
  placed,
  accepted,
  preparing,
  ready,
  pickedUp,
  onTheWay,
  nearby,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Order Accepted';
      case OrderStatus.preparing:
        return 'Preparing Food';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.onTheWay:
        return 'Out for Delivery';
      case OrderStatus.nearby:
        return 'Nearby';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'accepted':
      case 'order_accepted':
        return OrderStatus.accepted;
      case 'preparing':
      case 'preparing_food':
        return OrderStatus.preparing;
      case 'ready':
      case 'ready_for_pickup':
        return OrderStatus.ready;
      case 'picked_up':
      case 'pickedup':
        return OrderStatus.pickedUp;
      case 'out_for_delivery':
      case 'on_the_way':
      case 'ontheway':
        return OrderStatus.onTheWay;
      case 'order_placed':
      case 'placed':
        return OrderStatus.placed;
      case 'nearby':
        return OrderStatus.nearby;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }
}

class OrderLineItem {
  const OrderLineItem({
    required this.foodName,
    required this.quantity,
    required this.price,
  });

  final String foodName;
  final int quantity;
  final double price;

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      foodName: json['foodName']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'foodName': foodName, 'quantity': quantity, 'price': price};
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    this.paymentMethod = 'COD',
    this.kitchenName,
    this.kitchenLatitude,
    this.kitchenLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.isScheduled = false,
    this.scheduledFor,
    this.trackingStarted = true,
    this.codPaid = false,
  });

  final String id;
  final List<OrderLineItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String deliveryAddress;
  final String paymentMethod;
  final String? kitchenName;
  final double? kitchenLatitude;
  final double? kitchenLongitude;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final bool isScheduled;
  final DateTime? scheduledFor;
  final bool trackingStarted;
  final bool codPaid;

  OrderModel copyWith({
    String? id,
    List<OrderLineItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? tax,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    String? deliveryAddress,
    String? paymentMethod,
    String? kitchenName,
    double? kitchenLatitude,
    double? kitchenLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    bool? isScheduled,
    DateTime? scheduledFor,
    bool? trackingStarted,
    bool? codPaid,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      kitchenName: kitchenName ?? this.kitchenName,
      kitchenLatitude: kitchenLatitude ?? this.kitchenLatitude,
      kitchenLongitude: kitchenLongitude ?? this.kitchenLongitude,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      trackingStarted: trackingStarted ?? this.trackingStarted,
      codPaid: codPaid ?? this.codPaid,
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: OrderStatusX.fromValue(json['status']?.toString()),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
      kitchenName: json['kitchenName']?.toString(),
      kitchenLatitude: (json['kitchenLatitude'] as num?)?.toDouble(),
      kitchenLongitude: (json['kitchenLongitude'] as num?)?.toDouble(),
      deliveryLatitude: (json['deliveryLatitude'] as num?)?.toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] as num?)?.toDouble(),
      isScheduled: json['isScheduled'] as bool? ?? false,
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.tryParse(json['scheduledFor']?.toString() ?? '')
          : null,
      trackingStarted: json['trackingStarted'] as bool? ?? true,
      codPaid: json['codPaid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'kitchenName': kitchenName,
      'kitchenLatitude': kitchenLatitude,
      'kitchenLongitude': kitchenLongitude,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'isScheduled': isScheduled,
      'scheduledFor': scheduledFor?.toIso8601String(),
      'trackingStarted': trackingStarted,
      'codPaid': codPaid,
    };
  }
}
