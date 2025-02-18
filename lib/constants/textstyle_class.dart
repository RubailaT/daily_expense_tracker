import 'package:flutter/material.dart';

const String primaryFontName = 'Inter';

class TextStyleClass {
  static const double textHeight = 1.4;

  static TextStyle inter400TextStyle(double fontsize, Color color) {
    return TextStyle(
        fontFamily: primaryFontName,
        color: color,
        height: textHeight,
        fontSize: fontsize);
  }

  static TextStyle inter500TextStyle(double fontsize, Color color) {
    return TextStyle(
        fontFamily: primaryFontName,
        color: color,
        fontWeight: FontWeight.w500,
        height: textHeight,
        fontSize: fontsize);
  }

  // static TextStyle inter600TextUnderlinee(double fontSize, Color color) {
  //   return TextStyle(
  //     fontSize: fontSize,
  //     fontWeight: FontWeight.w600,
  //     color: color,
  //     decoration: TextDecoration.underline,
  //     decorationThickness: 0.7,
  //   );
  // }

  static TextStyle inter600TextStyle(double fontsize, Color color) {
    return TextStyle(
        fontFamily: primaryFontName,
        color: color,
        fontWeight: FontWeight.w600,
        height: textHeight,
        fontSize: fontsize);
  }

  static TextStyle inter700TextStyle(double fontsize, Color color) {
    return TextStyle(
        fontFamily: primaryFontName,
        color: color,
        fontWeight: FontWeight.w700,
        height: textHeight,
        fontSize: fontsize);
  }
}
