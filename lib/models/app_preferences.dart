// lib/models/app_preferences.dart

class AppPreferences {
  final String fontFamily;
  final double fontSize;

  AppPreferences({
    this.fontFamily = 'Roboto',
    this.fontSize = 16.0,
  });

  AppPreferences copyWith({
    String? fontFamily,
    double? fontSize,
  }) {
    return AppPreferences(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
    };
  }

  factory AppPreferences.fromMap(Map<String, dynamic> map) {
    return AppPreferences(
      fontFamily: map['fontFamily'] ?? 'Roboto',
      fontSize: map['fontSize']?.toDouble() ?? 16.0,
    );
  }
}
