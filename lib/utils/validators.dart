import 'constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorInvalidEmail;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.errorInvalidEmail;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorPasswordShort;
    }
    if (value.length < 6) {
      return AppStrings.errorPasswordShort;
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorPasswordMatch;
    }
    if (value != password) {
      return AppStrings.errorPasswordMatch;
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.errorNameRequired;
    }
    if (value.trim().length < 2) {
      return 'El nombre es muy corto';
    }
    return null;
  }

  static String? validateProfession(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorProfessionRequired;
    }
    return null;
  }

  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static String sanitizeName(String name) {
    return name.trim();
  }

  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.1;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;
    return strength.clamp(0.0, 1.0);
  }

  static PasswordStrengthLevel getPasswordStrengthLevel(double strength) {
    if (strength < 0.4) return PasswordStrengthLevel.weak;
    if (strength < 0.7) return PasswordStrengthLevel.medium;
    return PasswordStrengthLevel.strong;
  }

  static String getPasswordStrengthText(double strength) {
    switch (getPasswordStrengthLevel(strength)) {
      case PasswordStrengthLevel.weak:
        return 'Débil';
      case PasswordStrengthLevel.medium:
        return 'Media';
      case PasswordStrengthLevel.strong:
        return 'Fuerte';
    }
  }
}

enum PasswordStrengthLevel { weak, medium, strong }
