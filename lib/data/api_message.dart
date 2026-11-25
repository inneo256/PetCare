
import 'dart:convert';

import 'package:http/http.dart' as http;

String apiMessage(http.Response response) {
  String? code;

  try {
    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (data is Map && data['error'] is Map) {
      final error = data['error'] as Map;
      final value = error['code'];

      if (value is String) {
        code = value;
      }
    }
  } on FormatException {
    // Используем HTTP-статус.
  }

  switch (code) {
    case 'EMAIL_TAKEN':
      return 'Этот e-mail уже зарегистрирован';
    case 'UNAUTHORIZED':
      return 'Неверный e-mail или пароль';
    case 'VALIDATION_ERROR':
      return 'Проверьте введённые данные';
    case 'NOT_FOUND':
      return 'Запись не найдена';
  }

  switch (response.statusCode) {
    case 400:
      return 'Проверьте введённые данные';
    case 401:
      return 'Неверный e-mail или пароль';
    case 403:
      return 'Доступ запрещён';
    case 404:
      return 'Запись не найдена';
    case 409:
      return 'Этот e-mail уже зарегистрирован';
    case 413:
      return 'Файл слишком большой';
    default:
      return 'Ошибка сервера (${response.statusCode})';
  }
}
