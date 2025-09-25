class MenuItem {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String categoryId;
  final String? imageUrl;
  final bool isTimeBased;
  final String? timeRange;
  final bool isActive;
  final int stock;
  final String? unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.description,
    this.imageUrl,
    this.isTimeBased = false,
    this.timeRange,
    this.isActive = true,
    this.stock = -1, // -1 means unlimited stock
    this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'category_id': categoryId,
      'image_url': imageUrl,
      'is_time_based': isTimeBased ? 1 : 0,
      'time_range': timeRange,
      'is_active': isActive ? 1 : 0,
      'stock': stock,
      'unit': unit,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      description: map['description'],
      categoryId: map['category_id'],
      imageUrl: map['image_url'],
      isTimeBased: map['is_time_based'] == 1,
      timeRange: map['time_range'],
      isActive: map['is_active'] == 1,
      stock: map['stock'],
      unit: map['unit'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? categoryId,
    String? imageUrl,
    bool? isTimeBased,
    String? timeRange,
    bool? isActive,
    int? stock,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      isTimeBased: isTimeBased ?? this.isTimeBased,
      timeRange: timeRange ?? this.timeRange,
      isActive: isActive ?? this.isActive,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenuItem{id: $id, name: $name, price: $price, categoryId: $categoryId, isActive: $isActive}';
  }
}