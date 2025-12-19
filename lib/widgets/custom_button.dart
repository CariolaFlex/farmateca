import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPress = isEnabled && !isLoading && onPressed != null;
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: canPress
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        boxShadow: canPress
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canPress ? onPressed : null,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class TextLinkButton extends StatelessWidget {
  final String text;
  final String? boldText;
  final VoidCallback? onPressed;

  const TextLinkButton({
    super.key,
    required this.text,
    this.boldText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: boldText != null
          ? RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                children: [
                  TextSpan(text: text),
                  TextSpan(
                    text: ' $boldText',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Text(
              text,
              style: TextStyle(color: AppColors.primaryBlue, fontSize: 14),
            ),
    );
  }
}

class SocialAuthButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.borderColor,
  });

  factory SocialAuthButton.google({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialAuthButton(
      text: 'Continuar con Google',
      icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
      onPressed: onPressed,
      isLoading: isLoading,
      borderColor: Colors.grey.shade300,
    );
  }

  factory SocialAuthButton.apple({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return SocialAuthButton(
      text: 'Continuar con Apple',
      icon: const Icon(Icons.apple, color: Colors.white, size: 24),
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            side: BorderSide(color: borderColor ?? Colors.transparent),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
