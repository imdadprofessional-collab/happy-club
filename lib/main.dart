import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/root/root_shell.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const HappyClubApp());
}

class HappyClubApp extends StatefulWidget {
  const HappyClubApp({super.key});

  @override
  State<HappyClubApp> createState() => _HappyClubAppState();
}

class _HappyClubAppState extends State<HappyClubApp> {
  AppState? _appState;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final storage = await StorageService.create();
    final appState = AppState(storage: storage);
    await appState.init();
    if (!mounted) return;
    setState(() => _appState = appState);
  }

  @override
  Widget build(BuildContext context) {
    if (_appState == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _SplashScreen(),
      );
    }
    return ChangeNotifierProvider.value(
      value: _appState!,
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'Happy Club',
            debugShowCheckedModeBanner: false,
            themeMode: appState.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: appState.onboardingComplete
                ? const RootShell()
                : const OnboardingFlow(),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: AppColors.heroGradient),
              ),
              alignment: Alignment.center,
              child: const Text('😊', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Happy Club',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.lightOnSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
