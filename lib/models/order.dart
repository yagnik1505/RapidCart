import 'cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
  });
}

