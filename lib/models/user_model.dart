import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String profesion; // Mantener por compatibilidad con datos existentes
  final String? nivel; // NUEVO: 'estudiante', 'interno', 'profesional'
  final String? area; // NUEVO: 'medicina', 'enfermeria', etc.
  final DateTime fechaRegistro;
  final DateTime ultimaSesion;
  final UserPreferences preferencias;
  final SubscriptionStatus suscripcion;
  final List<String> favoritosSincronizados;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.profesion,
    this.nivel,
    this.area,
    required this.fechaRegistro,
    required this.ultimaSesion,
    required this.preferencias,
    required this.suscripcion,
    this.favoritosSincronizados = const [],
  });

  bool get isPremium => suscripcion.isActive;

  /// Obtiene el nombre legible del nivel
  String get nivelDisplay {
    switch (nivel) {
      case 'estudiante':
        return 'Estudiante';
      case 'interno':
        return 'Interno(a)';
      case 'profesional':
        return 'Profesional';
      default:
        return 'No especificado';
    }
  }

  /// Obtiene el nombre legible del área
  String get areaDisplay {
    switch (area) {
      case 'enfermeria':
        return 'Enfermería';
      case 'kinesiologia':
        return 'Kinesiología';
      case 'medicina':
        return 'Medicina';
      case 'nutricion':
        return 'Nutrición';
      case 'obstetricia':
        return 'Obstetricia y puericultura';
      case 'quimica':
        return 'Química y farmacia';
      case 'tens':
        return 'TENS';
      case 'otra':
        return 'Otra';
      default:
        return '';
    }
  }

  /// Obtiene la profesión completa en formato legible
  String get profesionCompleta {
    if (nivel == null) return profesion.isNotEmpty ? profesion : 'No especificado';
    if (area == null) return nivelDisplay;
    return '$nivelDisplay de $areaDisplay';
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      profesion: data['profesion'] ?? '',
      nivel: data['nivel'],
      area: data['area'],
      fechaRegistro:
          (data['fecha_registro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimaSesion:
          (data['ultima_sesion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferencias: UserPreferences.fromMap(data['preferencias'] ?? {}),
      suscripcion: SubscriptionStatus.fromMap(data['suscripcion'] ?? {}),
      favoritosSincronizados: List<String>.from(
        data['favoritos_sincronizados'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'nombre': nombre,
      'profesion': profesion,
      'nivel': nivel,
      'area': area,
      'fecha_registro': Timestamp.fromDate(fechaRegistro),
      'ultima_sesion': Timestamp.fromDate(ultimaSesion),
      'preferencias': preferencias.toMap(),
      'suscripcion': suscripcion.toMap(),
      'favoritos_sincronizados': favoritosSincronizados,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nombre,
    String? profesion,
    String? nivel,
    String? area,
    DateTime? fechaRegistro,
    DateTime? ultimaSesion,
    UserPreferences? preferencias,
    SubscriptionStatus? suscripcion,
    List<String>? favoritosSincronizados,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      profesion: profesion ?? this.profesion,
      nivel: nivel ?? this.nivel,
      area: area ?? this.area,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimaSesion: ultimaSesion ?? this.ultimaSesion,
      preferencias: preferencias ?? this.preferencias,
      suscripcion: suscripcion ?? this.suscripcion,
      favoritosSincronizados:
          favoritosSincronizados ?? this.favoritosSincronizados,
    );
  }
}

class UserPreferences {
  final String tema;
  final bool notificaciones;

  UserPreferences({this.tema = 'light', this.notificaciones = true});

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      tema: map['tema'] ?? 'light',
      notificaciones: map['notificaciones'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'tema': tema, 'notificaciones': notificaciones};
  }
}

class SubscriptionStatus {
  final String plan; // 'free', 'monthly', 'yearly'
  final DateTime? fechaInicio;
  final DateTime? fechaTermino;
  final bool isActive;

  SubscriptionStatus({
    this.plan = 'free',
    this.fechaInicio,
    this.fechaTermino,
    this.isActive = false,
  });

  factory SubscriptionStatus.fromMap(Map<String, dynamic> map) {
    return SubscriptionStatus(
      plan: map['plan'] ?? 'free',
      fechaInicio: (map['fecha_inicio'] as Timestamp?)?.toDate(),
      fechaTermino: (map['fecha_termino'] as Timestamp?)?.toDate(),
      isActive: map['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'fecha_inicio': fechaInicio != null
          ? Timestamp.fromDate(fechaInicio!)
          : null,
      'fecha_termino': fechaTermino != null
          ? Timestamp.fromDate(fechaTermino!)
          : null,
      'is_active': isActive,
    };
  }
}
