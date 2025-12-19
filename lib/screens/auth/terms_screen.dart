import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TÉRMINOS Y CONDICIONES DE USO',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Última actualización: Diciembre 2025',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    '1. ACEPTACIÓN DE TÉRMINOS',
                    'Al descargar, instalar o utilizar la aplicación ${AppConstants.appName}, usted acepta estar sujeto a estos Términos y Condiciones. Si no está de acuerdo con alguno de estos términos, no debe usar la aplicación.',
                  ),
                  _buildSection(
                    '2. PROPÓSITO DE LA APLICACIÓN',
                    '${AppConstants.appName} es una herramienta de consulta farmacológica diseñada exclusivamente para profesionales y estudiantes de la salud en Chile. La información proporcionada tiene fines orientativos y educativos.',
                  ),
                  _buildSection(
                    '3. ADVERTENCIA MÉDICA IMPORTANTE',
                    'La información contenida en esta aplicación NO sustituye el juicio clínico profesional ni la consulta de fuentes primarias. Los usuarios deben buscar el consejo de un médico además de usar esta aplicación y antes de tomar cualquier decisión médica.',
                  ),
                  _buildSection(
                    '4. EXACTITUD DE LA INFORMACIÓN',
                    'Aunque el equipo de ${AppConstants.appNameFull} realiza esfuerzos razonables para mantener la base de datos actualizada y alineada con los registros oficiales, la farmacología es una ciencia en constante cambio. No garantizamos que la información esté libre de errores.',
                  ),
                  _buildSection(
                    '5. LIMITACIÓN DE RESPONSABILIDAD',
                    '${AppConstants.appNameFull}, sus desarrolladores, socios y afiliados se eximen expresamente de toda responsabilidad por cualquier daño directo, indirecto, incidental, especial o consecuente derivado del uso de la aplicación.',
                  ),
                  _buildSection(
                    '6. ORIGEN DE LOS DATOS',
                    'La información proviene de fuentes reconocidas como: Registro oficial del Instituto de Salud Pública de Chile (ISP), Guías Clínicas del Ministerio de Salud (MINSAL), y literatura internacional.',
                  ),
                  _buildSection(
                    '7. PROPIEDAD INTELECTUAL',
                    'Todo el contenido de la aplicación, incluyendo diseño, código, textos y estructura de datos, es propiedad de ${AppConstants.companyNameFull} y está protegido por las leyes de propiedad intelectual.',
                  ),
                  _buildSection(
                    '8. PRIVACIDAD',
                    'Respetamos su privacidad. Los datos personales recopilados se utilizan únicamente para mejorar la experiencia del usuario y no se comparten con terceros sin su consentimiento.',
                  ),
                  _buildSection(
                    '9. MODIFICACIONES',
                    'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios serán notificados a través de la aplicación.',
                  ),
                  _buildSection(
                    '10. CONTACTO',
                    'Para consultas sobre estos términos, puede contactarnos en: ${AppConstants.supportEmail}',
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.alertRed.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.alertRed,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'IMPORTANTE: Esta aplicación no debe ser utilizada por pacientes o público general para la automedicación. Cualquier decisión de salud debe ser supervisada por un profesional calificado.',
                            style: TextStyle(
                              color: AppColors.alertRed,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: PrimaryButton(
              text: 'Aceptar Términos',
              icon: Icons.check_circle_outline,
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
