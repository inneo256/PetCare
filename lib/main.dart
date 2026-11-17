
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/pet_model.dart';
import 'router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PetModel(),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
