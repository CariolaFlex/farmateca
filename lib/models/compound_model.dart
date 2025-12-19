// lib/models/compound_model.dart

/// Modelo para representar un Compuesto Farmacológico
/// Mapea la estructura EXACTA del JSON farmateca_master.json
///
/// IMPORTANTE: Los nombres de campos usan EXACTAMENTE los mismos
/// nombres del JSON (con guiones bajos donde corresponde)
class Compound {
  // --- IDENTIFICADORES (CON GUIÓN BAJO) ---
  final String idPA; // ID_PA - Identificador único (ej: "PA-000001")
  final String idFA; // ID_FA - ID de familia farmacológica
  final String idAS1; // ID_AS1 - ID compuesto asociado 1
  final String idAS2; // ID_AS2 - ID compuesto asociado 2
  final String idAS3; // ID_AS3 - ID compuesto asociado 3
  final String idAS4; // ID_AS4 - ID compuesto asociado 4
  final String idAS5; // ID_AS5 - ID compuesto asociado 5

  // --- INFORMACIÓN PRINCIPAL (SIN GUIÓN BAJO) ---
  final String pa; // PA - Principio Activo (nombre)
  final String familia; // Familia - Familia Farmacológica

  // --- DESCRIPCIÓN CLÍNICA ---
  final String uso; // Uso - Uso Clínico
  final String posologia; // Posologia - Indicaciones de dosificación

  // --- INFORMACIÓN TÉCNICA ---
  final String consideraciones; // Consideraciones Especiales
  final String mecanismo; // Mecanismo de Acción

  // --- LISTAS COMO STRINGS (PARSEAR CON ";") ---
  final String marcas; // Marcas - STRING separado por ";"
  final String genericos; // Genericos - STRING separado por ";"

  // --- SEGURIDAD ---
  final String efectos; // Efectos Adversos
  final String contraindicaciones; // Contraindicaciones

  // --- CONTROL DE ACCESO ---
  final String acceso; // Acceso - 'F' = Free, 'P' = Premium

  // --- METADATA LOCAL ---
  bool isFavorite; // Favorito (no está en JSON)

  /// Constructor principal
  Compound({
    required this.idPA,
    required this.idFA,
    required this.idAS1,
    required this.idAS2,
    required this.idAS3,
    required this.idAS4,
    required this.idAS5,
    required this.pa,
    required this.familia,
    required this.uso,
    required this.posologia,
    required this.consideraciones,
    required this.mecanismo,
    required this.marcas,
    required this.genericos,
    required this.efectos,
    required this.contraindicaciones,
    required this.acceso,
    this.isFavorite = false,
  });

  // ========================================
  // FACTORY: Crear desde JSON
  // ========================================

  /// Crea Compound desde un mapa JSON
  /// USA LOS NOMBRES EXACTOS DEL JSON (con guiones bajos)
  factory Compound.fromJson(Map<String, dynamic> json) {
    return Compound(
      idPA: json['ID_PA'] as String? ?? '', // ← CON GUIÓN BAJO
      idFA: json['ID_FA'] as String? ?? '',
      idAS1: json['ID_AS1'] as String? ?? '',
      idAS2: json['ID_AS2'] as String? ?? '',
      idAS3: json['ID_AS3'] as String? ?? '',
      idAS4: json['ID_AS4'] as String? ?? '',
      idAS5: json['ID_AS5'] as String? ?? '',
      pa: json['PA'] as String? ?? 'Sin nombre',
      familia: json['Familia'] as String? ?? 'Sin familia',
      uso: json['Uso'] as String? ?? 'No especificado',
      posologia: json['Posologia'] as String? ?? 'Consulte médico',
      consideraciones: json['Consideraciones'] as String? ?? '',
      mecanismo: json['Mecanismo'] as String? ?? '',
      marcas: json['Marcas'] as String? ?? '', // ← STRING, no List
      genericos: json['Genericos'] as String? ?? '', // ← STRING, no List
      efectos: json['Efectos'] as String? ?? '',
      contraindicaciones: json['Contraindicaciones'] as String? ?? '',
      acceso: json['Acceso'] as String? ?? 'F',
      isFavorite: false,
    );
  }

  // ========================================
  // MÉTODOS DE CONVERSIÓN SQLite
  // ========================================

