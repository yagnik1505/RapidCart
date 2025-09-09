import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  Future<String?> placeOrder({
    required String userId,
    required List<CartItem> items,
    DeliveryAddress? deliveryAddress,
    PaymentMethod? paymentMethod,
    String? notes,
  }) async {
    try {
      final total = items.fold<double>(0.0, (a, b) => a + b.subtotal);
      final now = DateTime.now();
      
      final orderData = {
        'userId': userId,
        'total': total,
        'createdAt': now.toIso8601String(),
        'status': OrderStatus.pending.name,
        'deliveryAddress': deliveryAddress?.toMap(),
        'paymentMethod': paymentMethod?.toMap(),
        'notes': notes,
        'items': items.map((e) => {
          'productId': e.product.id,
          'name': e.product.name,
          'price': e.product.price,
          'quantity': e.quantity,
          'subtotal': e.subtotal,
        }).toList(),
      };

      // Add to user's orders collection
      final doc = await _db.collection('users').doc(userId).collection('orders').add(orderData);
      
      // Also add to global orders collection for admin management
      await _db.collection('orders').doc(doc.id).set({
        ...orderData,
        'id': doc.id,
      });

      final order = OrderModel(
        id: doc.id,
        userId: userId,
        items: items,
        total: total,
        createdAt: now,
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      _orders.insert(0, order);
      notifyListeners();
      
      return doc.id;
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow;
    }
  }

  Future<void> loadUserOrders(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = (data['items'] as List).map((itemData) {
          // Note: This is a simplified approach. In a real app, you'd fetch product details
          return CartItem(
            product: Product(
              id: itemData['productId'],
              name: itemData['name'],
              description: '',
              imageUrl: '',
              price: itemData['price'].toDouble(),
              unit: 'pcs',
            ),
            quantity: itemData['quantity'],
          );
        }).toList();

        final order = OrderModel.fromMap({...data, 'id': doc.id}, items);
        _orders.add(order);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': status.name,
      });
      
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }
}

