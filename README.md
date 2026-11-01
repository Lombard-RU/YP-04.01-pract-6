# Практическая №6 — Серёгов Роман Алексеевич, П-7-23

Финальная библиотечная система по ПР2–ПР6. Публикация подготовлена, но до подключения GitHub публичной ссылки нет.

## Запуск

Windows: `start.bat` (нужны Flutter и Node.js).

Или два терминала в этой папке:

```bash
node api/mock-server.js --port 8080 --origin http://localhost:5555 --ttl 60
```

```bash
flutter pub get
flutter run -d chrome --web-port=5555 --web-hostname=localhost --dart-define=API_BASE_URL=http://localhost:8080/api
```

Учётные записи: reader/reader123, librarian/librarian123, admin/admin123. Сервер учебный, данные в памяти. Пароли новых пользователей: от 8 символов с цифрой и спецсимволом. Сессия: 180 секунд неактивности, предупреждение за 30 секунд; общий предел 30 минут.

Адрес API не зашит в исходники: без параметра используется относительный `/api` (для прокси на одном origin). Для отдельного сервера обязательно передавайте API_BASE_URL при запуске/сборке.

## Адаптивность

- 360: одна колонка, NavigationBar снизу, списки карточками.
- 768: компактная NavigationRail сбоку, две колонки карточек на главной.
- 1280: расширенная NavigationRail с подписями, таблицы каталога.
- 1920: ограничение области содержимого 1320 пикселями.
- Перестроение выполняется при изменении окна без перезапуска. Таблицы прокручиваются по двум осям, формы ограничены по ширине, фильтры используют Wrap.

## Проверки и сборки

```bash
flutter analyze
flutter test --no-pub
dart format --output=none --set-exit-if-changed lib test
node --test api/mock-server.test.js api/auth.test.js
flutter build web --release --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:8080/api
flutter build web --release --wasm --no-web-resources-cdn --dart-define=API_BASE_URL=http://localhost:8080/api --output=build/wasm
```

Проверено: Flutter 3.47.7, Dart 3.13.5, Node.js 24.11.1. 110 Flutter-тестов, включая четыре ширины и перестроение; 12 серверных тестов. Журналы находятся рядом с README. Скриншоты и результаты браузерных проверок — `report/`.

Релиз — `build/web`; Wasm с JS fallback — `build/wasm`. Начальная HTML-заглушка видна до первого кадра Flutter; есть сообщение и повтор при ошибке загрузки. Шрифты/рендерер загружаются локально.

Локальный просмотр из корня всей работы:

```bash
python tools/serve_web.py --directory pract-6/build/web --port 5555
```

Для финальной копии замените путь на `final/app/build/web`. Нельзя открывать index.html через file://. Python-сервер настроен на SPA fallback и MIME application/wasm, application/javascript для .mjs.

## Измерения

`report/measurements.json` содержит размеры всех файлов, gzip-оценку, три холодных запуска каждого варианта и медиану времени до flutter-first-frame. Замеры локальные, Chromium без сетевого ограничения; это не замеры реального хостинга. `baseline` — до оптимизации; `web` — после удаления дублирующих шрифтов Roboto и неиспользуемого cupertino_icons; `wasm` — отдельная сборка с fallback. Размер всего каталога включает все варианты рендерера, а не только скачиваемые браузером ресурсы.

`report/browser-checks.json`: основные экраны на четырёх ширинах, отсутствие pageerror, отключение/повторное подключение API, вход с клавиатуры и Tab. ERR_CONNECTION_REFUSED в журнале консоли ожидаемы только в сценарии намеренного отключения API; отдельно записан намеренный отказ загрузки для снимка заглушки. `report/subdirectory-check.json`: прямой внутренний адрес и обновление в /library/.

## GitHub Pages — настроить позже

Готовый workflow: `.github/workflows/deploy.yml` в корне всей работы. Он рассчитан на структуру репозитория с папкой pract-6. Копия для отдельного репозитория (с приложением в корне) находится в `deployment/standalone-workflow.yml`: положите её в `.github/workflows/deploy.yml` своего отдельного репозитория.

1. Создайте репозиторий, загрузите файлы, основная ветка `main`.
2. Settings → Pages → Source: GitHub Actions.
3. Settings → Secrets and variables → Actions → Variables: `API_BASE_URL` = публичный **HTTPS** URL API с `/api`.
4. На API разрешите origin `https://ВАШ-ЛОГИН.github.io` (без подкаталога репозитория).
5. Запустите workflow или отправьте изменение в main.
6. Впишите опубликованный URL в отчёт, проверьте вход, внутреннюю ссылку и обновление страницы.

Workflow запускает форматирование, анализатор, тесты и сборку, рассчитывает --base-href по имени репозитория, создаёт 404.html как копию index.html и .nojekyll, публикует Pages artifact. Для репозитория вида user.github.io используется корень `/`. С HTTP API опубликованный HTTPS-клиент не заработает из-за mixed content. Node-сервер нельзя разместить на GitHub Pages: он требует отдельного хостинга. До настройки HTTPS API workflow намеренно завершается с понятным сообщением, а не публикует заведомо неработающий клиент.

## Отчёт и скриншоты

DOCX с окончанием «места для скриншотов» содержит описание и измерения, но не фрагменты кода. В нём указано, что открыть и где сделать снимок. Подробный чек-лист — `report/СКРИНШОТЫ.md`. Публичная ссылка и подтверждение GitHub-публикации остаются пустыми до настройки пользователем.
