import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String profesion; // Mantener por compatibilidad con datos existentes
  final String? nivel; // NUEVO: 'estudiante', 'interno', 'profesional'
  final String? area; // NUEVO: 'medicina', 'enfermeria', etc.
  final String? alias; // Apodo del usuario
  final String? photoURL; // URL de la foto de perfil
  final DateTime fechaRegistro;
  final DateTime ultimaSesion;
  final UserPreferences preferencias;
  final SubscriptionStatus suscripcion;
  final List<String> favoritosSincronizados;

  // === TRIAL DE 7 DÍAS ===
  final DateTime? trialStartDate; // Fecha de inicio del trial
  final DateTime? trialEndDate; // Fecha de fin del trial
  final bool hasUsedTrial; // Si ya usó el trial (solo 1 vez por usuario)

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.profesion,
    this.nivel,
    this.area,
    this.alias,
    this.photoURL,
    required this.fechaRegistro,
    required this.ultimaSesion,
    required this.preferencias,
    required this.suscripcion,
    this.favoritosSincronizados = const [],
    this.trialStartDate,
    this.trialEndDate,
    this.hasUsedTrial = false,
  });

  /// Verifica si el usuario tiene suscripción premium activa
  bool get isPremium => suscripcion.isActive;

  /// Verifica si el trial está activo (dentro del período de 7 días)
  bool get isTrialActive {
    if (trialStartDate == null || trialEndDate == null) return false;
    if (!hasUsedTrial) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  /// Días restantes del trial (0 si expirado o no activo)
  int get trialDaysRemaining {
    if (!isTrialActive) return 0;
    final remaining = trialEndDate!.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining + 1; // +1 porque el día actual cuenta
  }

  /// Indica si el trial está por expirar (≤2 días restantes)
  bool get isTrialExpiring {
    return isTrialActive && trialDaysRemaining <= 2;
  }

  /// Indica si el trial ya expiró (usó trial pero ya pasó la fecha)
  bool get isTrialExpired {
    if (!hasUsedTrial) return false;
    if (trialEndDate == null) return false;
    return DateTime.now().isAfter(trialEndDate!);
  }

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
    if (nivel == null)
      return profesion.isNotEmpty ? profesion : 'No especificado';
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
      alias: data['alias'],
      photoURL: data['photoURL'],
      fechaRegistro:
          (data['fecha_registro'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimaSesion:
          (data['ultima_sesion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferencias: UserPreferences.fromMap(data['preferencias'] ?? {}),
      suscripcion: SubscriptionStatus.fromMap(data['suscripcion'] ?? {}),
      favoritosSincronizados: List<String>.from(
        data['favoritos_sincronizados'] ?? [],
      ),
      // Trial fields
      trialStartDate: (data['trial_start_date'] as Timestamp?)?.toDate(),
      trialEndDate: (data['trial_end_date'] as Timestamp?)?.toDate(),
      hasUsedTrial: data['has_used_trial'] ?? false,
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
      'alias': alias,
      'photoURL': photoURL,
      'fecha_registro': Timestamp.fromDate(fechaRegistro),
      'ultima_sesion': Timestamp.fromDate(ultimaSesion),
      'preferencias': preferencias.toMap(),
      'suscripcion': suscripcion.toMap(),
      'favoritos_sincronizados': favoritosSincronizados,
      // Trial fields
      'trial_start_date': trialStartDate != null
          ? Timestamp.fromDate(trialStartDate!)
          : null,
      'trial_end_date': trialEndDate != null
          ? Timestamp.fromDate(trialEndDate!)
          : null,
      'has_used_trial': hasUsedTrial,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nombre,
    String? profesion,
    String? nivel,
    String? area,
    String? alias,
    String? photoURL,
    DateTime? fechaRegistro,
    DateTime? ultimaSesion,
    UserPreferences? preferencias,
    SubscriptionStatus? suscripcion,
    List<String>? favoritosSincronizados,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    bool? hasUsedTrial,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      profesion: profesion ?? this.profesion,
      nivel: nivel ?? this.nivel,
      area: area ?? this.area,
      alias: alias ?? this.alias,
      photoURL: photoURL ?? this.photoURL,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimaSesion: ultimaSesion ?? this.ultimaSesion,
      preferencias: preferencias ?? this.preferencias,
      suscripcion: suscripcion ?? this.suscripcion,
      favoritosSincronizados:
          favoritosSincronizados ?? this.favoritosSincronizados,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      hasUsedTrial: hasUsedTrial ?? this.hasUsedTrial,
    );
  }

  /// Nombre para mostrar en la UI.
  /// Prioridad: 1) alias (si existe y no está vacío), 2) nombre, 3) 'Usuario' como fallback
  String get displayName {
    // Primero verificar alias
    if (alias != null && alias!.trim().isNotEmpty) {
      return alias!.trim();
    }
    // Luego verificar nombre
    if (nombre.trim().isNotEmpty) {
      return nombre.trim();
    }
    // Fallback para UI (no se guarda en Firestore)
    return 'Usuario';
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
