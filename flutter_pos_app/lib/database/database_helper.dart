import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pos_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create menu_items table
    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT,
        category_id TEXT NOT NULL,
        image_url TEXT,
        is_time_based INTEGER NOT NULL DEFAULT 0,
        time_range TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        stock INTEGER NOT NULL DEFAULT -1,
        unit TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Create orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        table_number TEXT NOT NULL,
        position TEXT NOT NULL,
        staff_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        discount REAL NOT NULL DEFAULT 0.0,
        vat_rate REAL NOT NULL DEFAULT 0.0,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    // Create order_items table
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        menu_item_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        unit TEXT,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (menu_item_id) REFERENCES menu_items (id)
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'id': 'cat_drinks',
        'name': 'Đồ uống',
        'icon': 'local_drink',
        'color': 0xFF2196F3,
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cat_food',
        'name': 'Thức ăn',
        'icon': 'restaurant',
        'color': 0xFF4CAF50,
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cat_services',
        'name': 'Dịch vụ',
        'icon': 'room_service',
        'color': 0xFF9C27B0,
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': 'cat_time_based',
        'name': 'Theo giờ',
        'icon': 'schedule',
        'color': 0xFFFF9800,
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // Categories CRUD
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories({bool activeOnly = true}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menu Items CRUD
  Future<int> insertMenuItem(MenuItem item) async {
    final db = await database;
    return await db.insert('menu_items', item.toMap());
  }

  Future<List<MenuItem>> getMenuItems({
    bool activeOnly = true,
    String? categoryId,
    String? searchQuery,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (activeOnly) {
      whereClause += 'is_active = ?';
      whereArgs.add(1);
    }

    if (categoryId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category_id = ?';
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'name LIKE ?';
      whereArgs.add('%$searchQuery%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'menu_items',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => MenuItem.fromMap(maps[i]));
  }

  Future<MenuItem?> getMenuItem(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return MenuItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMenuItem(MenuItem item) async {
    final db = await database;
    return await db.update(
      'menu_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteMenuItem(String id) async {
    final db = await database;
    return await db.delete(
      'menu_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Orders CRUD
  Future<int> insertOrder(Order order) async {
    final db = await database;
    await db.transaction((txn) async {
      // Insert order
      await txn.insert('orders', {
        'id': order.id,
        'table_number': order.tableNumber,
        'position': order.position,
        'staff_name': order.staffName,
        'created_at': order.createdAt.millisecondsSinceEpoch,
        'discount': order.discount,
        'vat_rate': order.vatRate,
        'status': 'pending',
      });

      // Insert order items
      for (var item in order.items) {
        await txn.insert('order_items', {
          'id': item.id,
          'order_id': order.id,
          'menu_item_id': item.menuItem.id,
          'quantity': item.quantity,
          'unit_price': item.menuItem.price,
          'unit': item.unit,
        });
      }
    });
    return 1;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}