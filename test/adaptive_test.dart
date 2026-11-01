import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/main.dart';
import 'package:library_app/widgets/entity_table.dart';

void main() {
  for (final width in [360.0, 768.0, 1280.0, 1920.0]) {
    testWidgets('Каталог без переполнений при ширине $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const LibraryApp(initialLocation: '/books'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('library-bottom-navigation')),
        width < 600 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(NavigationRail),
        width >= 600 ? findsOneWidget : findsNothing,
      );
      final rail = find.byType(NavigationRail);
      if (width >= 600) {
        expect(tester.widget<NavigationRail>(rail).extended, width >= 1280);
      }
      expect(
        find.byKey(const ValueKey('entity-cards')),
        width < 1280 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byWidgetPredicate((w) => w is EntityTable),
        width >= 1280 ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('Изменение ширины перестраивает навигацию без перезапуска', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(1280, 1000);
    await tester.pumpWidget(const LibraryApp(initialLocation: '/books'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(360, 1000);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byKey(const ValueKey('entity-cards')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
