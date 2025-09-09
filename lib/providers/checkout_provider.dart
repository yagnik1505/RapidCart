import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class CheckoutProvider extends ChangeNotifier {
  DeliveryAddress? _deliveryAddress;
  PaymentMethod? _paymentMethod;
  String? _notes;
  bool _isLoading = false;
  String? _error;

  DeliveryAddress? get deliveryAddress => _deliveryAddress;
  PaymentMethod? get paymentMethod => _paymentMethod;
  String? get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setDeliveryAddress(DeliveryAddress address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  bool get canProceedToPayment {
    return _deliveryAddress != null && _paymentMethod != null;
  }

  void clearCheckout() {
    _deliveryAddress = null;
    _paymentMethod = null;
    _notes = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Map<String, dynamic> getCheckoutData() {
    return {
      'deliveryAddress': _deliveryAddress?.toMap(),
      'paymentMethod': _paymentMethod?.toMap(),
      'notes': _notes,
    };
  }
}
