import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medication_models.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersionNumber,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de Compuestos (Principios Activos)
    await db.execute('''
      CREATE TABLE compuestos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pa TEXT UNIQUE,
        pa TEXT,
        familia TEXT,
        uso TEXT,
        posologia TEXT,
        consideraciones TEXT,
        mecanismo TEXT,
        marcas TEXT,
        genericos TEXT,
        efectos TEXT,
        contraindicaciones TEXT,
        id_fa TEXT,
        id_as1 TEXT,
        id_as2 TEXT,
        id_as3 TEXT,
        id_as4 TEXT,
        id_as5 TEXT,
        acceso TEXT
      )
    ''');

    // Tabla de Marcas
    await db.execute('''
      CREATE TABLE marcas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_ma TEXT UNIQUE,
        id_pam TEXT,
        ma TEXT,
        pa_m TEXT,
        tl_m TEXT,
        familia_m TEXT,
        uso_m TEXT,
        presentacion_m TEXT,
        contraindicaciones_m TEXT,
        via_m TEXT,
        tipo_m TEXT,
        lab_m TEXT,
        id_labm TEXT,
        id_fam TEXT,
        acceso_m TEXT
      )
    ''');

    // Tabla de Favoritos
    await db.execute('''
      CREATE TABLE favoritos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT,
        tipo TEXT,
        fecha_agregado TEXT
      )
    ''');

    // Cargar datos iniciales desde JSON
    await _loadInitialData(db);
  }

  Future<void> _loadInitialData(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString(
        AppConstants.jsonDataPath,
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Insertar Compuestos
      if (jsonData['compuestos'] != null) {
        for (var compuesto in jsonData['compuestos']) {
          await db.insert('compuestos', {
            'id_pa': compuesto['ID_PA'],
            'pa': compuesto['PA'],
            'familia': compuesto['Familia'],
            'uso': compuesto['Uso'],
            'posologia': compuesto['Posologia'],
            'consideraciones': compuesto['Consideraciones'],
            'mecanismo': compuesto['Mecanismo'],
            'marcas': compuesto['Marcas'],
            'genericos': compuesto['Genericos'],
            'efectos': compuesto['Efectos'],
            'contraindicaciones': compuesto['Contraindicaciones'],
            'id_fa': compuesto['ID_FA'],
            'id_as1': compuesto['ID_AS1'] ?? '',
            'id_as2': compuesto['ID_AS2'] ?? '',
            'id_as3': compuesto['ID_AS3'] ?? '',
            'id_as4': compuesto['ID_AS4'] ?? '',
            'id_as5': compuesto['ID_AS5'] ?? '',
            'acceso': compuesto['Acceso'],
          });
        }
      }

      // Insertar Marcas
      if (jsonData['marcas'] != null) {
        for (var marca in jsonData['marcas']) {
          await db.insert('marcas', {
            'id_ma': marca['ID_MA'],
            'id_pam': marca['ID_PAM'],
            'ma': marca['MA'],
            'pa_m': marca['PA_M'],
            'tl_m': marca['TL_M'],
            'familia_m': marca['Familia_M'],
            'uso_m': marca['Uso_M'],
            'presentacion_m': marca['Presentacion_M'],
            'contraindicaciones_m': marca['Contraindicaciones_M'],
            'via_m': marca['Via_M'],
            'tipo_m': marca['Tipo_M'],
            'lab_m': marca['Lab_M'],
            'id_labm': marca['ID_LABM'],
            'id_fam': marca['ID_FAM'],
            'acceso_m': marca['Acceso_M'],
          });
        }
      }

      print(
        '✅ Base de datos cargada: ${jsonData['compuestos']?.length ?? 0} compuestos, ${jsonData['marcas']?.length ?? 0} marcas',
      );
    } catch (e) {
      print('❌ Error cargando datos iniciales: $e');
    }
  }

  // === BÚSQUEDAS ===

  Future<List<Compuesto>> searchCompuestos(String query) async {
    final db = await database;
    final results = await db.query(
      'compuestos',
      where: 'pa LIKE ? OR familia LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'pa ASC',
    );
    return results.map((map) => Compuesto.fromMap(map)).toList();
  }

  Future<List<Marca>> searchMarcas(String query) async {
    final db = await database;
    final results = await db.query(
      'marcas',
      where: 'ma LIKE ? OR pa_m LIKE ? OR lab_m LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'ma ASC',
    );
    return results.map((map) => Marca.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> searchGlobal(String query) async {
    final compuestos = await searchCompuestos(query);
    final marcas = await searchMarcas(query);
    return {'compuestos': compuestos, 'marcas': marcas};
  }

  // === OBTENER POR ID ===

  Future<Compuesto?> getCompuestoById(String idPa) async {
    final db = await database;
    final results = await db.query(
      'compuestos',
      where: 'id_pa = ?',
      whereArgs: [idPa],
    );
    if (results.isNotEmpty) {
      return Compuesto.fromMap(results.first);
    }
    return null;
  }

  Future<Marca?> getMarcaById(String idMa) async {
    final db = await database;
    final results = await db.query(
      'marcas',
      where: 'id_ma = ?',
      whereArgs: [idMa],
    );
    if (results.isNotEmpty) {
      return Marca.fromMap(results.first);
    }
    return null;
  }

  Future<List<Marca>> getMarcasByCompuestoId(String idPa) async {
    final db = await database;
    final results = await db.query(
      'marcas',
      where: 'id_pam = ?',
      whereArgs: [idPa],
      orderBy: 'ma ASC',
    );
    return results.map((map) => Marca.fromMap(map)).toList();
  }

  // === OBTENER TODOS ===

  Future<List<Compuesto>> getAllCompuestos() async {
    final db = await database;
    final results = await db.query('compuestos', orderBy: 'pa ASC');
    return results.map((map) => Compuesto.fromMap(map)).toList();
  }

  Future<List<Marca>> getAllMarcas() async {
    final db = await database;
    final results = await db.query('marcas', orderBy: 'ma ASC');
    return results.map((map) => Marca.fromMap(map)).toList();
  }

  // === FILTROS POR FAMILIA Y LABORATORIO ===

  Future<List<Compuesto>> getCompuestosByFamilia(String familia) async {
    final db = await database;
    final results = await db.query(
      'compuestos',
      where: 'familia = ?',
      whereArgs: [familia],
      orderBy: 'pa ASC',
    );
    return results.map((map) => Compuesto.fromMap(map)).toList();
  }

  Future<List<Marca>> getMarcasByLaboratorio(String laboratorio) async {
    final db = await database;
    final results = await db.query(
      'marcas',
      where: 'lab_m = ?',
      whereArgs: [laboratorio],
      orderBy: 'ma ASC',
    );
    return results.map((map) => Marca.fromMap(map)).toList();
  }

  Future<List<String>> getAllFamilias() async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT DISTINCT familia FROM compuestos ORDER BY familia ASC',
    );
    return results.map((map) => map['familia'] as String).toList();
  }

  Future<List<String>> getAllLaboratorios() async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT DISTINCT lab_m FROM marcas WHERE lab_m IS NOT NULL ORDER BY lab_m ASC',
    );
    return results.map((map) => map['lab_m'] as String).toList();
  }

  // === FAVORITOS ===

  Future<void> addFavorito(String itemId, String tipo) async {
    final db = await database;
    await db.insert('favoritos', {
      'item_id': itemId,
      'tipo': tipo,
      'fecha_agregado': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorito(String itemId) async {
    final db = await database;
    await db.delete('favoritos', where: 'item_id = ?', whereArgs: [itemId]);
  }

  Future<bool> isFavorito(String itemId) async {
    final db = await database;
    final results = await db.query(
      'favoritos',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );
    return results.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllFavoritos() async {
    final db = await database;
    return await db.query('favoritos', orderBy: 'fecha_agregado DESC');
  }
}
