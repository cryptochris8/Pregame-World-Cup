import 'package:flutter/material.dart';
import '../../domain/services/auth_service.dart';
import '../../../../injection_container.dart';
import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = sl<AuthService>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoginMode = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLoginMode) {
        await _authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _authService.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: AppTheme.backgroundCard,
          title: Text(
            l10n.forgotPassword,
            style: const TextStyle(color: AppTheme.textWhite),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.enterEmailForReset,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: InputDecoration(
                  labelText: l10n.email,
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.email_rounded, color: AppTheme.primaryOrange),
                  filled: true,
                  fillColor: AppTheme.backgroundElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.send, style: const TextStyle(color: AppTheme.accentGold)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final email = resetEmailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pleaseEnterValidEmail),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      try {
        await _authService.sendPasswordResetEmail(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).resetPasswordSent),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).resetPasswordError),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }

    resetEmailController.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _switchAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Section
                    Container(
                      padding: const EdgeInsets.only(bottom: 60.0),
                      child: Column(
                        children: [
                          // Logo with glow effect
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryOrange.withValues(alpha:0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/logos/pregame_logo.png',
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // App title with gradient text effect
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppTheme.accentGold,
                                AppTheme.primaryOrange,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'PREGAME',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.whereSportsFansConnect,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCard.withValues(alpha:0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.primaryOrange.withValues(alpha:0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Mode Title
                          Text(
                            _isLoginMode ? l10n.welcomeBack : l10n.joinPregame,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textWhite,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: AppTheme.textWhite),
                            decoration: InputDecoration(
                              labelText: l10n.email,
                              labelStyle: const TextStyle(color: AppTheme.textSecondary),
                              hintText: l10n.enterYourEmail,
                              hintStyle: const TextStyle(color: AppTheme.textTertiary),
                              prefixIcon: const Icon(
                                Icons.email_rounded,
                                color: AppTheme.primaryOrange,
                              ),
                              filled: true,
                              fillColor: AppTheme.backgroundElevated.withValues(alpha:0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppTheme.textTertiary.withValues(alpha:0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryOrange,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty || !value.contains('@')) {
                                return l10n.pleaseEnterValidEmail;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(color: AppTheme.textWhite),
                            decoration: InputDecoration(
                              labelText: l10n.password,
                              labelStyle: const TextStyle(color: AppTheme.textSecondary),
                              hintText: l10n.enterYourPassword,
                              hintStyle: const TextStyle(color: AppTheme.textTertiary),
                              prefixIcon: const Icon(
                                Icons.lock_rounded,
                                color: AppTheme.primaryOrange,
                              ),
                              filled: true,
                              fillColor: AppTheme.backgroundElevated.withValues(alpha:0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: AppTheme.textTertiary.withValues(alpha:0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryOrange,
                                  width: 2,
                                ),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.passwordMinLength;
                              }
                              if (!_isLoginMode) {
                                if (value.length < 8 ||
                                    !RegExp(r'[A-Z]').hasMatch(value) ||
                                    !RegExp(r'[0-9]').hasMatch(value) ||
                                    !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                                  return l10n.passwordRequirements;
                                }
                              }
                              return null;
                            },
                          ),

                          // Forgot Password (login mode only)
                          if (_isLoginMode)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  l10n.forgotPassword,
                                  style: const TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                          // Error Message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.errorColor.withValues(alpha:0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.errorColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: AppTheme.errorColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: _isLoading
                                ? Container(
                                    decoration: AppTheme.buttonGradientDecoration,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: AppTheme.buttonGradientDecoration,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      onPressed: _submitAuthForm,
                                      child: Text(
                                        _isLoginMode ? l10n.signIn : l10n.createAccount,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(height: 20),

                          // OR Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  l10n.orContinueWith,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: (_isLoading || _isGoogleLoading)
                                  ? null
                                  : _signInWithGoogle,
                              icon: _isGoogleLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.textWhite,
                                      ),
                                    )
                                  : const Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                              label: Text(
                                l10n.continueWithGoogle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textWhite,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppTheme.textTertiary.withValues(alpha: 0.4),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Switch Mode Button
                          TextButton(
                            onPressed: _switchAuthMode,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 16),
                                children: [
                                  TextSpan(
                                    text: _isLoginMode
                                        ? l10n.dontHaveAccount
                                        : l10n.alreadyHaveAccount,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _isLoginMode ? l10n.signUp : l10n.signIn,
                                    style: const TextStyle(
                                      color: AppTheme.accentGold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 