import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/bioagent_selection_screen.dart';
import 'screens/mission_preview_screen.dart';
import 'screens/mission_execution_screen.dart';
import 'screens/mission_report_screen.dart';
import 'screens/help_screen.dart';
import 'providers/mission_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Принудительная горизонтальная ориентация
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const BioDropApp());
}

class BioDropApp extends StatelessWidget {
  const BioDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MissionProvider()),
      ],
      child: MaterialApp.router(
        title: 'BIO_DROP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: const Color(0xFF4CAF50),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/mode-selection',
      builder: (context, state) => const ModeSelectionScreen(),
    ),
    GoRoute(
      path: '/bioagent-selection',
      builder: (context, state) => const BioagentSelectionScreen(),
    ),
    GoRoute(
      path: '/mission-preview',
      builder: (context, state) => const MissionPreviewScreen(),
    ),
    GoRoute(
      path: '/mission-execution',
      builder: (context, state) => const MissionExecutionScreen(),
    ),
    GoRoute(
      path: '/mission-report',
      builder: (context, state) => const MissionReportScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
  ],
);
