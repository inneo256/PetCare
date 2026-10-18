
import 'package:go_router/go_router.dart';

import 'screens/login_screen.dart';
import 'screens/registration_page.dart';
import 'screens/pets_screen.dart';
import 'screens/pet_details_screen.dart';
import 'screens/pet_form_screen.dart';
import 'screens/vet_visit_form_screen.dart';
import 'screens/vaccination_calendar_screen.dart';
import 'screens/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationPage(),
    ),
    GoRoute(
      path: '/pets',
      builder: (context, state) => const PetsScreen(),
    ),

    // Маршрут создания питомца должен стоять перед маршрутом с id.
    GoRoute(
      path: '/pets/new',
      builder: (context, state) => const PetFormScreen(),
    ),
    GoRoute(
      path: '/pets/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PetDetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: '/vet-visits/new',
      builder: (context, state) => const VetVisitFormScreen(),
    ),
    GoRoute(
      path: '/vaccinations',
      builder: (context, state) => const VaccinationCalendarScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
