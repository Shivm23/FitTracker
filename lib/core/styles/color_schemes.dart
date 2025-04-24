import 'package:flutter/material.dart';

///
/// Generated from Material Theme Builder
/// https://m3.material.io/theme-builder#/dynamic
///
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006E2B),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF69FF89),
  onPrimaryContainer: Color(0xFF002108),
  secondary: Color(0xFF516351),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD4E8D1),
  onSecondaryContainer: Color(0xFF0F1F11),
  tertiary: Color(0xFF39656C),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFBDEAF3),
  onTertiaryContainer: Color(0xFF001F24),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFCFDF7),
  onSurface: Color(0xFF1A1C19),
  surfaceContainerHighest: Color(0xFFDDE5D9),
  onSurfaceVariant: Color(0xFF424940),
  outline: Color(0xFF727970),
  onInverseSurface: Color(0xFFF0F1EB),
  inverseSurface: Color(0xFF2E312D),
  inversePrimary: Color(0xFF33E36A),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006E2B),
  outlineVariant: Color(0xFFC1C9BE),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFB5A0),
  onPrimary: Color(
      0xFF392E2B), // inverse on surface (choix logique vu que "onPrimary" n'était pas donné)
  primaryContainer: Color(0xFF723523),
  onPrimaryContainer: Color(0xFFF1DFDA), // on surface

  secondary: Color(0xFFE7BDB2),
  onSecondary: Color(0xFF392E2B), // inverse on surface
  secondaryContainer: Color(0xFF5D4037),
  onSecondaryContainer: Color(0xFFF1DFDA), // on surface

  tertiary: Color(0xFFD8C58D),
  onTertiary: Color(0xFF392E2B), // inverse on surface
  tertiaryContainer: Color(0xFF534619),
  onTertiaryContainer: Color(0xFFF1DFDA), // on surface

  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFFFFFFFF), // Valeur par défaut si non précisé
  onErrorContainer: Color(0xFFF1DFDA), // on surface

  surface: Color(0xFF1A110F),
  onSurface: Color(0xFFF1DFDA),
  surfaceContainerHighest: Color(0xFF3D322F),
  onSurfaceVariant: Color(0xFFD8C2BC), // on surface var

  outline: Color(0xFFA08C87),
  onInverseSurface: Color(0xFF392E2B),
  inverseSurface: Color(0xFFF1DFDA),
  inversePrimary: Color(0xFF8F4C38),

  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFFFB5A0), // Souvent la couleur "primary"
  outlineVariant: Color(0xFF53433F),
  scrim: Color(0xFF000000),
);
