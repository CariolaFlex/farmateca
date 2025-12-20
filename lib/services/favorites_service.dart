// lib/services/favorites_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_models.dart';
import 'database_helper.dart';

class FavoritesService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== COMPUESTOS ====================

  Future<void> addCompoundToFavorites({
    required String userId,
    required Compuesto compound,
  }) async {
    try {
      await _dbHelper.insertFavoriteCompound(
        userId: userId,
        compoundId: compound.idPa,
        compoundName: compound.pa,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoritos')
          .doc('compuestos_${compound.idPa}')
          .set({
        'tipo': 'compuesto',
        'id': compound.idPa,
        'nombre': compound.pa,
        'familia': compound.familia,
        'fechaAgregado': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al sincronizar favorito: $e');
    }
  }

  Future<void> removeCompoundFromFavorites({
    required String userId,
    required String compoundId,
  }) async {
    try {
      await _dbHelper.deleteFavoriteCompound(
        userId: userId,
        compoundId: compoundId,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoritos')
          .doc('compuestos_$compoundId')
          .delete();
    } catch (e) {
      print('Error al eliminar favorito: $e');
    }
  }

  Future<bool> isCompoundFavorite({
    required String userId,
    required String compoundId,
  }) async {
    return await _dbHelper.isCompoundFavorite(
      userId: userId,
      compoundId: compoundId,
    );
  }

  Future<List<Compuesto>> getFavoriteCompounds(String userId) async {
    return await _dbHelper.getFavoriteCompounds(userId);
  }

  // ==================== MARCAS ====================

  Future<void> addBrandToFavorites({
    required String userId,
    required Marca brand,
  }) async {
    try {
      await _dbHelper.insertFavoriteBrand(
        userId: userId,
        brandId: brand.idMa,
        brandName: brand.ma,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoritos')
          .doc('marcas_${brand.idMa}')
          .set({
        'tipo': 'marca',
        'id': brand.idMa,
        'nombre': brand.ma,
        'laboratorio': brand.labM,
        'fechaAgregado': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al sincronizar favorito de marca: $e');
    }
  }

  Future<void> removeBrandFromFavorites({
    required String userId,
    required String brandId,
  }) async {
    try {
      await _dbHelper.deleteFavoriteBrand(
        userId: userId,
        brandId: brandId,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoritos')
          .doc('marcas_$brandId')
          .delete();
    } catch (e) {
      print('Error al eliminar favorito de marca: $e');
    }
  }

  Future<bool> isBrandFavorite({
    required String userId,
    required String brandId,
  }) async {
    return await _dbHelper.isBrandFavorite(
      userId: userId,
      brandId: brandId,
    );
  }

  Future<List<Marca>> getFavoriteBrands(String userId) async {
    return await _dbHelper.getFavoriteBrands(userId);
  }
}
