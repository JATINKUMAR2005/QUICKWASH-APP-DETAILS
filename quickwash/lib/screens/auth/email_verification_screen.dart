import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/video_background.dart';
import '../../widgets/animated_laundry_logo.dart';
import '../../services/local_database.dart';
import 'sign_in_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  String? _message;

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });

    final appState = AppState();
    await appState.refreshSession();

    final user = appState.supabase.auth.currentUser;
    final isConfirmed = user?.emailConfirmedAt != null;

    setState(() => _isChecking = false);

    if (isConfirmed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email confirmed successfully! Welcome to QuickWash.'),
            backgroundColor: Colors.green,
          ),
        );
        // main.dart will automatically rebuild and route to HomeShell or CompleteProfileScreen
      }
    } else {
      setState(() {
        _message = 'Email is still unverified. Please check your inbox and click the activation link!';
      });
    }
  }

  void _handleLogout() async {
    await AppState().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = AppState().supabase.auth.currentUser?.email ?? 'your email';

    return VideoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AnimatedLaundryLogo(),
                  const SizedBox(height: 12),
                  Text(
                    'QuickWash Security',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      shadows: [
                        Shadow(
                          color: AppColors.secondary.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Verify Your Email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We've sent a verification link to:\n$email",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (_message != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error, fontSize: 13, height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        const Icon(
                          Icons.mark_email_read_outlined,
                          color: AppColors.secondary,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Once you have clicked the link inside your email, click the button below to continue.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlassButton(
                          label: _isChecking ? 'Checking status...' : 'I have verified  →',
                          onPressed: _isChecking ? null : _checkVerification,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GlassButton(
                          label: 'Log out / Change Email',
                          outlined: true,
                          onPressed: _handleLogout,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
