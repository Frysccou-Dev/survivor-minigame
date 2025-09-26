import 'package:flutter/material.dart';
import 'screens/survivor_list_screen.dart';
import 'screens/tournament_screens.dart';

void main() {
  runApp(const SurvivorApp());
}

class SurvivorApp extends StatelessWidget {
  const SurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Penka Survivor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFED9320),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: SurvivorListScreen.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SurvivorListScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const SurvivorListScreen(),
            );
          case SurvivorDetailScreen.routeName:
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => SurvivorDetailScreen(survivor: args),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const SurvivorListScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SurvivorListScreen(),
            );
        }
      },
    );
  }
}
