import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle get _fontStyl => GoogleFonts.sourceSansPro(
      color: const Color(0XFF3F7EE8),
      fontWeight: FontWeight.bold,
    );

get googleText => [
      TextSpan(
        text: "G",
        style: _fontStyl,
      ),
      TextSpan(
        text: "o",
        style: _fontStyl.copyWith(
          color: const Color(0XFFDE4032),
        ),
      ),
      TextSpan(
        text: "o",
        style: _fontStyl.copyWith(
          color: const Color(0XFFEEB205),
        ),
      ),
      TextSpan(
        text: "g",
        style: _fontStyl.copyWith(
          color: const Color(0XFF3F7EE8),
        ),
      ),
      TextSpan(
        text: "l",
        style: _fontStyl.copyWith(
          color: const Color(0XFF319F4F),
        ),
      ),
      TextSpan(
        text: "e",
        style: _fontStyl.copyWith(
          color: const Color(0XFFDE4032),
        ),
      ),
    ];
