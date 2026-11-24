import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

/// Преобразование строки базы данных в JSON.
Map<String, Object?> _toJson(Row row) => {
      'id': row['id'],
      'name': row['name'],
      'species': row['species'],
      'birthDate': row['birth_date'],
      'imageUrl': row['image_url'],
      'createdAt': row['created_at'],
    };

/// Поиск питомца только среди питомцев текущего пользователя.
Row? _find(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');

  if (id == null) return null;

  final rows = db.select(
    'SELECT * FROM pets WHERE id = ? AND user_id = ?',
    [id, userId],
  );

  return rows.isEmpty ? null : rows.first;
}

/// GET /pets — список, поиск и пагинация.
Future<Response> listPets(Request request) async {
  final query = request.url.queryParameters;

  final page = max(
    int.tryParse(query['page'] ?? '') ?? 1,
    1,
  );

  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100);

  final search = query['search'] ?? '';

  const where = 'user_id = ? AND (name LIKE ? OR species LIKE ?)';

  final args = [
    currentUserId(request),
    '%$search%',
    '%$search%',
  ];

  final total = db
      .select(
        'SELECT COUNT(*) AS n FROM pets WHERE $where',
        args,
      )
      .first['n'] as int;

  final rows = db.select(
    'SELECT * FROM pets WHERE $where '
    'ORDER BY id DESC LIMIT ? OFFSET ?',
    [...args, limit, (page - 1) * limit],
  );

  return jsonResponse({
    'items': rows.map(_toJson).toList(),
    'page': page,
    'limit': limit,
    'total': total,
  });
}

/// POST /pets — создание питомца.
Future<Response> createPet(Request request) async {
  final body = await readJsonBody(request);

  if (body == null) {
    return validationError('Body must be a JSON object');
  }

  final name = stringField(body, 'name');
  final species = stringField(body, 'species');
  final birthDate = stringField(body, 'birthDate');

  if (name == null) {
    return validationError('name is required');
  }

  if (species == null) {
    return validationError('species is required');
  }

  if (birthDate == null) {
    return validationError('birthDate is required');
  }

  final imageUrl = body['imageUrl'];

  if (imageUrl != null && imageUrl is! String) {
    return validationError('imageUrl must be a string');
  }

  db.execute(
    'INSERT INTO pets '
    '(user_id, name, species, birth_date, image_url, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    [
      currentUserId(request),
      name,
      species,
      birthDate,
      imageUrl,
      nowIso(),
    ],
  );

  final row = _find(
    currentUserId(request),
    '${db.lastInsertRowId}',
  )!;

  return jsonResponse(_toJson(row), status: 201);
}

/// GET /pets/{id} — получение питомца.
Future<Response> getPet(Request request) async {
  final row = _find(
    currentUserId(request),
    request.params['id'],
  );

  if (row == null) {
    return notFound('Pet not found');
  }

  return jsonResponse(_toJson(row));
}

/// PUT /pets/{id} — редактирование питомца.
Future<Response> updatePet(Request request) async {
  final userId = currentUserId(request);

  final row = _find(userId, request.params['id']);

  if (row == null) {
    return notFound('Pet not found');
  }

  final body = await readJsonBody(request);

  if (body == null) {
    return validationError('Body must be a JSON object');
  }

  final name = stringField(body, 'name');
  final species = stringField(body, 'species');
  final birthDate = stringField(body, 'birthDate');

  if (name == null) {
    return validationError('name is required');
  }

  if (species == null) {
    return validationError('species is required');
  }

  if (birthDate == null) {
    return validationError('birthDate is required');
  }

  final imageUrl =
      body.containsKey('imageUrl') ? body['imageUrl'] : row['image_url'];

  if (imageUrl != null && imageUrl is! String) {
    return validationError('imageUrl must be a string');
  }

  db.execute(
    'UPDATE pets SET name = ?, species = ?, '
    'birth_date = ?, image_url = ? '
    'WHERE id = ? AND user_id = ?',
    [
      name,
      species,
      birthDate,
      imageUrl,
      row['id'],
      userId,
    ],
  );

  final updated = _find(userId, '${row['id']}')!;

  return jsonResponse(_toJson(updated));
}

/// DELETE /pets/{id} — удаление питомца.
Future<Response> deletePet(Request request) async {
  final userId = currentUserId(request);

  final row = _find(userId, request.params['id']);

  if (row == null) {
    return notFound('Pet not found');
  }

  db.execute(
    'DELETE FROM pets WHERE id = ? AND user_id = ?',
    [row['id'], userId],
  );

  return Response(204);
}
