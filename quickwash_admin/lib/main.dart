import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
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
  runApp(const QuickWashAdminApp());
}

class QuickWashAdminApp extends StatelessWidget {
  const QuickWashAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AppState().currentUser != null;
    final isAdmin = AppState().currentUser?['role'] == 'admin';

    Widget homeScreen;
    if (!isLoggedIn) {
      homeScreen = const SignInScreen();
    } else if (!isAdmin) {
      // Access Denied! Force logout and sign in
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await AppState().logout();
      });
      homeScreen = const SignInScreen();
    } else {
      homeScreen = const AdminDashboardScreen();
    }

    return MaterialApp(
      title: 'QuickWash Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: homeScreen,
    );
  }
}
