
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class AuthApi {
  final String baseUrl;
  final TokenStore tokens;

  static const _timeout = Duration(seconds: 8);

  AuthApi(this.baseUrl, this.tokens);

  Future<Result<void>> login(
      String email,
      String password,
      ) {
    return _authenticate('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Result<void>> register(
      String email,
      String password,
      String name,
      ) {
    return _authenticate('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  Future<Result<void>> _authenticate(
      String path,
      Map<String, Object?> body,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        return Err(apiMessage(response));
      }

      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      final token = data['token'] as String;

      if (token.isEmpty) {
        return const Err('Сервер не вернул токен');
      }

      await tokens.save(token);

      return const Ok<void>(null);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return const Err('Не удалось подключиться к серверу');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Некорректный ответ сервера');
    } on TypeError {
      return const Err('Некорректный ответ сервера');
    }
  }

  Future<void> logout() async {
    await tokens.clear();
  }
}
