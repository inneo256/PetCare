# petcare

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## L5 — Backend Integration

Выбранный язык backend: Dart.

Технологии: Dart, Shelf, SQLite.

Запуск сервера:
- cd server
- dart pub get
- dart run

Адрес сервера: http://localhost:8080

Ручное тестирование:
- Health check — успешно.
- Регистрация пользователя — успешно.
- Запрос без JWT — 401 Unauthorized.
- Повторная регистрация — 409 Conflict.
- Авторизованный запрос — 200 OK.
- Создание заметок — успешно.
- Серверный поиск — успешно.

Автоматические conformance-тесты не запускались:
файлы тестов отсутствуют в предоставленных материалах.