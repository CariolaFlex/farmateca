// ============================================================
// === MODELOS DE DATOS - FARMATECA ===
// ============================================================

class Compuesto {
  final int? id;
  final String idPa;
  final String pa; // Principio Activo (nombre)
  final String familia;
  final String uso;
  final String posologia;
  final String consideraciones;
  final String mecanismo;
  final String marcas; // Lista de marcas como texto
  final String genericos; // Lista de genéricos como texto
  final String efectos;
  final String contraindicaciones;
  final String idFa; // ID Familia
  final String idAs1; // IDs asociados
  final String idAs2;
  final String idAs3;
  final String idAs4;
  final String idAs5;
  final String acceso; // "F" = Free, "P" = Premium

  Compuesto({
    this.id,
    required this.idPa,
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
    required this.idFa,
    this.idAs1 = '',
    this.idAs2 = '',
    this.idAs3 = '',
    this.idAs4 = '',
    this.idAs5 = '',
    required this.acceso,
  });

  // Verificar si es contenido gratuito
  bool get isFree => acceso == 'F';
  bool get isPremium => acceso == 'P';

  factory Compuesto.fromMap(Map<String, dynamic> map) {
    return Compuesto(
      id: map['id'],
      idPa: map['id_pa'] ?? '',
      pa: map['pa'] ?? '',
      familia: map['familia'] ?? '',
      uso: map['uso'] ?? '',
      posologia: map['posologia'] ?? '',
      consideraciones: map['consideraciones'] ?? '',
      mecanismo: map['mecanismo'] ?? '',
      marcas: map['marcas'] ?? '',
      genericos: map['genericos'] ?? '',
      efectos: map['efectos'] ?? '',
      contraindicaciones: map['contraindicaciones'] ?? '',
      idFa: map['id_fa'] ?? '',
      idAs1: map['id_as1'] ?? '',
      idAs2: map['id_as2'] ?? '',
      idAs3: map['id_as3'] ?? '',
      idAs4: map['id_as4'] ?? '',
      idAs5: map['id_as5'] ?? '',
      acceso: map['acceso'] ?? 'P',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_pa': idPa,
      'pa': pa,
      'familia': familia,
      'uso': uso,
      'posologia': posologia,
      'consideraciones': consideraciones,
      'mecanismo': mecanismo,
      'marcas': marcas,
      'genericos': genericos,
      'efectos': efectos,
      'contraindicaciones': contraindicaciones,
      'id_fa': idFa,
      'id_as1': idAs1,
      'id_as2': idAs2,
      'id_as3': idAs3,
      'id_as4': idAs4,
      'id_as5': idAs5,
      'acceso': acceso,
    };
  }
}

class Marca {
  final int? id;
  final String idMa;
  final String idPam; // ID del compuesto asociado
  final String ma; // Nombre de la marca
  final String paM; // Principio activo
  final String tlM; // Tipo y Laboratorio
  final String familiaM;
  final String usoM;
  final String presentacionM;
  final String contraindicacionesM;
  final String viaM;
  final String tipoM; // Genérico o Marca comercial
  final String labM; // Laboratorio
  final String idLabm;
  final String idFam;
  final String accesoM; // "F" = Free, "P" = Premium

  Marca({
    this.id,
    required this.idMa,
    required this.idPam,
    required this.ma,
    required this.paM,
    required this.tlM,
    required this.familiaM,
    required this.usoM,
    required this.presentacionM,
    required this.contraindicacionesM,
    required this.viaM,
    required this.tipoM,
    required this.labM,
    required this.idLabm,
    required this.idFam,
    required this.accesoM,
  });

  // Verificar si es contenido gratuito
  bool get isFree => accesoM == 'F';
  bool get isPremium => accesoM == 'P';
  bool get isGenerico => tipoM == 'Genérico';

  factory Marca.fromMap(Map<String, dynamic> map) {
    return Marca(
      id: map['id'],
      idMa: map['id_ma'] ?? '',
      idPam: map['id_pam'] ?? '',
      ma: map['ma'] ?? '',
      paM: map['pa_m'] ?? '',
      tlM: map['tl_m'] ?? '',
      familiaM: map['familia_m'] ?? '',
      usoM: map['uso_m'] ?? '',
      presentacionM: map['presentacion_m'] ?? '',
      contraindicacionesM: map['contraindicaciones_m'] ?? '',
      viaM: map['via_m'] ?? '',
      tipoM: map['tipo_m'] ?? '',
      labM: map['lab_m'] ?? '',
      idLabm: map['id_labm'] ?? '',
      idFam: map['id_fam'] ?? '',
      accesoM: map['acceso_m'] ?? 'P',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_ma': idMa,
      'id_pam': idPam,
      'ma': ma,
      'pa_m': paM,
      'tl_m': tlM,
      'familia_m': familiaM,
      'uso_m': usoM,
      'presentacion_m': presentacionM,
      'contraindicaciones_m': contraindicacionesM,
      'via_m': viaM,
      'tipo_m': tipoM,
      'lab_m': labM,
      'id_labm': idLabm,
      'id_fam': idFam,
      'acceso_m': accesoM,
    };
  }
}
