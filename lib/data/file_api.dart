import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class FileApi {
  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 20);
  static const _maxFileSize = 5 * 1024 * 1024;

  FileApi(this.baseUrl, this.tokens, {this.onUnauthorized});

  Future<Result<String>> upload(String path) async {
    try {
      final file = File(path);

      if (!await file.exists()) {
        return const Err('Файл не найден');
      }

      if (await file.length() > _maxFileSize) {
        return const Err('Размер фотографии не должен превышать 5 МБ');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files'),
      );

      final token = await tokens.read();

      request.headers['Authorization'] = 'Bearer ${token ?? ''}';

      request.files.add(await http.MultipartFile.fromPath('file', path));

      final streamedResponse = await request.send().timeout(_timeout);

      final response = await http.Response.fromStream(streamedResponse)
          .timeout(_timeout);

      if (response.statusCode == 401) {
        await tokens.clear();
        onUnauthorized?.call();

        return const Err('Сессия истекла — войдите снова');
      }

      if (response.statusCode != 201) {
        return Err(apiMessage(response));
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      final url = data['url'] as String;

      if (!RegExp(r'^/files/\d+$').hasMatch(url)) {
        return const Err('Сервер вернул некорректную ссылку');
      }

      return Ok(url);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return const Err('Не удалось подключиться к серверу');
    } on TimeoutException {
      return const Err('Сервер не отвечает — повторите попытку');
    } on FileSystemException {
      return const Err('Не удалось прочитать фотографию');
    } on FormatException {
      return const Err('Некорректный ответ сервера');
    } on TypeError {
      return const Err('Некорректный ответ сервера');
    }
  }
}
