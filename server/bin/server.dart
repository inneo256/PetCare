import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:server/auth.dart';
import 'package:server/db.dart';
import 'package:server/errors.dart';
import 'package:server/files.dart';
import 'package:server/notes.dart';
import 'package:server/pets.dart';

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  initDb('app.db');
  initFileStorage('uploads');

  final router =
      Router(notFoundHandler: (Request r) => notFound('Route not found'))

        // Проверка доступности сервера.
        ..get('/health', (Request r) => jsonResponse({'status': 'ok'}))

        // Авторизация.
        ..post('/auth/register', register)
        ..post('/auth/login', login)
        ..get('/me', requireAuth(me))

        // Заметки — существующий функционал.
        ..get('/notes', requireAuth(listNotes))
        ..post('/notes', requireAuth(createNote))
        ..get('/notes/<id>', requireAuth(getNote))
        ..put('/notes/<id>', requireAuth(updateNote))
        ..delete('/notes/<id>', requireAuth(deleteNote))

        // Питомцы — PetCare.
        ..get('/pets', requireAuth(listPets))
        ..post('/pets', requireAuth(createPet))
        ..get('/pets/<id>', requireAuth(getPet))
        ..put('/pets/<id>', requireAuth(updatePet))
        ..delete('/pets/<id>', requireAuth(deletePet))

        // Загрузка и получение файлов.
        ..post('/files', requireAuth(uploadFile))
        ..get('/files/<id>', downloadFile);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors)
      .addHandler(router.call);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    port,
  );

  print('Backend listening on http://localhost:${server.port}');
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
};

Handler _cors(Handler inner) => (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }

      final response = await inner(request);

      return response.change(headers: _corsHeaders);
    };
