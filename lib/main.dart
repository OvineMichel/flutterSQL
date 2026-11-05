import 'package:dbestudante/pag1.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AplicativoAcademico());
}

class AplicativoAcademico extends StatelessWidget {
  const AplicativoAcademico({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF176B67);
    return MaterialApp(
      title: 'Gestão Acadêmica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF5F7F6)),
        inputDecorationTheme: const InputDecorationTheme(filled: true, fillColor: Colors.white),
      ),
      home: const PaginaAcademica(),
    );
  }
}
