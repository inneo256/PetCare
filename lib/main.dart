import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_api.dart';
import 'data/token_store.dart';
import 'data/http_pet_repository.dart';
import 'data/pet_repository.dart';
import 'data/file_api.dart';
import 'router.dart';

const apiBase = 'http://10.0.2.2:8080';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null;

  initRouter(loggedIn);

  final repository = HttpPetRepository(
    apiBase,
    tokens,
    onUnauthorized: () {
      appRouter.go('/login');
    },
  );

  final fileApi = FileApi(
    apiBase,
    tokens,
    onUnauthorized: () {
      appRouter.go('/login');
    },
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStore>.value(value: tokens),

        Provider<AuthApi>(create: (_) => AuthApi(apiBase, tokens)),

        Provider<PetRepository>.value(value: repository),

        Provider<FileApi>.value(value: fileApi),
      ],
      child: const PetCareApp(),
    ),
  );
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PetCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
