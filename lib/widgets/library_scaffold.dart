import 'package:flutter/material.dart';
import '../core/practice_stage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../models/catalog_entity.dart';
import '../repositories/library_database.dart';
import '../state/auth_notifier.dart';
import '../state/author_list_notifier.dart';
import '../state/book_list_notifier.dart';
import '../state/reference_list_notifier.dart';
import 'api_session_button.dart';
import 'adaptive_navigation.dart';

class LibraryScaffold extends StatelessWidget {
  const LibraryScaffold({
    super.key,
    required this.child,
    this.section = 'books',
  });
  final Widget child;
  final String section;
  static const _icons = {
    'books': Icons.menu_book_outlined,
    'authors': Icons.people_outline,
    'genres': Icons.category_outlined,
    'publishers': Icons.business_outlined,
    'readers': Icons.badge_outlined,
  };
  void _navigate(BuildContext context, String target) {
    if (!catalogSections.contains(target)) {
      context.go(target);
      return;
    }
    final query = switch (target) {
      'books' => context.read<BookListNotifier>().query,
      'authors' => context.read<AuthorListNotifier>().query,
      'genres' => context.read<GenreListNotifier>().query,
      'publishers' => context.read<PublisherListNotifier>().query,
      _ => context.read<ReaderListNotifier>().query,
    };
    context.go(query.toUri('/$target').toString());
  }

  @override
  Widget build(BuildContext context) {
    final database = context.watch<LibraryDatabase?>();
    final auth = context.watch<AuthNotifier>();
    final mobile = MediaQuery.sizeOf(context).width < AppLayout.mobile;
    final sections = {
      for (final target in catalogSections)
        if ((practiceStage >= 3 || ['books', 'authors'].contains(target)) &&
            (target != 'readers' || auth.allows(Permission.readers)))
          target: sectionTitles[target]!,
    };
    final primary = auth.enabled
        ? {
            '/': 'Главная',
            'books': 'Книги',
            if (auth.isRole(Role.reader)) '/my-loans': 'Мои выдачи',
            if (auth.isRole(Role.librarian)) '/loans': 'Выдачи',
            if (auth.isRole(Role.admin)) ...{
              '/admin/users': 'Пользователи',
              '/admin/stats': 'Статистика',
            },
          }
        : sections;
    final destinations = [
      for (final entry in primary.entries)
        LibraryDestination(entry.key, entry.value, switch (entry.key) {
          '/' => Icons.home_outlined,
          '/my-loans' || '/loans' => Icons.assignment_outlined,
          '/admin/users' => Icons.manage_accounts_outlined,
          '/admin/stats' => Icons.bar_chart_outlined,
          _ => _icons[entry.key] ?? Icons.dashboard_outlined,
        }),
    ];
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    final active = destinations.indexWhere((destination) {
      final path = destination.path.startsWith('/')
          ? destination.path
          : '/${destination.path}';
      return location == path || (path != '/' && location.startsWith('$path/'));
    });
    final selected = active < 0 ? 0 : active;
    void select(int index) => _navigate(context, destinations[index].path);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 20,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_library_outlined, size: 28),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Библиотека',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Разделы библиотеки',
            onSelected: (target) => _navigate(context, target),
            icon: const Icon(Icons.menu),
            itemBuilder: (_) => [
              for (final entry in {...primary, ...sections}.entries)
                PopupMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(_icons[entry.key] ?? Icons.dashboard_outlined),
                      const SizedBox(width: 12),
                      Text(entry.value),
                    ],
                  ),
                ),
            ],
          ),
          const ApiSessionButton(),
          const SizedBox(width: 12),
        ],
      ),
      bottomNavigationBar: mobile
          ? NavigationBar(
              key: const ValueKey('library-bottom-navigation'),
              selectedIndex: selected,
              onDestinationSelected: select,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: [
                for (final entry in destinations)
                  NavigationDestination(
                    icon: Icon(entry.icon),
                    label: entry.label,
                    tooltip: entry.label,
                  ),
              ],
            )
          : null,
      body: SafeArea(
        child: AdaptiveNavigation(
          destinations: destinations,
          selectedIndex: selected,
          onSelected: select,
          child: Column(
            children: [
              if (auth.warningSeconds != null)
                MaterialBanner(
                  leading: const Icon(Icons.timer_outlined),
                  content: Text(
                    'Сессия завершится через ${auth.warningSeconds} сек. из-за бездействия.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: auth.recordActivity,
                      child: const Text('Продолжить работу'),
                    ),
                  ],
                ),
              if (auth.notice != null && auth.loggedIn)
                MaterialBanner(
                  content: Text(auth.notice!),
                  actions: [
                    TextButton(
                      onPressed: auth.dismissNotice,
                      child: const Text('Понятно'),
                    ),
                  ],
                ),
              if (auth.demoOverride)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Учебная демонстрация: роль интерфейса изменена локально. Права API не изменены.',
                  ),
                ),
              if (database?.notice != null)
                MaterialBanner(
                  content: Text(database!.notice!),
                  actions: [
                    TextButton(
                      onPressed: database.dismissNotice,
                      child: const Text('Понятно'),
                    ),
                  ],
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppLayout.maxContent,
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
