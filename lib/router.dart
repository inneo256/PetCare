import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'data/pet_repository.dart';
import 'models/pet_model.dart';

import 'screens/login_screen.dart';
import 'screens/registration_page.dart';
import 'screens/pets_screen.dart';
import 'screens/pet_details_screen.dart';
import 'screens/pet_form_screen.dart';
import 'screens/vet_visit_form_screen.dart';
import 'screens/vaccination_calendar_screen.dart';
import 'screens/profile_screen.dart';

late final GoRouter appRouter;

void initRouter(bool loggedIn) {
  appRouter = GoRouter(
    initialLocation: loggedIn ? '/pets' : '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/registration',
        builder: (context, state) => const RegistrationPage(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ChangeNotifierProvider<PetModel>(
            create: (context) =>
                PetModel(context.read<PetRepository>())..load(),
            child: AppShell(navigationShell: navigationShell),
          );
        },

        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pets',
                builder: (context, state) => const PetsScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const PetFormScreen(),
                  ),

                  GoRoute(
                    path: 'vet-visits/new',
                    builder: (context, state) => const VetVisitFormScreen(),
                  ),

                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);

                      return PetDetailsScreen(id: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);

                          return PetFormScreen(petId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vaccinations',
                builder: (context, state) => const VaccinationCalendarScreen(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
