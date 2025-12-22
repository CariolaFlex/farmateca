// lib/services/storage_service.dart

import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Seleccionar imagen desde galería
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Tomar foto con cámara
  Future<File?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  /// Subir imagen a Firebase Storage con mejor manejo de errores
  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      print('📤 Iniciando subida de imagen para userId: $userId');

      // Verificar que el archivo existe
      if (!await imageFile.exists()) {
        print('❌ El archivo no existe: ${imageFile.path}');
        return null;
      }

      // Verificar tamaño del archivo
      int fileSize = await imageFile.length();
      print('📊 Tamaño del archivo: ${fileSize / 1024} KB');

      if (fileSize > 5 * 1024 * 1024) {
        print('❌ Archivo muy grande: ${fileSize / (1024 * 1024)} MB');
        return null;
      }

      // Generar nombre único
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String extension = path.extension(imageFile.path);
      String fileName = 'profile_${userId}_$timestamp$extension';

      print('📝 Nombre del archivo: $fileName');

      // Referencia al storage
      Reference ref = _storage.ref().child('profile_images').child(fileName);

      print('🔗 Referencia creada: ${ref.fullPath}');

      // Configurar metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Subir archivo con timeout de 60 segundos
      print('⏳ Subiendo archivo...');

      UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // Escuchar progreso
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📈 Progreso: ${(progress * 100).toStringAsFixed(1)}%');
      });

      // Esperar a que termine con timeout
      TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏰ Timeout: La subida tardó más de 60 segundos');
          throw TimeoutException('Timeout al subir imagen');
        },
      );

      print('✅ Archivo subido exitosamente');

      // Obtener URL de descarga
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('🔗 URL de descarga obtenida: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('❌ Firebase Error: ${e.code}');
      print('❌ Mensaje: ${e.message}');
      print('❌ Stack: ${e.stackTrace}');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error general al subir imagen: $e');
      print('❌ Stack: $stackTrace');
      return null;
    }
  }

  /// Eliminar imagen anterior de Firebase Storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('🗑️ Imagen eliminada de Storage');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
