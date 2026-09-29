import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

// 1. O Riverpod cria uma "antena" que vai chamar o Python
final apiProvider = FutureProvider<String>((ref) async {
  // Bate na rota "/" do FastAPI que criamos antes
  final response = await http.get(Uri.parse('http://192.168.15.20:8000/'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['mensagem']; // Pega a mensagem do JSON do Python
  } else {
    throw Exception('Falha ao conectar com o Servidor Spotter');
  }
});

void main() {
  runApp(const ProviderScope(child: SpotterApp()));
}

class SpotterApp extends StatelessWidget {
  const SpotterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotter',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepOrange, // Nosso laranja
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange, // Aplicando o laranja no botão
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const HomeSpotter(),
    );
  }
}

class HomeSpotter extends ConsumerWidget {
  const HomeSpotter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. O app "escuta" a nossa antena
    final apiConnection = ref.watch(apiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spotter API Test',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3. Reage ao status da conexão (Carregando, Erro ou Sucesso)
            apiConnection.when(
              loading: () =>
                  const CircularProgressIndicator(color: Colors.deepOrange),
              error: (err, stack) => Text(
                'Erro de conexão: $err',
                style: const TextStyle(color: Colors.red),
              ),
              data: (mensagem) => Text(
                mensagem,
                style: const TextStyle(fontSize: 18, color: Colors.greenAccent),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // Atualiza a requisição
                ref.invalidate(apiProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Pingar Servidor Python'),
            ),
          ],
        ),
      ),
    );
  }
}
