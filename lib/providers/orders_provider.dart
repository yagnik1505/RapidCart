import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  Future<void> placeOrder({required String userId, required List<CartItem> items}) async {
    final total = items.fold<double>(0.0, (a, b) => a + b.subtotal);
    final now = DateTime.now();
    final doc = await _db.collection('users').doc(userId).collection('orders').add({
      'total': total,
      'createdAt': now.toIso8601String(),
      'items': items
          .map((e) => {
                'productId': e.product.id,
                'name': e.product.name,
                'price': e.product.price,
                'quantity': e.quantity,
              })
          .toList(),
    });
    _orders.insert(
      0,
      OrderModel(id: doc.id, items: items, total: total, createdAt: now),
    );
    notifyListeners();
  }
}

