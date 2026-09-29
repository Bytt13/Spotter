import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotter_app/main.dart'; // Puxa a nossa base real

void main() {
  testWidgets('App smoke test - Verifica se o motor liga', (
    WidgetTester tester,
  ) async {
    // Constrói nosso app envolto no ProviderScope do Riverpod
    await tester.pumpWidget(const ProviderScope(child: SpotterApp()));

    // Verifica se o texto da nossa fundação apareceu na tela
    expect(find.text('Motor Flutter Enterprise Ligado.'), findsOneWidget);
  });
}
