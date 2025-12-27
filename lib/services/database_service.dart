import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smart_warehouse_mobile/core/constants.dart';
import 'package:smart_warehouse_mobile/models/cell.dart';
import 'package:smart_warehouse_mobile/models/product.dart';
import 'package:smart_warehouse_mobile/models/operation.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._private();

  DatabaseService._private();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create cells table
    await db.execute('''
      CREATE TABLE cells (
        id INTEGER PRIMARY KEY,
        row_num INTEGER NOT NULL,
        col_num INTEGER NOT NULL,
        label TEXT NOT NULL,
        status TEXT NOT NULL,
        product_id INTEGER,
        product_name TEXT,
        product_sku TEXT,
        rfid_uid TEXT,
        quantity INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL,
        is_selected INTEGER DEFAULT 0,
        is_loading INTEGER DEFAULT 0
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT,
        rfid_uid TEXT UNIQUE,
        category TEXT,
        weight_grams INTEGER,
        auto_assign INTEGER DEFAULT 1,
        occupied_cells INTEGER DEFAULT 0,
        total_quantity INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create operations table
    await db.execute('''
      CREATE TABLE operations (
        id INTEGER PRIMARY KEY,
        type TEXT NOT NULL,
        command TEXT NOT NULL,
        status TEXT NOT NULL,
        error_message TEXT,
        product_id INTEGER,
        product_name TEXT,
        cell_id INTEGER,
        cell_label TEXT,
        execution_time_ms INTEGER,
        priority TEXT NOT NULL,
        created_at TEXT NOT NULL,
        started_at TEXT,
        completed_at TEXT
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('settings', {
      'key': 'server_url',
      'value': AppConstants.baseUrl,
    });

    await db.insert('settings', {
      'key': 'esp32_ip',
      'value': '192.168.1.101',
    });

    await db.insert('settings', {
      'key': 'auto_refresh',
      'value': 'true',
    });

    await db.insert('settings', {
      'key': 'refresh_interval',
      'value': '10',
    });
  }

  // Cells CRUD
  Future<void> saveCells(List<WarehouseCell> cells) async {
    final db = await database;
    final batch = db.batch();

    for (final cell in cells) {
      batch.insert(
        'cells',
        cell.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<WarehouseCell>> getCells() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cells');
    return List.generate(maps.length, (i) => WarehouseCell.fromJson(maps[i]));
  }

  Future<void> updateCell(WarehouseCell cell) async {
    final db = await database;
    await db.update(
      'cells',
      cell.toJson(),
      where: 'id = ?',
      whereArgs: [cell.id],
    );
  }

  // Products CRUD
  Future<void> saveProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();

    for (final product in products) {
      batch.insert(
        'products',
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  // Operations CRUD
  Future<void> saveOperations(List<Operation> operations) async {
    final db = await database;
    final batch = db.batch();

    for (final operation in operations) {
      batch.insert(
        'operations',
        {
          ...operation.toJson(),
          'type': operation.type,
          'command': operation.command,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  Future<List<Operation>> getOperations({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'operations',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Operation.fromJson(maps[i]));
  }

  // Settings CRUD
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('cells');
    await db.delete('products');
    await db.delete('operations');
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final cellsCount = await db.rawQuery('SELECT COUNT(*) FROM cells');
    final occupiedCellsCount = await db.rawQuery(
      'SELECT COUNT(*) FROM cells WHERE status = ?',
      ['OCCUPIED']
    );
    final productsCount = await db.rawQuery('SELECT COUNT(*) FROM products');
    final operationsCount = await db.rawQuery('SELECT COUNT(*) FROM operations');

    return {
      'total_cells': cellsCount.first.values.first as int,
      'occupied_cells': occupiedCellsCount.first.values.first as int,
      'total_products': productsCount.first.values.first as int,
      'total_operations': operationsCount.first.values.first as int,
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}