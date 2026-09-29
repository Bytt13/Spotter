import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
        primaryColor: Colors.deepOrange,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const ChatSpotterScreen(),
    );
  }
}

// ==========================================
// ESTADO MODERNO (Padrão Riverpod Notifier)
// ==========================================

// 1. Notifier para controlar o indicador de carregamento
class LoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final loadingProvider = NotifierProvider<LoadingNotifier, bool>(
  LoadingNotifier.new,
);

// 2. Notifier para controlar a resposta da IA na tela
class RespostaAiNotifier extends Notifier<String> {
  @override
  String build() => "Aguardando seu comando para gerar o treino...";
  void set(String value) => state = value;
}

final respostaAiProvider = NotifierProvider<RespostaAiNotifier, String>(
  RespostaAiNotifier.new,
);

// ==========================================
// TELA DO CHAT (UI)
// ==========================================

class ChatSpotterScreen extends ConsumerStatefulWidget {
  const ChatSpotterScreen({super.key});

  @override
  ConsumerState<ChatSpotterScreen> createState() => _ChatSpotterScreenState();
}

class _ChatSpotterScreenState extends ConsumerState<ChatSpotterScreen> {
  final TextEditingController _textController = TextEditingController();

  Future<void> _enviarParaInteligencia() async {
    final texto = _textController.text.trim();
    if (texto.isEmpty) return;

    FocusScope.of(context).unfocus();

    // Ativa o loading usando o novo Notifier
    ref.read(loadingProvider.notifier).set(true);

    try {
      // IP do seu Mac na rede local (Hardcode pragmático validado)
      // Lê diretamente do arquivo de ambiente que configuramos
      final apiUrl = dotenv.env['API_URL'] ?? "http://192.168.15.20:8000";

      final response = await http.post(
        Uri.parse('$apiUrl/gerar-treino'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"mensagem_usuario": texto}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Atualiza a resposta da IA
        ref.read(respostaAiProvider.notifier).set(data['treino_gerado']);
      } else {
        ref
            .read(respostaAiProvider.notifier)
            .set("Erro no Servidor: ${response.statusCode}");
      }
    } catch (e) {
      ref
          .read(respostaAiProvider.notifier)
          .set("Erro de Rede: Tente novamente. ($e)");
    } finally {
      // Desativa o loading
      ref.read(loadingProvider.notifier).set(false);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final resposta = ref.watch(respostaAiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Spotter Alpha',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  resposta,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Ex: Treino de peito pesado com halteres...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _enviarParaInteligencia(),
                  ),
                ),
                const SizedBox(width: 8),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.deepOrange)
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepOrange),
                        iconSize: 32,
                        onPressed: _enviarParaInteligencia,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
