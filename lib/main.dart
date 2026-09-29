import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // O ProviderScope ativa o sistema nervoso central do Riverpod
    const ProviderScope(
      child: SpotterApp(),
    ),
  );
}

class SpotterApp extends StatelessWidget {
  const SpotterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotter',
      theme: ThemeData(
        brightness: Brightness.dark, // Academia pede Dark Mode
        primaryColor: Colors.deepOrange, // Uma cor forte e agressiva para treino
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Motor Flutter Enterprise Ligado.'),
        ),
      ),
    );
  }
}