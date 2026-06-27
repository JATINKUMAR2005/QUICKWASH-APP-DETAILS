import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../services/local_database.dart';
import '../admin/admin_dashboard_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OtpVerificationScreen({
    super.key,
    this.phoneNumber = '98765 43210',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _countdown = 30;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 4) {
      setState(() => _errorMessage = 'Please enter the 4-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Mock processing verification
    await Future.delayed(const Duration(milliseconds: 800));

    // Sign in the user session in database
    final appState = AppState();
    // Check if the user already exists in db, otherwise create a session for this phone number
    final userFound = await appState.loginUser(widget.phoneNumber, '');
    if (!userFound) {
      // Create a default session for this phone number
      await appState.registerUser(
        name: 'Guest User',
        email: 'user_${widget.phoneNumber}@quickwash.in',
        phone: widget.phoneNumber,
        password: '',
      );
      await appState.loginUser(widget.phoneNumber, '');
    }

    setState(() => _isLoading = false);

    if (mounted) {
      final role = appState.currentUser?['role'] ?? 'customer';
      if (role != 'admin') {
        await appState.logout();
        setState(() {
          _errorMessage = 'Access Denied: Admin role required.';
        });
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
        (route) => false,
      );
    }
  }

  void _handleResend() {
    if (_countdown > 0) return;
    setState(() {
      _countdown = 30;
      _errorMessage = null;
      for (final c in _controllers) {
        c.clear();
      }
    });
    _startCountdown();
    _focusNodes[0].requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully!'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxSize = (screenWidth - 40 - 48 - 36).clamp(40.0, 56.0) / 4 > 14
        ? ((screenWidth - 40 - 48 - 36) / 4).clamp(44.0, 56.0)
        : 48.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF0A1535), Color(0xFF0A0F1E)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Verification card
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Verification',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter the 4-digit code sent to',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+91 ${widget.phoneNumber.length >= 10 ? '${widget.phoneNumber.substring(0, 5)} ${widget.phoneNumber.substring(5)}' : widget.phoneNumber}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // OTP boxes — optimized for fast input
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return Container(
                              width: boxSize,
                              height: boxSize,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _focusNodes[index].hasFocus
                                      ? AppColors.primaryContainer
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: RawKeyboardListener(
                                focusNode: FocusNode(),
                                onKey: (event) {
                                  if (event is RawKeyDownEvent &&
                                      event.logicalKey == LogicalKeyboardKey.backspace &&
                                      _controllers[index].text.isEmpty &&
                                      index > 0) {
                                    _controllers[index - 1].clear();
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  textInputAction: index < 3 ? TextInputAction.next : TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(1),
                                  ],
                                  style: TextStyle(
                                    fontSize: boxSize * 0.44,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.surface,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 1 && index < 3) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                    if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                    // Auto-verify after small delay when all 4 digits entered
                                    if (value.length == 1 && index == 3) {
                                      _focusNodes[index].unfocus();
                                      // Small delay to let the keyboard dismiss smoothly
                                      Future.delayed(const Duration(milliseconds: 200), () {
                                        if (mounted) _handleVerify();
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),
                        GlassButton(
                          label: _isLoading ? 'Verifying...' : 'Verify & Continue',
                          onPressed: _isLoading ? null : _handleVerify,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Didn't receive the code?",
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _countdown == 0 ? _handleResend : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _countdown > 0 ? '$_countdown s' : 'Resend OTP',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _countdown > 0 
                                      ? AppColors.secondary 
                                      : AppColors.primaryContainer,
                                ),
                              ),
                            ],
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
