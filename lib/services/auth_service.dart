import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // ==========================================
  // REGISTRO CON EMAIL
  // ==========================================
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String profesion,
    String? nivel,
    String? area,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Crear documento del usuario en Firestore
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          nombre: nombre,
          profesion: profesion,
          nivel: nivel,
          area: area,
          fechaRegistro: DateTime.now(),
          ultimaSesion: DateTime.now(),
          preferencias: UserPreferences(),
          suscripcion: SubscriptionStatus(), // Plan free por defecto
          favoritosSincronizados: [],
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());

        return AuthResult.success(userModel);
      }

      return AuthResult.error('Error al crear la cuenta');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Error inesperado: $e');
    }
  }

  // ==========================================
  // LOGIN CON EMAIL
  // ==========================================
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Actualizar última sesión
        await _firestore.collection('users').doc(credential.user!.uid).update({
          'ultima_sesion': Timestamp.fromDate(DateTime.now()),
        });

        // Guardar email si "recordarme" está activo
        if (rememberMe) {
          await _saveLastEmail(email);
        }

        final userModel = await getCurrentUserData();
        return AuthResult.success(userModel);
      }

      return AuthResult.error('Error al iniciar sesión');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Error inesperado: $e');
    }
  }

  // ==========================================
  // RECUPERAR CONTRASEÑA
  // ==========================================
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Error inesperado: $e');
    }
  }

  // ==========================================
  // CERRAR SESIÓN
  // ==========================================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==========================================
  // OBTENER DATOS DEL USUARIO ACTUAL
  // ==========================================
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
      return null;
    }
  }

  // ==========================================
  // ACTUALIZAR PERFIL
  // ==========================================
  Future<bool> updateUserProfile({String? nombre, String? profesion}) async {
    try {
      if (currentUser == null) return false;

      final updates = <String, dynamic>{};
      if (nombre != null) updates['nombre'] = nombre;
      if (profesion != null) updates['profesion'] = profesion;

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update(updates);
      }

      return true;
    } catch (e) {
      print('Error actualizando perfil: $e');
      return false;
    }
  }

  // ==========================================
  // ACTUALIZAR SUSCRIPCIÓN
  // ==========================================
  Future<bool> updateSubscription(SubscriptionStatus subscription) async {
    try {
      if (currentUser == null) return false;

      await _firestore.collection('users').doc(currentUser!.uid).update({
        'suscripcion': subscription.toMap(),
      });

      return true;
    } catch (e) {
      print('Error actualizando suscripción: $e');
      return false;
    }
  }

  // ==========================================
  // HELPERS
  // ==========================================

  Future<void> _saveLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.lastEmail, email);
  }

  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefsKeys.lastEmail);
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación: $code';
    }
  }
}

// ==========================================
// CLASE RESULTADO DE AUTENTICACIÓN
// ==========================================
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(UserModel? user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}
