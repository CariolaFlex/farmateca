// lib/models/brand_model.dart

/// Modelo para representar una Marca Comercial o Genérico
/// Mapea la estructura EXACTA del JSON farmateca_master.json
///
/// IMPORTANTE: Los nombres de campos usan EXACTAMENTE los mismos
/// nombres del JSON (TODOS con guiones bajos en marcas)
class Brand {
  // --- IDENTIFICADORES (TODOS CON GUIÓN BAJO) ---
  final String idMA; // ID_MA - ID único de marca (ej: "MA-000001")
  final String idPAM; // ID_PAM - ID del principio activo (FK a Compound.idPA)
  final String idLABM; // ID_LABM - ID del laboratorio
  final String idFAM; // ID_FAM - ID de familia farmacológica

  // --- INFORMACIÓN PRINCIPAL ---
  final String ma; // MA - Nombre de la marca
  final String paM; // PA_M - Principio Activo (CON GUIÓN BAJO)
  final String labM; // Lab_M - Laboratorio (CON GUIÓN BAJO)

  // --- CLASIFICACIÓN (TODOS CON GUIÓN BAJO) ---
  final String familiaM; // Familia_M - Familia Farmacológica
  final String tlM; // TL_M - Tipo y Laboratorio combinado
  final String tipoM; // Tipo_M - "Marca comercial" o "Genérico"

  // --- DESCRIPCIÓN CLÍNICA (TODOS CON GUIÓN BAJO) ---
  final String usoM; // Uso_M - Uso Clínico
  final String presentacionM; // Presentacion_M - Forma farmacéutica
  final String viaM; // Via_M - Vía de administración

  // --- SEGURIDAD ---
  final String contraindicacionesM; // Contraindicaciones_M

  // --- CONTROL DE ACCESO ---
  final String accesoM; // Acceso_M - 'F' = Free, 'P' = Premium

  // --- METADATA LOCAL ---
  bool isFavorite; // No está en JSON

  /// Constructor principal
  Brand({
    required this.idMA,
    required this.idPAM,
    required this.idLABM,
    required this.idFAM,
    required this.ma,
    required this.paM,
    required this.labM,
    required this.familiaM,
    required this.tlM,
    required this.tipoM,
    required this.usoM,
    required this.presentacionM,
    required this.viaM,
    required this.contraindicacionesM,
    required this.accesoM,
    this.isFavorite = false,
  });

  // ========================================
  // FACTORY: Crear desde JSON
  // ========================================

  /// Crea Brand desde un mapa JSON
  /// USA LOS NOMBRES EXACTOS DEL JSON (TODOS con guiones bajos)
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      idMA: json['ID_MA'] as String? ?? '',
      idPAM: json['ID_PAM'] as String? ?? '', // ← CLAVE DE RELACIÓN
      idLABM: json['ID_LABM'] as String? ?? '',
      idFAM: json['ID_FAM'] as String? ?? '',
      ma: json['MA'] as String? ?? 'Sin nombre',
      paM: json['PA_M'] as String? ?? 'Sin PA',
      labM: json['Lab_M'] as String? ?? 'Sin laboratorio',
      familiaM: json['Familia_M'] as String? ?? 'Sin familia',
      tlM: json['TL_M'] as String? ?? '',
      tipoM: json['Tipo_M'] as String? ?? '',
      usoM: json['Uso_M'] as String? ?? 'No especificado',
      presentacionM: json['Presentacion_M'] as String? ?? 'No especificado',
      viaM: json['Via_M'] as String? ?? 'No especificado',
      contraindicacionesM: json['Contraindicaciones_M'] as String? ?? '',
      accesoM: json['Acceso_M'] as String? ?? 'F',
      isFavorite: false,
    );
  }

  // ========================================
  // MÉTODOS DE CONVERSIÓN SQLite
  // ========================================

  /// Convierte a Map para SQLite (snake_case)
  Map<String, dynamic> toMap() {
    return {
      'id_ma': idMA,
      'id_pam': idPAM,
      'id_labm': idLABM,
      'id_fam': idFAM,
      'ma': ma,
      'pa_m': paM,
      'lab_m': labM,
      'familia_m': familiaM,
      'tl_m': tlM,
      'tipo_m': tipoM,
      'uso_m': usoM,
      'presentacion_m': presentacionM,
      'via_m': viaM,
      'contraindicaciones_m': contraindicacionesM,
      'acceso_m': accesoM,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  /// Crea Brand desde Map de SQLite
  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      idMA: map['id_ma'] as String,
      idPAM: map['id_pam'] as String,
      idLABM: map['id_labm'] as String,
      idFAM: map['id_fam'] as String,
      ma: map['ma'] as String,
      paM: map['pa_m'] as String,
      labM: map['lab_m'] as String,
      familiaM: map['familia_m'] as String,
      tlM: map['tl_m'] as String,
      tipoM: map['tipo_m'] as String,
      usoM: map['uso_m'] as String,
      presentacionM: map['presentacion_m'] as String,
      viaM: map['via_m'] as String,
      contraindicacionesM: map['contraindicaciones_m'] as String,
      accesoM: map['acceso_m'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }

  // ========================================
  // GETTERS DE NEGOCIO
  // ========================================

  bool get isGratuito => accesoM == 'F';
  bool get isPremium => accesoM == 'P';
  bool get esMarcaComercial => tipoM == 'Marca comercial';
  bool get esGenerico => tipoM == 'Genérico';
  bool get tieneContraindicaciones => contraindicacionesM.isNotEmpty;
  bool get tieneVia => viaM.isNotEmpty && viaM != 'No especificado';

  /// Descripción completa: "Marca - PA - Lab"
  String get descripcionCompleta => '$ma - $paM - $labM';

  /// Descripción corta: "Marca (Lab)"
  String get descripcionCorta => '$ma ($labM)';

  // ========================================
  // UTILIDADES
  // ========================================

  Brand copyWith({
    String? idMA,
    String? idPAM,
    String? idLABM,
    String? idFAM,
    String? ma,
    String? paM,
    String? labM,
    String? familiaM,
    String? tlM,
    String? tipoM,
    String? usoM,
    String? presentacionM,
    String? viaM,
    String? contraindicacionesM,
    String? accesoM,
    bool? isFavorite,
  }) {
    return Brand(
      idMA: idMA ?? this.idMA,
      idPAM: idPAM ?? this.idPAM,
      idLABM: idLABM ?? this.idLABM,
      idFAM: idFAM ?? this.idFAM,
      ma: ma ?? this.ma,
      paM: paM ?? this.paM,
      labM: labM ?? this.labM,
      familiaM: familiaM ?? this.familiaM,
      tlM: tlM ?? this.tlM,
      tipoM: tipoM ?? this.tipoM,
      usoM: usoM ?? this.usoM,
      presentacionM: presentacionM ?? this.presentacionM,
      viaM: viaM ?? this.viaM,
      contraindicacionesM: contraindicacionesM ?? this.contraindicacionesM,
      accesoM: accesoM ?? this.accesoM,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() => 'Brand(idMA: $idMA, ma: $ma, paM: $paM, labM: $labM)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Brand && other.idMA == idMA;

  @override
  int get hashCode => idMA.hashCode;
}
