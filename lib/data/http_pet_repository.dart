import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'pet.dart';
import 'pet_repository.dart';
import 'result.dart';
import 'token_store.dart';

class HttpPetRepository implements PetRepository {
  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  HttpPetRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  Future<Map<String, String>> _headers() async {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer ${await tokens.read() ?? ''}',
    };
  }

  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();

    return 'Сессия истекла — войдите снова';
  }

  Future<Result<T>> _request<T>(
    Future<http.Response> Function() send,
    int expectedStatus,
    T Function(http.Response) decode,
  ) async {
    try {
      final response = await send().timeout(_timeout);

      if (response.statusCode == 401) {
        return Err<T>(await _sessionDied());
      }

      if (response.statusCode != expectedStatus) {
        return Err<T>(apiMessage(response));
      }

      return Ok<T>(decode(response));
    } on SocketException {
      return Err<T>('Нет сети — повторите попытку');
    } on http.ClientException {
      return Err<T>('Не удалось подключиться к серверу');
    } on TimeoutException {
      return Err<T>('Сервер не отвечает');
    } on FormatException {
      return Err<T>('Некорректный ответ сервера');
    } on TypeError {
      return Err<T>('Некорректный ответ сервера');
    }
  }

  @override
  Future<Result<List<Pet>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  }) {
    final uri = Uri.parse('$baseUrl/pets').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    return _request<List<Pet>>(
      () async => http.get(uri, headers: await _headers()),
      200,
      (response) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        final items = data['items'] as List<dynamic>;

        return items
            .map((item) => Pet.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<Result<Pet>> fetchById(int id) {
    return _request<Pet>(
      () async =>
          http.get(Uri.parse('$baseUrl/pets/$id'), headers: await _headers()),
      200,
      (response) => Pet.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Result<Pet>> create(Pet pet) {
    return _request<Pet>(
      () async => http.post(
        Uri.parse('$baseUrl/pets'),
        headers: await _headers(),
        body: jsonEncode(pet.toJson()),
      ),
      201,
      (response) => Pet.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Result<Pet>> update(Pet pet) {
    return _request<Pet>(
      () async => http.put(
        Uri.parse('$baseUrl/pets/${pet.id}'),
        headers: await _headers(),
        body: jsonEncode(pet.toJson()),
      ),
      200,
      (response) => Pet.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Result<void>> delete(int id) {
    return _request<void>(
      () async => http.delete(
        Uri.parse('$baseUrl/pets/$id'),
        headers: await _headers(),
      ),
      204,
      (_) {},
    );
  }
}