  /// Convierte a Map para SQLite (snake_case para columnas)
  Map<String, dynamic> toMap() {
    return {
      'id_pa': idPA,
      'id_fa': idFA,
      'id_as1': idAS1,
      'id_as2': idAS2,
      'id_as3': idAS3,
      'id_as4': idAS4,
      'id_as5': idAS5,
      'pa': pa,
      'familia': familia,
      'uso': uso,
      'posologia': posologia,
      'consideraciones': consideraciones,
      'mecanismo': mecanismo,
      'marcas': marcas, // Ya es String
      'genericos': genericos, // Ya es String
      'efectos': efectos,
      'contraindicaciones': contraindicaciones,
      'acceso': acceso,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Crea Compound desde Map de SQLite
  factory Compound.fromMap(Map<String, dynamic> map) {
    return Compound(
      idPA: map['id_pa'] as String,
      idFA: map['id_fa'] as String,
      idAS1: map['id_as1'] as String,
      idAS2: map['id_as2'] as String,
      idAS3: map['id_as3'] as String,
      idAS4: map['id_as4'] as String,
      idAS5: map['id_as5'] as String,
      pa: map['pa'] as String,
      familia: map['familia'] as String,
      uso: map['uso'] as String,
      posologia: map['posologia'] as String,
      consideraciones: map['consideraciones'] as String,
      mecanismo: map['mecanismo'] as String,
      marcas: map['marcas'] as String,
      genericos: map['genericos'] as String,
      efectos: map['efectos'] as String,
      contraindicaciones: map['contraindicaciones'] as String,
      acceso: map['acceso'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }

  // ========================================
  // GETTERS DE NEGOCIO
  // ========================================

  bool get isGratuito => acceso == 'F';
  bool get isPremium => acceso == 'P';

  /// Parsea el string "Marcas" y retorna lista de marcas
  /// Formato: "Alividol (Oral); Bufferin (Oral); ..."
  List<String> get marcasList {
    if (marcas.isEmpty) return [];
    return marcas
        .split(';')
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();
  }

  /// Parsea el string "Genericos" y retorna lista
  /// Formato: "Paracetamol / Lab Chile (Oral); ..."
  List<String> get genericosList {
    if (genericos.isEmpty) return [];
    return genericos
        .split(';')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
  }

  bool get tieneMarcas => marcas.isNotEmpty;
  bool get tieneGenericos => genericos.isNotEmpty;
  bool get tieneEfectos => efectos.isNotEmpty;
  bool get tieneContraindicaciones => contraindicaciones.isNotEmpty;

  /// Retorna true si tiene compuestos asociados (ID_AS1-5)
  bool get tieneAsociados {
    return idAS1.isNotEmpty ||
        idAS2.isNotEmpty ||
        idAS3.isNotEmpty ||
        idAS4.isNotEmpty ||
        idAS5.isNotEmpty;
  }

  /// Lista de IDs de compuestos asociados (solo no vacíos)
  List<String> get idsAsociados {
    return [
      idAS1,
      idAS2,
      idAS3,
      idAS4,
      idAS5,
    ].where((id) => id.isNotEmpty).toList();
  }

  // ========================================
  // UTILIDADES
  // ========================================

  Compound copyWith({
    String? idPA,
    String? idFA,
    String? idAS1,
    String? idAS2,
    String? idAS3,
    String? idAS4,
    String? idAS5,
    String? pa,
    String? familia,
    String? uso,
    String? posologia,
    String? consideraciones,
    String? mecanismo,
    String? marcas,
    String? genericos,
    String? efectos,
    String? contraindicaciones,
    String? acceso,
    bool? isFavorite,
  }) {
    return Compound(
      idPA: idPA ?? this.idPA,
      idFA: idFA ?? this.idFA,
      idAS1: idAS1 ?? this.idAS1,
      idAS2: idAS2 ?? this.idAS2,
      idAS3: idAS3 ?? this.idAS3,
      idAS4: idAS4 ?? this.idAS4,
      idAS5: idAS5 ?? this.idAS5,
      pa: pa ?? this.pa,
      familia: familia ?? this.familia,
      uso: uso ?? this.uso,
      posologia: posologia ?? this.posologia,
      consideraciones: consideraciones ?? this.consideraciones,
      mecanismo: mecanismo ?? this.mecanismo,
      marcas: marcas ?? this.marcas,
      genericos: genericos ?? this.genericos,
      efectos: efectos ?? this.efectos,
      contraindicaciones: contraindicaciones ?? this.contraindicaciones,
      acceso: acceso ?? this.acceso,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() =>
      'Compound(idPA: $idPA, pa: $pa, familia: $familia, acceso: $acceso)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Compound && other.idPA == idPA;

  @override
  int get hashCode => idPA.hashCode;
}
