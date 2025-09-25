import 'order_item.dart';

class Order {
  final String id;
  final String tableNumber;
  final String position;
  final String staffName;
  final DateTime createdAt;
  final List<OrderItem> items;
  double discount;
  double vatRate;

  Order({
    required this.id,
    required this.tableNumber,
    required this.position,
    required this.staffName,
    required this.createdAt,
    required this.items,
    this.discount = 0.0,
    this.vatRate = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => subtotal * (discount / 100);

  double get vatAmount => (subtotal - discountAmount) * (vatRate / 100);

  double get total => subtotal - discountAmount + vatAmount;

  Order copyWith({
    String? id,
    String? tableNumber,
    String? position,
    String? staffName,
    DateTime? createdAt,
    List<OrderItem>? items,
    double? discount,
    double? vatRate,
  }) {
    return Order(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      position: position ?? this.position,
      staffName: staffName ?? this.staffName,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      vatRate: vatRate ?? this.vatRate,
    );
  }
}