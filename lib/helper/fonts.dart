import 'package:flutter/material.dart';

class FontsHelper {
  // Define font sizes
  static const fontFamily = "Comfortaa";
  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 20.0;

  // Define font weights
  static const FontWeight lightWeight = FontWeight.w300;
  static const FontWeight regularWeight = FontWeight.w400;
  static const FontWeight boldWeight = FontWeight.w700;

  // New method for bold text style
  static TextStyle boldTextStyle({
    double fontSize = mediumFontSize,
    Color color = Colors.black,
    FontStyle fontStyle = FontStyle.normal,
    String fontFamily = fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: boldWeight,
      color: color,
      fontStyle: fontStyle,
      fontFamily: fontFamily,
    );
  }

  static TextStyle largeTextStyle({
    double fontSize = largeFontSize,
    Color color = Colors.black,
    FontWeight fontWeight = regularWeight,
    FontStyle fontStyle = FontStyle.normal,
    String fontFamily = fontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      fontFamily: fontFamily,
    );
  }

  static TextStyle mediumTextStyle({
    Color color = Colors.black,
    FontWeight fontWeight = regularWeight,
    FontStyle fontStyle = FontStyle.normal,
    String fontFamily = fontFamily,
    required double fontSize,
  }) {
    return TextStyle(
      fontSize: mediumFontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      fontFamily: fontFamily,
    );
  }

  // Define text styles with font style and font family
  static TextStyle smallTextStyle({
    Color color = Colors.black,
    FontWeight fontWeight = regularWeight,
    FontStyle fontStyle = FontStyle.normal,
    String fontFamily = fontFamily,
    required double fontSize,
  }) {
    return TextStyle(
      fontSize: smallFontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      fontFamily: fontFamily,
    );
  }

  // Add more styles as needed
}
