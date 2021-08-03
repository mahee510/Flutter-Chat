import 'package:flutter/material.dart';

Shader textGradient(Color color1, Color color2) {
  final Shader linearGradient = LinearGradient(
    colors: <Color>[color1, color2],
  ).createShader(
    const Rect.fromLTWH(100.0, 0.0, 200.0, 70.0),
  );
  return linearGradient;
}

BoxDecoration fieldBuildBoxDecoration(BuildContext context) {
  final Color bgColor =
      Theme.of(context).scaffoldBackgroundColor == Colors.grey.shade900
          ? const Color(0xFF1A1B1E)
          : const Color(0xFFF5F5F5);
  final Color shadeColor =
      Theme.of(context).scaffoldBackgroundColor == Colors.grey.shade900
          ? const Color(0xFF242529).withOpacity(0.50)
          : Colors.black.withOpacity(0.075);
  final Color shadeColor2 =
      Theme.of(context).scaffoldBackgroundColor == Colors.grey.shade900
          ? const Color(0xFF242529).withOpacity(0.50)
          : Colors.white;
  return BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: shadeColor,
        offset: const Offset(10, 10),
        blurRadius: 10,
      ),
      BoxShadow(
        color: shadeColor2,
        offset: const Offset(-10, -10),
        blurRadius: 10,
      ),
    ],
  );
}
