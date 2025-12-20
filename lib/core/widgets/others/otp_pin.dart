// Définition des thèmes Pinput dans votre OtpScreen (ou une classe de style)
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

// Thèmes pour le widget Pinput
final defaultPinTheme = PinTheme(
  width: 56,
  height: 60,
  textStyle: const TextStyle(
    fontSize: 22,
    color: Colors.black,
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade400),
  ),
);

final focusedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration!.copyWith(
    border: Border.all(color: const Color(0xFF204FCF)), // Couleur de focus bleue
  ),
);

final errorPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration!.copyWith(
    border: Border.all(color: Colors.red), // Couleur d'erreur rouge
  ),
);