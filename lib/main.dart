import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'data/datasources/word_local_data_source.dart';
import 'data/repositories/word_repository_impl.dart';
import 'domain/usecases/get_words.dart';
import 'presentation/bloc/word_bloc.dart';
import 'presentation/pages/word_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Initialize Web DB
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    // Initialize Desktop DB (Windows/Linux/macOS)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // On Android and iOS, sqflite uses the standard native implementation by default.

  // Dependency Injection (Manual for now)
  final localDataSource = WordLocalDataSource();
  final repository = WordRepositoryImpl(localDataSource: localDataSource);
  final getWordsUseCase = GetWords(repository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WordBloc(getWords: getWordsUseCase)),
      ],
      child: const PathWord(),
    ),
  );
}

class PathWord extends StatelessWidget {
  const PathWord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathWord',
      debugShowCheckedModeBanner: false,
      theme: themeDataColors(),
      home: const WordListPage(),
    );
  }
}

ThemeData themeDataColors() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8D6E63), // Marrón cuero base
      brightness: Brightness.light,

      // El color de fondo: Un beige "pergamino" para que no canse la vista
      surface: const Color(0xFFF2EAD3),

      // Color principal: Azul oscuro "Medianoche" (confianza y misterio)
      primary: const Color(0xFF2C3E50),
      onPrimary: Colors.white,

      // Color secundario: Rojo "Lacre" o "Sangre seca" (para pistas e importancia)
      secondary: const Color(0xFF8B0000),
      onSecondary: Colors.white,

      // Acentos: Dorado viejo / Bronce (para medallas, logros o lupas)
      tertiary: const Color(0xFFC5A059),

      // Errores: Un naranja quemado para no romper la estética vintage
      error: const Color(0xFFB7410E),
    ),

    // Estilo de texto inspirado en máquinas de escribir o libros antiguos
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF2C3E50),
        fontWeight: FontWeight.bold,
        fontFamily: 'Serif',
      ),
      bodyLarge: TextStyle(color: Color(0xFF4E342E), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF5D4037)),
    ),

    // Estilo de tarjetas (Cards) que imitan expedientes o sobres
    cardTheme: CardThemeData(
      color: const Color(0xFFEADCBF),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
