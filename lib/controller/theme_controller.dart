import 'package:flutter/material.dart';
import 'package:guia_turismo/theme/theme_widget.dart';


class ThemeController extends ChangeNotifier {
  ThemeMode _temaAtual = ThemeMode.light;
  ThemeMode get temaAtual => _temaAtual;

  IconData get iconeAtual =>
      _temaAtual == ThemeMode.light ? Icons.light_mode : Icons.dark_mode;

  static ThemeData _mudarTema(Brightness brilho) {
    final cor = ColorScheme.fromSeed(
      seedColor: Colors.lightGreen,
      brightness: brilho,
    );
    return ThemeData(
      
      useMaterial3: true,
      colorScheme: cor,
      appBarTheme: defineAppBar(cor),
      bottomNavigationBarTheme: defineNavegacaoBase(cor),
      
      elevatedButtonTheme: defineBotaoElevated(cor),
      iconButtonTheme: IconButtonThemeData(),
      cardTheme: CardThemeData(),
    );
  }

  ThemeData temaClaro() => _mudarTema(Brightness.light);
  ThemeData temaEscuro() => _mudarTema(Brightness.dark);

  void alternarTema() {
    _temaAtual = _temaAtual == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners(); 
  }
}
