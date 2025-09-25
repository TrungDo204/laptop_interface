import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/menu_item.dart';

class OrderProvider with ChangeNotifier {
  Order? _currentOrder;

  Order? get currentOrder => _currentOrder;

  void createNewOrder({
    required String tableNumber,
    required String position,
    required String staffName,
  }) {
    _currentOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tableNumber: tableNumber,
      position: position,
      staffName: staffName,
      createdAt: DateTime.now(),
      items: [],
    );
    notifyListeners();
  }

  void addItem(MenuItem menuItem, {int quantity = 1, String? unit}) {
    if (_currentOrder == null) return;

    final existingItemIndex = _currentOrder!.items.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingItemIndex != -1) {
      _currentOrder!.items[existingItemIndex].quantity += quantity;
    } else {
      final newItem = OrderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        menuItem: menuItem,
        quantity: quantity,
        unit: unit,
      );
      _currentOrder!.items.add(newItem);
    }
    notifyListeners();
  }

  void updateItemQuantity(String itemId, int quantity) {
    if (_currentOrder == null) return;

    final itemIndex = _currentOrder!.items.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      if (quantity <= 0) {
        _currentOrder!.items.removeAt(itemIndex);
      } else {
        _currentOrder!.items[itemIndex].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    if (_currentOrder == null) return;

    _currentOrder!.items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateDiscount(double discount) {
    if (_currentOrder == null) return;

    _currentOrder = _currentOrder!.copyWith(discount: discount);
    notifyListeners();
  }

  void updateVatRate(double vatRate) {
    if (_currentOrder == null) return;

    _currentOrder = _currentOrder!.copyWith(vatRate: vatRate);
    notifyListeners();
  }

  void clearOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}