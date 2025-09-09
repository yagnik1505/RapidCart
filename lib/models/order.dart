import 'cart_item.dart';

enum OrderStatus { pending, confirmed, preparing, outForDelivery, delivered, cancelled }

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final OrderStatus status;
  final DeliveryAddress? deliveryAddress;
  final PaymentMethod? paymentMethod;
  final String? notes;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.createdAt,
    this.status = OrderStatus.pending,
    this.deliveryAddress,
    this.paymentMethod,
    this.notes,
  });

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? total,
    DateTime? createdAt,
    OrderStatus? status,
    DeliveryAddress? deliveryAddress,
    PaymentMethod? paymentMethod,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'deliveryAddress': deliveryAddress?.toMap(),
      'paymentMethod': paymentMethod?.toMap(),
      'notes': notes,
      'items': items.map((item) => {
        'productId': item.product.id,
        'name': item.product.name,
        'price': item.product.price,
        'quantity': item.quantity,
        'subtotal': item.subtotal,
      }).toList(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, List<CartItem> items) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: items,
      total: (map['total'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: map['deliveryAddress'] != null 
          ? DeliveryAddress.fromMap(map['deliveryAddress']) 
          : null,
      paymentMethod: map['paymentMethod'] != null 
          ? PaymentMethod.fromMap(map['paymentMethod']) 
          : null,
      notes: map['notes'],
    );
  }
}

class DeliveryAddress {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;

  const DeliveryAddress({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
    };
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      landmark: map['landmark'],
    );
  }

  String get fullAddress => '$address, $city, $state - $pincode';
}

enum PaymentType { cashOnDelivery, onlinePayment, wallet }

class PaymentMethod {
  final PaymentType type;
  final String? transactionId;
  final String? paymentStatus;

  const PaymentMethod({
    required this.type,
    this.transactionId,
    this.paymentStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'transactionId': transactionId,
      'paymentStatus': paymentStatus,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      type: PaymentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PaymentType.cashOnDelivery,
      ),
      transactionId: map['transactionId'],
      paymentStatus: map['paymentStatus'],
    );
  }
}

