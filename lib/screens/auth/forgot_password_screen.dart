import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
    final success = await authProvider.resetPassword(
      Validators.sanitizeEmail(_emailController.text),
    );
    if (mounted) {
      if (success) {
        setState(() => _emailSent = true);
      } else {
        CustomSnackbar.showError(
          context,
          authProvider.errorMessage ?? 'Error al enviar correo',
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
        message: 'Enviando instrucciones...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _emailSent ? _buildSuccessContent() : _buildFormContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        const SizedBox(height: 40),
        FadeInDown(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 50,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 32),
        FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: const Text(
            'Recuperar Contraseña',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        FadeInDown(
          delay: const Duration(milliseconds: 300),
          child: Text(
            'Ingresa tu correo y te enviaremos instrucciones para restablecer tu contraseña.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        FadeInUp(
          delay: const Duration(milliseconds: 400),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                EmailTextField(controller: _emailController, autofocus: true),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Enviar Instrucciones',
                  icon: Icons.email_outlined,
                  onPressed: _handleSendEmail,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeIn(
          delay: const Duration(milliseconds: 500),
          child: TextLinkButton(
            text: 'Volver al inicio de sesión',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const SizedBox(height: 40),
        FadeInDown(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: ZoomIn(
              delay: const Duration(milliseconds: 300),
              child: const Icon(
                Icons.check_circle,
                size: 70,
                color: AppColors.successGreen,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        FadeInDown(
          delay: const Duration(milliseconds: 400),
          child: const Text(
            '¡Revisa tu correo!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.successGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        FadeInDown(
          delay: const Duration(milliseconds: 500),
          child: Text(
            'Te enviamos instrucciones para restablecer tu contraseña.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        FadeIn(
          delay: const Duration(milliseconds: 600),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  _emailController.text,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        FadeInUp(
          delay: const Duration(milliseconds: 700),
          child: PrimaryButton(
            text: 'Volver al inicio de sesión',
            icon: Icons.login,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: 20),
        FadeIn(
          delay: const Duration(milliseconds: 800),
          child: Text(
            '¿No recibiste el correo? Revisa tu carpeta de spam',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
