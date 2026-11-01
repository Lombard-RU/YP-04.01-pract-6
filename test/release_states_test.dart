import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_app/main.dart';
import 'package:library_app/models/book.dart';
import 'package:library_app/models/book_query.dart';
import 'package:library_app/models/page_result.dart';
import 'package:library_app/repositories/in_memory_book_repository.dart';

class PendingBooks extends InMemoryBookRepository {
  final response = Completer<PageResult<Book>>();
  @override
  Future<PageResult<Book>> find(BookQuery query) => response.future;
}

void main() {
  testWidgets('Во время незавершённого запроса виден индикатор загрузки', (
    tester,
  ) async {
    final books = PendingBooks();
    await tester.pumpWidget(
      LibraryApp(initialLocation: '/books', books: books),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Загружаем каталог…'), findsOneWidget);
    books.response.complete(PageResult.empty());
    await tester.pumpAndSettle();
    expect(find.text('Ничего не найдено'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets(
    'Пустой список не является ошибкой и предлагает сбросить фильтры',
    (tester) async {
      await tester.pumpWidget(
        const LibraryApp(initialLocation: '/books?search=zzzzzzzz'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ничего не найдено'), findsOneWidget);
      expect(find.text('Сбросить фильтры'), findsOneWidget);
      expect(find.text('Не удалось загрузить данные'), findsNothing);
    },
  );

  testWidgets('После ошибки повтор восстанавливает каталог без перезагрузки', (
    tester,
  ) async {
    await tester.pumpWidget(
      const LibraryApp(initialLocation: '/books?__fail=500'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Не удалось загрузить данные'), findsOneWidget);
    await tester.ensureVisible(find.text('Повторить'));
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось загрузить данные'), findsNothing);
    expect(find.text('1984'), findsOneWidget);
  });
}
