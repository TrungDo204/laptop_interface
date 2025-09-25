import '../database/database_helper.dart';
import '../models/category.dart';
import '../models/menu_item.dart';

class MenuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Categories
  Future<List<Category>> getCategories({bool activeOnly = true}) async {
    return await _dbHelper.getCategories(activeOnly: activeOnly);
  }

  Future<int> addCategory(Category category) async {
    return await _dbHelper.insertCategory(category);
  }

  Future<int> updateCategory(Category category) async {
    return await _dbHelper.updateCategory(category);
  }

  Future<int> deleteCategory(String id) async {
    return await _dbHelper.deleteCategory(id);
  }

  // Menu Items
  Future<List<MenuItem>> getMenuItems({
    bool activeOnly = true,
    String? categoryId,
    String? searchQuery,
  }) async {
    return await _dbHelper.getMenuItems(
      activeOnly: activeOnly,
      categoryId: categoryId,
      searchQuery: searchQuery,
    );
  }

  Future<MenuItem?> getMenuItem(String id) async {
    return await _dbHelper.getMenuItem(id);
  }

  Future<int> addMenuItem(MenuItem item) async {
    return await _dbHelper.insertMenuItem(item);
  }

  Future<int> updateMenuItem(MenuItem item) async {
    return await _dbHelper.updateMenuItem(item);
  }

  Future<int> deleteMenuItem(String id) async {
    return await _dbHelper.deleteMenuItem(id);
  }

  Future<List<MenuItem>> searchMenuItems(String query) async {
    return await _dbHelper.getMenuItems(
      activeOnly: true,
      searchQuery: query,
    );
  }

  Future<List<MenuItem>> getPopularItems({int limit = 10}) async {
    final allItems = await _dbHelper.getMenuItems(activeOnly: true);
    return allItems.take(limit).toList();
  }

  Future<List<MenuItem>> getItemsByCategory(String categoryId) async {
    return await _dbHelper.getMenuItems(
      activeOnly: true,
      categoryId: categoryId,
    );
  }

  Future<void> toggleItemStatus(String id) async {
    final item = await getMenuItem(id);
    if (item != null) {
      final updatedItem = item.copyWith(
        isActive: !item.isActive,
        updatedAt: DateTime.now(),
      );
      await updateMenuItem(updatedItem);
    }
  }

  Future<void> updateStock(String id, int newStock) async {
    final item = await getMenuItem(id);
    if (item != null) {
      final updatedItem = item.copyWith(
        stock: newStock,
        updatedAt: DateTime.now(),
      );
      await updateMenuItem(updatedItem);
    }
  }
}