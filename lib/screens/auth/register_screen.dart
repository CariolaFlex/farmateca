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
  String? _selectedProfession;
  bool _acceptedTerms = false;
  double _passwordStrength = 0.0;

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
    final success = await authProvider.register(
      email: Validators.sanitizeEmail(_emailController.text),
      password: _passwordController.text,
      nombre: Validators.sanitizeName(_nameController.text),
      profesion: _selectedProfession!,
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
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
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
                      const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                        const SizedBox(height: 16),
                        ProfessionDropdown(
                          value: _selectedProfession,
                          onChanged: (v) =>
                              setState(() => _selectedProfession = v),
                        ),
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
                                          builder: (_) => const TermsScreen(),
                                        ),
                                      );
                                      if (result == true && mounted)
                                        setState(() => _acceptedTerms = true);
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
}
