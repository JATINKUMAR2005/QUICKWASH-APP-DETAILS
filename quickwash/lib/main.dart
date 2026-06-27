import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/home/home_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_config.dart';
import 'services/local_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization failed: $e');
    }
  }
  
  // Initialize persistence and local database
  final appState = AppState();
  await appState.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const QuickWashApp());
}

class QuickWashApp extends StatelessWidget {
  const QuickWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final isLoggedIn = appState.currentUser != null;

        Widget homeScreen;
        if (!isLoggedIn) {
          homeScreen = const SignInScreen();
        } else {
          // If Supabase is active, check if email is confirmed
          final bool isEmailUnconfirmed = appState.isSupabaseEnabled &&
              appState.supabase.auth.currentUser != null &&
              appState.supabase.auth.currentUser!.emailConfirmedAt == null;

          if (isEmailUnconfirmed) {
            homeScreen = const EmailVerificationScreen();
          } else {
            // Check if profile is complete (needs real Name and Address)
            final name = appState.currentUser?['name'] as String? ?? '';
            final address = appState.currentUser?['address'] as String? ?? '';
            if (name == 'Guest User' || name.trim().isEmpty || address.trim().isEmpty) {
              homeScreen = const CompleteProfileScreen();
            } else {
              homeScreen = const HomeShell();
            }
          }
        }

        return MaterialApp(
          title: 'QuickWash 2.0',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: homeScreen,
        );
      },
    );
  }
}
