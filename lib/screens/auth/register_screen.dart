import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../home_screen.dart';
import 'terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Nuevo sistema de profesión en 2 pasos
  String? _selectedNivel; // 'estudiante', 'interno', 'profesional'
  String? _selectedArea; // 'medicina', 'enfermeria', etc.
  bool _skipProfession = false;

  bool _acceptedTerms = false;
  double _passwordStrength = 0.0;

  // Opciones de nivel
  final List<Map<String, String>> _niveles = [
    {'value': 'estudiante', 'label': 'Estudiante'},
    {'value': 'interno', 'label': 'Interno(a)'},
    {'value': 'profesional', 'label': 'Profesional'},
  ];

  // Opciones de área (ordenadas alfabéticamente)
  final List<Map<String, String>> _areas = [
    {'value': 'enfermeria', 'label': 'Enfermería'},
    {'value': 'kinesiologia', 'label': 'Kinesiología'},
    {'value': 'medicina', 'label': 'Medicina'},
    {'value': 'nutricion', 'label': 'Nutrición'},
    {'value': 'obstetricia', 'label': 'Obstetricia y puericultura'},
    {'value': 'quimica', 'label': 'Química y farmacia'},
    {'value': 'tens', 'label': 'TENS'},
    {'value': 'otra', 'label': 'Otra'},
  ];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(
      () => setState(
        () => _passwordStrength = Validators.calculatePasswordStrength(
          _passwordController.text,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _buildProfesionString() {
    if (_skipProfession || _selectedNivel == null) return null;
    if (_selectedArea == null) return _selectedNivel;
    return '${_selectedNivel}_$_selectedArea';
  }

  Future<void> _handleRegister() async {
    if (!_acceptedTerms) {
      CustomSnackbar.showError(
        context,
        'Debes aceptar los términos y condiciones',
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    // Construir string de profesión o null si se omitió
    final profesion = _buildProfesionString() ?? 'no_especificado';

    final success = await authProvider.register(
      email: Validators.sanitizeEmail(_emailController.text),
      password: _passwordController.text,
      nombre: Validators.sanitizeName(_nameController.text),
      profesion: profesion,
      nivel: _selectedNivel,
      area: _selectedArea,
    );

    if (mounted) {
      if (success) {
        CustomSnackbar.showSuccess(context, '¡Cuenta creada exitosamente!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        CustomSnackbar.showError(
          context,
          authProvider.errorMessage ?? 'Error al crear cuenta',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LoadingOverlay(
        isLoading: authProvider.isLoading,
        message: 'Creando cuenta...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInDown(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa tus datos para registrarte',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Nombre completo',
                          hint: 'Ej: Juan Pérez',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          validator: Validators.validateName,
                        ),
                        const SizedBox(height: 16),
                        EmailTextField(controller: _emailController),
                        const SizedBox(height: 16),
                        PasswordTextField(
                          controller: _passwordController,
                          textInputAction: TextInputAction.next,
                        ),
                        if (_passwordController.text.isNotEmpty)
                          PasswordStrengthIndicator(
                            strength: _passwordStrength,
                          ),
                        const SizedBox(height: 16),
                        PasswordTextField(
                          label: 'Confirmar contraseña',
                          hint: 'Repite tu contraseña',
                          controller: _confirmPasswordController,
                          validator: (v) => Validators.validateConfirmPassword(
                            v,
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nuevo selector de profesión en 2 pasos
                        _buildProfessionSelector(isDark),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeIn(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (v) =>
                              setState(() => _acceptedTerms = v ?? false),
                          activeColor: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _acceptedTerms = !_acceptedTerms),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: 'Acepto los '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const TermsScreen(
                                            showAcceptButton: true,
                                          ),
                                        ),
                                      );
                                      if (result == true && mounted) {
                                        setState(() => _acceptedTerms = true);
                                      }
                                    },
                                    child: const Text(
                                      'Términos y Condiciones',
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: PrimaryButton(
                    text: 'Crear Cuenta',
                    onPressed: _handleRegister,
                    isEnabled: _acceptedTerms,
                  ),
                ),
                const SizedBox(height: 24),
                FadeIn(
                  delay: const Duration(milliseconds: 600),
                  child: Center(
                    child: TextLinkButton(
                      text: '¿Ya tienes cuenta?',
                      boldText: 'Inicia sesión',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget para selección de profesión en 2 pasos
  Widget _buildProfessionSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y botón "Agregar después"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Profesión',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Opcional',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _skipProfession = !_skipProfession;
                    if (_skipProfession) {
                      _selectedNivel = null;
                      _selectedArea = null;
                    }
                  });
                },
                child: Text(
                  _skipProfession ? 'Agregar' : 'Omitir',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (!_skipProfession) ...[
            const SizedBox(height: 16),

            // Paso 1: Nivel
            DropdownButtonFormField<String>(
              value: _selectedNivel,
              decoration: InputDecoration(
                labelText: 'Selecciona tu nivel',
                labelStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
                filled: true,
                fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.school_outlined,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              dropdownColor: isDark ? AppColors.cardDark : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              items: _niveles
                  .map((n) => DropdownMenuItem(
                        value: n['value'],
                        child: Text(n['label']!),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNivel = value;
                  _selectedArea = null; // Reset área al cambiar nivel
                });
              },
            ),

            // Paso 2: Área (solo si nivel está seleccionado)
            if (_selectedNivel != null) ...[
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: DropdownButtonFormField<String>(
                  value: _selectedArea,
                  decoration: InputDecoration(
                    labelText: 'Selecciona tu área',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.medical_services_outlined,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  items: _areas
                      .map((a) => DropdownMenuItem(
                            value: a['value'],
                            child: Text(a['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedArea = value;
                    });
                  },
                ),
              ),
            ],

            // Mostrar selección actual
            if (_selectedNivel != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryBlue.withAlpha(77),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedArea != null
                            ? '${_niveles.firstWhere((n) => n['value'] == _selectedNivel)['label']} de ${_areas.firstWhere((a) => a['value'] == _selectedArea)['label']}'
                            : _niveles.firstWhere(
                                (n) => n['value'] == _selectedNivel)['label']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            // Mensaje cuando se omite
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Podrás agregar tu profesión después en tu perfil',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
