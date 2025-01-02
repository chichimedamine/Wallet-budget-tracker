import 'package:flutter/material.dart';

class ColorsHelper {
  // Define some common colors as static constants
  static const Color primaryColor = Color(0xFF4CAF50); // Material Design Green
  static const Color secondaryColor =
      Color(0xFF81C784); // Lighter green for secondary
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF000000);
  static const Color white = Color.fromARGB(255, 255, 254, 254);

  // Basic colors
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color.fromARGB(255, 126, 193, 126);
  static const Color blue = Color.fromARGB(255, 8, 8, 48);
  static const Color yellow = Color(0xFFFFFF00);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color magenta = Color(0xFFFF00FF);
  static const Color gray = Color(0xFF808080);
  static const Color lightGray = Color(0xFFD3D3D3);
  static const Color darkGray = Color(0xFFA9A9A9);
  static const Color orange = Color(0xFFFFA500);
  static const Color pink = Color(0xFFFFC0CB);
  static const Color purple = Color(0xFF800080);
  static const Color brown = Color(0xFFA52A2A);

  // Method to blend two colors
  static Color blendColors(Color color1, Color color2, double amount) {
    return Color.lerp(color1, color2, amount) ?? color1;
  }

  // Method to get a color with opacity
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Method to get a contrasting color (black or white) for a given color
  static Color getContrastingColor(Color color) {
    final double luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
