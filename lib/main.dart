import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/word_local_data_source.dart';
import 'data/repositories/word_repository_impl.dart';
import 'presentation/bloc/word_bloc.dart';
import 'presentation/pages/investigation_board_page.dart';

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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              WordBloc(repository: repository)..add(LoadInitialData()),
        ),
      ],
      child: const InvestigationBoardPageRoot(),
    ),
  );
}

class InvestigationBoardPageRoot extends StatelessWidget {
  const InvestigationBoardPageRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathWord',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const InvestigationBoardPage(),
    );
  }
}
