import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../state/auth_notifier.dart';
import '../widgets/library_scaffold.dart';
import '../widgets/adaptive_navigation.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final entries = <(String, String, IconData, String)>[
      (
        'Каталог',
        'Поиск книг, авторов, жанров и издательств.',
        Icons.menu_book_outlined,
        '/books',
      ),
      if (auth.isRole(Role.reader))
        (
          'Мои выдачи',
          'Ваши книги, сроки возврата и продление.',
          Icons.auto_stories_outlined,
          '/my-loans',
        ),
      if (auth.isRole(Role.librarian)) ...[
        (
          'Рабочее место библиотекаря',
          'Оформление и закрытие выдач.',
          Icons.assignment_outlined,
          '/loans',
        ),
        (
          'Читатели',
          'Карточки читателей и читательские билеты.',
          Icons.badge_outlined,
          '/readers',
        ),
      ],
      if (auth.isRole(Role.admin)) ...[
        (
          'Пользователи и роли',
          'Управление доступом к библиотеке.',
          Icons.manage_accounts_outlined,
          '/admin/users',
        ),
        (
          'Статистика',
          'Книги, читатели и незакрытые выдачи.',
          Icons.bar_chart_outlined,
          '/admin/stats',
        ),
      ],
    ];
    return LibraryScaffold(
      section: 'home',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Здравствуйте, ${auth.fullName ?? 'читатель'}!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Chip(
              avatar: const Icon(Icons.person_outline, size: 20),
              label: Text(auth.user?.role.label ?? 'Библиотека'),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final windowWidth = MediaQuery.sizeOf(context).width;
                final columns = windowWidth < AppLayout.mobile
                    ? 1
                    : windowWidth < AppLayout.desktop
                    ? 2
                    : 3;
                final cardWidth =
                    (constraints.maxWidth - 16 * (columns - 1)) / columns;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final (title, description, icon, path) in entries)
                      SizedBox(
                        width: cardWidth,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(icon, size: 32),
                                const SizedBox(height: 16),
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(description),
                                const SizedBox(height: 20),
                                FilledButton.tonal(
                                  onPressed: () => context.go(path),
                                  child: const Text('Открыть'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});
  @override
  Widget build(BuildContext context) => LibraryScaffold(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Доступ запрещён',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'У вашей роли нет прав на этот раздел.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
}
