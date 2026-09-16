// =============================================================
// ChefUnitPlus - Tests autonomes
// Ces tests ne dependent d'AUCUN fichier du projet
// Ils verifient que Flutter fonctionne correctement
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChefUnitPlus - Smoke Tests', () {
    // ---------------------------------------------------------
    // 🧪 Test 1 : affichage basique
    // ---------------------------------------------------------
    testWidgets('Affichage d un texte', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('ChefUnitPlus')),
          ),
        ),
      );

      expect(find.text('ChefUnitPlus'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    // ---------------------------------------------------------
    // 🧪 Test 2 : presence d'un bouton
    // ---------------------------------------------------------
    testWidgets('Presence d un bouton', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Cliquer'),
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Cliquer'), findsOneWidget);
    });

    // ---------------------------------------------------------
    // 🧪 Test 3 : interaction avec un bouton
    // ---------------------------------------------------------
    testWidgets('Tap sur un bouton incremente un compteur',
        (WidgetTester tester) async {
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Compteur : $counter'),
                      ElevatedButton(
                        onPressed: () => setState(() => counter++),
                        child: const Text('Ajouter'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Compteur : 0'), findsOneWidget);

      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      expect(find.text('Compteur : 1'), findsOneWidget);
    });

    // ---------------------------------------------------------
    // 🧪 Test 4 : saisie de texte
    // ---------------------------------------------------------
    testWidgets('Saisie dans un TextField',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ChefUnitPlus');
      await tester.pump();

      expect(controller.text, 'ChefUnitPlus');
    });

    // ---------------------------------------------------------
    // 🧪 Test 5 : navigation
    // ---------------------------------------------------------
    testWidgets('Navigation entre deux ecrans',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Page 2')),
                      ),
                    ),
                  ),
                  child: const Text('Aller page 2'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Page 2'), findsNothing);

      await tester.tap(find.text('Aller page 2'));
      await tester.pumpAndSettle();

      expect(find.text('Page 2'), findsOneWidget);
    });

    // ---------------------------------------------------------
    // 🧪 Test 6 : validation de couleur du theme
    // ---------------------------------------------------------
    testWidgets('Theme Material 3 actif', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(body: SizedBox()),
        ),
      );

      final BuildContext context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);

      expect(theme.useMaterial3, true);
    });

    // ---------------------------------------------------------
    // 🧪 Test 7 : widget Icon
    // ---------------------------------------------------------
    testWidgets('Affichage d une icone', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Icon(Icons.school, size: 48),
          ),
        ),
      );

      expect(find.byIcon(Icons.school), findsOneWidget);
    });
  });
}
