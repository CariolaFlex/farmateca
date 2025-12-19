import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/validators.dart';
import '../config/app_config.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool showToggleVisibility;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.showToggleVisibility = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffix,
    this.autofocus = false,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                    size: 22,
                  )
                : null,
            suffixIcon: widget.showToggleVisibility
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : widget.suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryMedium,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: const BorderSide(
                color: AppColors.alertRed,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}

class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final bool autofocus;

  const EmailTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.onEditingComplete,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: 'Correo electrónico',
      hint: 'tu@correo.com',
      controller: controller,
      focusNode: focusNode,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      autofocus: autofocus,
      validator: Validators.validateEmail,
      onEditingComplete: onEditingComplete,
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final VoidCallback? onEditingComplete;
  final TextInputAction textInputAction;

  const PasswordTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.validator,
    this.onEditingComplete,
    this.textInputAction = TextInputAction.done,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'Contraseña',
      hint: hint ?? '••••••••',
      controller: controller,
      focusNode: focusNode,
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      showToggleVisibility: true,
      textInputAction: textInputAction,
      validator: validator ?? Validators.validatePassword,
      onEditingComplete: onEditingComplete,
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final double strength;
  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    final level = Validators.getPasswordStrengthLevel(strength);
    final text = Validators.getPasswordStrengthText(strength);
    Color color = level == PasswordStrengthLevel.weak
        ? AppColors.alertRed
        : (level == PasswordStrengthLevel.medium
              ? AppColors.warningOrange
              : AppColors.successGreen);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              level == PasswordStrengthLevel.strong
                  ? Icons.check_circle
                  : Icons.info_outline,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              'Fortaleza: $text',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfessionDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;

  const ProfessionDropdown({super.key, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profesión',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            'Selecciona tu profesión',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
            prefixIcon: Icon(
              Icons.work_outline,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              size: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: AppConfig.professions
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: onChanged,
          validator: Validators.validateProfession,
        ),
      ],
    );
  }
}
