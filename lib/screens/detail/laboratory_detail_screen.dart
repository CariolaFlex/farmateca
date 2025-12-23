// lib/screens/detail/laboratory_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/medication_models.dart';
import '../../utils/app_colors.dart';
import '../../services/database_helper.dart';
import '../home_screen.dart';
import 'brand_detail_screen.dart';
import 'compound_detail_screen.dart';

class LaboratoryDetailScreen extends StatefulWidget {
  final String laboratoryName;
  final List<Marca> brands;

  const LaboratoryDetailScreen({
    super.key,
    required this.laboratoryName,
    required this.brands,
  });

  @override
  State<LaboratoryDetailScreen> createState() => _LaboratoryDetailScreenState();
}

class _LaboratoryDetailScreenState extends State<LaboratoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Separar comerciales y genéricos
    final comerciales = widget.brands
        .where((b) =>
            b.tipoM.toLowerCase() == 'marca comercial' ||
            b.tipoM.toLowerCase() == 'comercial')
        .toList();
    final genericos = widget.brands
        .where((b) =>
            b.tipoM.toLowerCase() == 'genérico' ||
            b.tipoM.toLowerCase() == 'generico')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.laboratoryName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.brands.length} marca${widget.brands.length != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          // Botón Home
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            tooltip: 'Inicio',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del laboratorio
          _buildInfoCard(),

          const SizedBox(height: 20),

          // Marcas Comerciales
          if (comerciales.isNotEmpty) ...[
            _buildSectionTitle('Marcas Comerciales', comerciales.length),
            const SizedBox(height: 12),
            ...comerciales.map((brand) => _buildBrandButton(brand)),
            const SizedBox(height: 20),
          ],

          // Genéricos
          if (genericos.isNotEmpty) ...[
            _buildSectionTitle('Genéricos', genericos.length),
            const SizedBox(height: 12),
            ...genericos.map((brand) => _buildBrandButton(brand)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.laboratoryName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Laboratorio Farmacéutico',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandButton(Marca brand) {
    // Detectar si está próximamente
    final isComingSoon = brand.usoM.isEmpty || brand.presentacionM.isEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isComingSoon ? 1 : 2,
      color: isComingSoon ? Colors.grey.shade200 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // NUEVO: Abrir ficha de marca, NO navegar directo al compuesto
        onTap: () {
          if (isComingSoon) {
            _showComingSoonDialog(brand.ma);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BrandDetailScreen(marca: brand),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isComingSoon
                      ? Colors.grey.shade300
                      : AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.medication,
                  color: isComingSoon ? Colors.grey.shade600 : AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.ma,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isComingSoon
                            ? Colors.grey.shade700
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // NUEVO: Principio Activo como botón clickeable
                    GestureDetector(
                      onTap: isComingSoon ? null : () async {
                        // Navegar al compuesto
                        final dbHelper = DatabaseHelper();
                        final compound = await dbHelper.getCompuestoById(brand.idPam);
                        if (compound != null && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompoundDetailScreen(compuesto: compound),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              brand.paM,
                              style: TextStyle(
                                fontSize: 13,
                                color: isComingSoon
                                    ? Colors.grey.shade600
                                    : AppColors.primaryMedium,
                                fontWeight: FontWeight.w500,
                                decoration: isComingSoon ? null : TextDecoration.underline,
                                decorationColor: AppColors.primaryMedium,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isComingSoon) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: AppColors.primaryMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (brand.viaM.isNotEmpty && !isComingSoon) ...[
                      const SizedBox(height: 2),
                      Text(
                        brand.viaM,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (isComingSoon) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.comingSoonGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRÓXIMAMENTE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Flecha para ver ficha de marca
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isComingSoon ? Colors.grey.shade400 : AppColors.primaryMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String medicationName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryDark, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        content: Text(
          'El medicamento "$medicationName" estará disponible pronto con toda su información farmacológica.',
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
