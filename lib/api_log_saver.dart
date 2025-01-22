import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class ApiLogSaver {
  static final ApiLogSaver instance = ApiLogSaver._init();

  static Database? _database;

  ApiLogSaver._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('api_logs.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE api_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT,
        method TEXT,
        headers TEXT,
        body TEXT,
        statusCode INTEGER,
        message TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future<void> logRequest(
    String url,
    String method,
    Map<String, dynamic>? headers,
    dynamic body,
    int? statusCode,
    String message,
  ) async {
    final db = await instance.database;
    final logEntry = {
      'url': url,
      'method': method,
      'headers': headers?.toString(),
      'body': body?.toString(),
      'statusCode': statusCode,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await db.insert('api_logs', logEntry);
  }

  Future<List<Map<String, dynamic>>> fetchLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? url,
    String? method,
    String? message,
  }) async {
    final db = await instance.database;

    // Initialize whereClause as an empty string to avoid null issues
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause +=
          whereClause.isNotEmpty ? ' AND timestamp >= ?' : 'timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClause +=
          whereClause.isNotEmpty ? ' AND timestamp <= ?' : 'timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    if (url != null) {
      whereClause += whereClause.isNotEmpty ? ' AND url LIKE ?' : 'url LIKE ?';
      whereArgs.add('%$url%');
    }

    if (method != null) {
      whereClause += whereClause.isNotEmpty ? ' AND method = ?' : 'method = ?';
      whereArgs.add(method);
    }

    if (message != null) {
      whereClause +=
          whereClause.isNotEmpty ? ' AND message LIKE ?' : 'message LIKE ?';
      whereArgs.add('%$message%');
    }

    // If whereClause is empty, pass null for "where"
    return await db.query(
      'api_logs',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
    );
  }

  Future<Uint8List> exportLogsToCSVAsBytes({
    DateTime? startDate,
    DateTime? endDate,
    String? url,
    String? method,
    String? message,
  }) async {
    final logs = await fetchLogs(
      startDate: startDate,
      endDate: endDate,
      url: url,
      method: method,
      message: message,
    );
    List<List<String>> csvData = [
      [
        "ID",
        "URL",
        "Method",
        "Headers",
        "Body",
        "Status Code",
        "Message",
        "Timestamp"
      ],
    ];

    for (var log in logs) {
      csvData.add([
        log['id'].toString(),
        log['url'] ?? '',
        log['method'] ?? '',
        log['headers'] ?? '',
        log['body'] ?? '',
        log['statusCode']?.toString() ?? '',
        log['message'] ?? '',
        log['timestamp'] ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    // Convert CSV to bytes
    return Uint8List.fromList(utf8.encode(csv));
  }

  Future<void> clearLogs() async {
    final db = await instance.database;
    await db.delete('api_logs');
  }
}
