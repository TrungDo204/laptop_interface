import 'menu_item.dart';

class OrderItem {
  final String id;
  final MenuItem menuItem;
  int quantity;
  final String? unit;

  OrderItem({
    required this.id,
    required this.menuItem,
    this.quantity = 1,
    this.unit,
  });

  double get totalPrice => menuItem.price * quantity;

  OrderItem copyWith({
    String? id,
    MenuItem? menuItem,
    int? quantity,
    String? unit,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}