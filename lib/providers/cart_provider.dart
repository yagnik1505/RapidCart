import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _itemsByProductId = {};

  List<CartItem> get items => _itemsByProductId.values.toList(growable: false);

  int get totalQuantity => _itemsByProductId.values.fold(0, (a, b) => a + b.quantity);

  double get totalPrice => _itemsByProductId.values.fold(0.0, (a, b) => a + b.subtotal);

  void add(Product product) {
    final existing = _itemsByProductId[product.id];
    if (existing == null) {
      _itemsByProductId[product.id] = CartItem(product: product, quantity: 1);
    } else {
      _itemsByProductId[product.id] = existing.copyWith(quantity: existing.quantity + 1);
    }
    notifyListeners();
  }

  void removeOne(Product product) {
    final existing = _itemsByProductId[product.id];
    if (existing == null) return;
    if (existing.quantity <= 1) {
      _itemsByProductId.remove(product.id);
    } else {
      _itemsByProductId[product.id] = existing.copyWith(quantity: existing.quantity - 1);
    }
    notifyListeners();
  }

  void remove(Product product) {
    _itemsByProductId.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _itemsByProductId.clear();
    notifyListeners();
  }
}

