import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../repositories/menu_repository.dart';

class MenuProvider with ChangeNotifier {
  final MenuRepository _repository = MenuRepository();
  final Uuid _uuid = const Uuid();

  List<Category> _categories = [];
  List<MenuItem> _menuItems = [];
  List<MenuItem> _filteredItems = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;

  List<Category> get categories => _categories;
  List<MenuItem> get menuItems => _menuItems;
  List<MenuItem> get filteredItems => _filteredItems;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMenuItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _menuItems = await _repository.getMenuItems();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading menu items: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory({
    required String name,
    required String icon,
    required int colorValue,
  }) async {
    final category = Category(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      color: Color(colorValue),
      createdAt: DateTime.now(),
    );

    try {
      await _repository.addCategory(category);
      await loadCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> addMenuItem({
    required String name,
    required double price,
    required String categoryId,
    String? description,
    String? imageUrl,
    bool isTimeBased = false,
    String? timeRange,
    int stock = -1,
    String? unit,
  }) async {
    final now = DateTime.now();
    final item = MenuItem(
      id: _uuid.v4(),
      name: name,
      price: price,
      categoryId: categoryId,
      description: description,
      imageUrl: imageUrl,
      isTimeBased: isTimeBased,
      timeRange: timeRange,
      stock: stock,
      unit: unit,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.addMenuItem(item);
      await loadMenuItems();
    } catch (e) {
      debugPrint('Error adding menu item: $e');
      rethrow;
    }
  }

  Future<void> updateMenuItem(MenuItem item) async {
    try {
      final updatedItem = item.copyWith(updatedAt: DateTime.now());
      await _repository.updateMenuItem(updatedItem);
      await loadMenuItems();
    } catch (e) {
      debugPrint('Error updating menu item: $e');
      rethrow;
    }
  }

  Future<void> deleteMenuItem(String id) async {
    try {
      await _repository.deleteMenuItem(id);
      await loadMenuItems();
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      rethrow;
    }
  }

  Future<void> toggleItemStatus(String id) async {
    try {
      await _repository.toggleItemStatus(id);
      await loadMenuItems();
    } catch (e) {
      debugPrint('Error toggling item status: $e');
      rethrow;
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void searchItems(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredItems = _menuItems.where((item) {
      bool matchesCategory = _selectedCategoryId == null ||
                           item.categoryId == _selectedCategoryId;
      bool matchesSearch = _searchQuery.isEmpty ||
                         item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                         (item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      return matchesCategory && matchesSearch && item.isActive;
    }).toList();
  }

  Future<void> initializeWithSampleData() async {
    if (_categories.isEmpty) {
      await loadCategories();
    }

    if (_menuItems.isEmpty && _categories.isNotEmpty) {
      final drinksCategory = _categories.firstWhere((c) => c.name == 'Đồ uống');
      final timeBasedCategory = _categories.firstWhere((c) => c.name == 'Theo giờ');

      final sampleItems = [
        {
          'name': 'sữa cacao',
          'price': 18000.0,
          'categoryId': drinksCategory.id,
          'unit': null,
        },
        {
          'name': 'sữa nóng',
          'price': 15000.0,
          'categoryId': drinksCategory.id,
          'unit': 'ly',
        },
        {
          'name': 'pepsi lon',
          'price': 15000.0,
          'categoryId': drinksCategory.id,
          'unit': 'lon',
        },
        {
          'name': 'TIỀN GIỜ',
          'price': 200000.0,
          'categoryId': timeBasedCategory.id,
          'isTimeBased': true,
          'timeRange': '12/03 15:15→12/03 15:20 (6 phút)',
        },
        {
          'name': 'dưa hấu ép',
          'price': 20000.0,
          'categoryId': drinksCategory.id,
          'unit': 'ly',
        },
      ];

      for (var itemData in sampleItems) {
        await addMenuItem(
          name: itemData['name'] as String,
          price: itemData['price'] as double,
          categoryId: itemData['categoryId'] as String,
          unit: itemData['unit'] as String?,
          isTimeBased: itemData['isTimeBased'] as bool? ?? false,
          timeRange: itemData['timeRange'] as String?,
        );
      }
    }
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  MenuItem? getItemById(String id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}