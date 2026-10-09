import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/pets_screen.dart';
import 'screens/pet_details_screen.dart';
import 'screens/pet_form_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_page.dart';
import 'screens/vaccination_calendar_screen.dart';
import 'screens/vet_visit_form_screen.dart';

void main() {
  runApp(const PetCareApp());
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
        ),
        useMaterial3: true,
      ),
      home: const PetCareHome(),
    );
  }
}

class PetCareHome extends StatelessWidget {
  const PetCareHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetCare'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuButton(
            title: 'Вход',
            icon: Icons.login,
            screen: const LoginScreen(),
          ),
          _MenuButton(
            title: 'Регистрация',
            icon: Icons.person_add_outlined,
            screen: const RegistrationPage(),
          ),
          _MenuButton(
            title: 'Мои питомцы',
            icon: Icons.pets,
            screen: const PetsScreen(),
          ),
          _MenuButton(
            title: 'Карточка питомца',
            icon: Icons.badge_outlined,
            screen: const PetDetailsScreen(),
          ),
          _MenuButton(
            title: 'Новый питомец',
            icon: Icons.add_circle_outline,
            screen: const PetFormScreen(),
          ),
          _MenuButton(
            title: 'Новый визит к ветеринару',
            icon: Icons.medical_services_outlined,
            screen: const VetVisitFormScreen(),
          ),
          _MenuButton(
            title: 'Календарь прививок',
            icon: Icons.vaccines_outlined,
            screen: const VaccinationCalendarScreen(),
          ),
          _MenuButton(
            title: 'Профиль',
            icon: Icons.person_outline,
            screen: const ProfileScreen(),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget screen;

  const _MenuButton({
    required this.title,
    required this.icon,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },
      ),
    );
  }
}