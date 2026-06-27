import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/video_background.dart';
import '../../widgets/animated_laundry_logo.dart';
import '../../services/local_database.dart';
import 'sign_in_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-populate user details if they exist from third-party provider or default profile values
    final user = AppState().currentUser;
    if (user != null) {
      final nameVal = user['name'] as String? ?? '';
      if (nameVal != 'Guest User') {
        _nameController.text = nameVal;
      }
      _emailController.text = user['email'] as String? ?? '';
      _addressController.text = user['address'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || email.isEmpty || address.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all details.');
      return;
    }

    if (name == 'Guest User') {
      setState(() => _errorMessage = 'Please provide your actual name.');
      return;
    }

    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AppState().updateUserProfile(
      name: name,
      email: email,
      address: address,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile completed successfully! Welcome to QuickWash.'),
            backgroundColor: Colors.green,
          ),
        );
        // main.dart will automatically rebuild and route to HomeShell
      }
    } else {
      setState(() => _errorMessage = 'Failed to save details. Please try again.');
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
                    'QuickWash onboarding',
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
                  const SizedBox(height: 24),
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please fill in your delivery details to proceed.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        GlassInput(
                          controller: _nameController,
                          hintText: 'Full Name',
                          prefix: const Icon(Icons.person_outline_rounded, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        GlassInput(
                          controller: _emailController,
                          hintText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          prefix: const Icon(Icons.email_outlined, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        GlassInput(
                          controller: _addressController,
                          hintText: 'Complete Delivery Address',
                          maxLines: 3,
                          prefix: const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),
                        GlassButton(
                          label: _isLoading ? 'Saving...' : 'Save & Continue  →',
                          onPressed: _isLoading ? null : _handleSave,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _handleLogout,
                          child: const Text(
                            'Log Out / Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
