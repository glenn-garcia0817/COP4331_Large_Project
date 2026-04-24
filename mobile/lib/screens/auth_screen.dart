import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/auth_service.dart';

// The auth screen manages its own view state internally so the
// home screen only needs to know: "did a user log in or not?"

enum _View { login, register, verificationPending, forgotPassword, forgotSent }

class AuthScreen extends StatefulWidget {
  final void Function(UserProfile user) onLogin;
  const AuthScreen({super.key, required this.onLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _View _view = _View.login;
  bool _loading = false;
  String _pendingMessage = '';
  String _forgotSentMessage = '';

  // Login
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _loginKey = GlobalKey<FormState>();
  bool _loginPwVisible = false;

  // Register
  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPassword = TextEditingController();
  final _regConfirm = TextEditingController();
  final _regKey = GlobalKey<FormState>();
  bool _regPwVisible = false;
  bool _regConfirmVisible = false;

  // Forgot password
  final _forgotEmail = TextEditingController();
  final _forgotKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final c in [
      _loginEmail, _loginPassword,
      _regName, _regEmail, _regPassword, _regConfirm,
      _forgotEmail,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _login() async {
    if (!_loginKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await AuthService.login(
      email: _loginEmail.text.trim(),
      password: _loginPassword.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      widget.onLogin(result.user!);
    } else {
      _showError(result.error!);
    }
  }

  Future<void> _register() async {
    if (!_regKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await AuthService.register(
      name: _regName.text.trim(),
      email: _regEmail.text.trim(),
      password: _regPassword.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.needsVerification) {
      setState(() {
        _pendingMessage = result.message!;
        _view = _View.verificationPending;
      });
    } else if (result.isSuccess) {
      // Server issued token immediately (e.g. verification disabled)
      widget.onLogin(result.user!);
    } else {
      _showError(result.error!);
    }
  }

  Future<void> _forgotPassword() async {
    if (!_forgotKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await AuthService.forgotPassword(_forgotEmail.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      setState(() {
        _forgotSentMessage = result.message!;
        _view = _View.forgotSent;
      });
    } else {
      _showError(result.error!);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GarnishColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _view != _View.login
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => setState(() => _view = _View.login),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _buildView(),
          ),
        ),
      ),
    );
  }

  Widget _buildView() {
    switch (_view) {
      case _View.login:
        return _LoginView(
          key: const ValueKey('login'),
          emailCtrl: _loginEmail,
          passwordCtrl: _loginPassword,
          formKey: _loginKey,
          pwVisible: _loginPwVisible,
          onTogglePw: () => setState(() => _loginPwVisible = !_loginPwVisible),
          loading: _loading,
          onSubmit: _login,
          onGoRegister: () => setState(() => _view = _View.register),
          onForgotPassword: () => setState(() => _view = _View.forgotPassword),
        );
      case _View.register:
        return _RegisterView(
          key: const ValueKey('register'),
          nameCtrl: _regName,
          emailCtrl: _regEmail,
          passwordCtrl: _regPassword,
          confirmCtrl: _regConfirm,
          formKey: _regKey,
          pwVisible: _regPwVisible,
          confirmVisible: _regConfirmVisible,
          onTogglePw: () => setState(() => _regPwVisible = !_regPwVisible),
          onToggleConfirm: () =>
              setState(() => _regConfirmVisible = !_regConfirmVisible),
          loading: _loading,
          onSubmit: _register,
          onGoLogin: () => setState(() => _view = _View.login),
        );
      case _View.verificationPending:
        return _VerificationPendingView(
          key: const ValueKey('pending'),
          message: _pendingMessage,
          onGoLogin: () => setState(() => _view = _View.login),
        );
      case _View.forgotPassword:
        return _ForgotPasswordView(
          key: const ValueKey('forgot'),
          emailCtrl: _forgotEmail,
          formKey: _forgotKey,
          loading: _loading,
          onSubmit: _forgotPassword,
          onGoLogin: () => setState(() => _view = _View.login),
        );
      case _View.forgotSent:
        return _ForgotSentView(
          key: const ValueKey('forgotSent'),
          message: _forgotSentMessage,
          onGoLogin: () => setState(() => _view = _View.login),
        );
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// View: Login
// ══════════════════════════════════════════════════════════════════════════════

class _LoginView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final GlobalKey<FormState> formKey;
  final bool pwVisible;
  final VoidCallback onTogglePw;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onGoRegister;
  final VoidCallback onForgotPassword;

  const _LoginView({
    super.key,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.formKey,
    required this.pwVisible,
    required this.onTogglePw,
    required this.loading,
    required this.onSubmit,
    required this.onGoRegister,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _AuthHeading('Welcome back.'),
        const SizedBox(height: 6),
        _AuthSubheading('Log in to your Garnish account.'),
        const SizedBox(height: 28),
        _AuthCard(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Email'),
                _Field(
                  controller: emailCtrl,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your email' : null,
                ),
                const SizedBox(height: 16),
                _Label('Password'),
                _Field(
                  controller: passwordCtrl,
                  hint: '••••••••',
                  obscure: !pwVisible,
                  suffix: _EyeButton(visible: pwVisible, onTap: onTogglePw),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your password' : null,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
            child: Text(
              'Forgot password?',
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: GarnishColors.orange),
            ),
          ),
        ),
        const SizedBox(height: 4),
        _PrimaryButton(
          label: loading ? 'Logging in…' : 'Log In',
          onPressed: loading ? null : onSubmit,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account? ",
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: GarnishColors.textMid)),
            GestureDetector(
              onTap: onGoRegister,
              child: Text('Create one',
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: GarnishColors.orange,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// View: Register
// ══════════════════════════════════════════════════════════════════════════════

class _RegisterView extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final GlobalKey<FormState> formKey;
  final bool pwVisible;
  final bool confirmVisible;
  final VoidCallback onTogglePw;
  final VoidCallback onToggleConfirm;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onGoLogin;

  const _RegisterView({
    super.key,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.formKey,
    required this.pwVisible,
    required this.confirmVisible,
    required this.onTogglePw,
    required this.onToggleConfirm,
    required this.loading,
    required this.onSubmit,
    required this.onGoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _AuthHeading('Create an account.'),
        const SizedBox(height: 6),
        _AuthSubheading('You\'ll receive a verification email before you can log in.'),
        const SizedBox(height: 28),
        _AuthCard(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Full Name'),
                _Field(
                  controller: nameCtrl,
                  hint: 'Jane Smith',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                _Label('Email'),
                _Field(
                  controller: emailCtrl,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your email';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _Label('Password'),
                _Field(
                  controller: passwordCtrl,
                  hint: 'At least 8 characters',
                  obscure: !pwVisible,
                  suffix: _EyeButton(visible: pwVisible, onTap: onTogglePw),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 8) return 'At least 8 characters required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _Label('Confirm Password'),
                _Field(
                  controller: confirmCtrl,
                  hint: '••••••••',
                  obscure: !confirmVisible,
                  suffix:
                      _EyeButton(visible: confirmVisible, onTap: onToggleConfirm),
                  validator: (v) =>
                      v != passwordCtrl.text ? 'Passwords do not match' : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: loading ? 'Creating account…' : 'Create Account',
          onPressed: loading ? null : onSubmit,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Already have an account? ',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: GarnishColors.textMid)),
            GestureDetector(
              onTap: onGoLogin,
              child: Text('Log in',
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: GarnishColors.orange,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// View: Verification pending
// ══════════════════════════════════════════════════════════════════════════════

class _VerificationPendingView extends StatelessWidget {
  final String message;
  final VoidCallback onGoLogin;

  const _VerificationPendingView({
    super.key,
    required this.message,
    required this.onGoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _AuthHeading('Check your inbox.'),
        const SizedBox(height: 12),
        _AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: GarnishColors.textMid,
                    height: 1.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Once you have verified your email, return here to log in.',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: GarnishColors.textLight,
                    height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(label: 'Go to Log In', onPressed: onGoLogin),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// View: Forgot password
// ══════════════════════════════════════════════════════════════════════════════

class _ForgotPasswordView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final GlobalKey<FormState> formKey;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onGoLogin;

  const _ForgotPasswordView({
    super.key,
    required this.emailCtrl,
    required this.formKey,
    required this.loading,
    required this.onSubmit,
    required this.onGoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _AuthHeading('Reset your password.'),
        const SizedBox(height: 6),
        _AuthSubheading(
            'Enter the email address associated with your account. If it exists, we\'ll send a reset link.'),
        const SizedBox(height: 28),
        _AuthCard(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Email'),
                _Field(
                  controller: emailCtrl,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter your email' : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: loading ? 'Sending…' : 'Send Reset Link',
          onPressed: loading ? null : onSubmit,
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: onGoLogin,
            child: Text('Back to log in',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: GarnishColors.textMid)),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// View: Forgot password — confirmation sent
// ══════════════════════════════════════════════════════════════════════════════

class _ForgotSentView extends StatelessWidget {
  final String message;
  final VoidCallback onGoLogin;

  const _ForgotSentView({
    super.key,
    required this.message,
    required this.onGoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _AuthHeading('Email sent.'),
        const SizedBox(height: 12),
        _AuthCard(
          child: Text(
            message,
            style: GoogleFonts.dmSans(
                fontSize: 14, color: GarnishColors.textMid, height: 1.6),
          ),
        ),
        const SizedBox(height: 24),
        _PrimaryButton(label: 'Back to Log In', onPressed: onGoLogin),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared small components
// ══════════════════════════════════════════════════════════════════════════════

class _AuthHeading extends StatelessWidget {
  final String text;
  const _AuthHeading(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: GarnishColors.textDark,
          height: 1.2,
        ),
      );
}

class _AuthSubheading extends StatelessWidget {
  final String text;
  const _AuthSubheading(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textLight, height: 1.5),
      );
}

class _AuthCard extends StatelessWidget {
  final Widget child;
  const _AuthCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GarnishColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GarnishColors.border),
        ),
        child: child,
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GarnishColors.textDark),
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textLight),
          suffixIcon: suffix,
        ),
      );
}

class _EyeButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;
  const _EyeButton({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: GarnishColors.textLight,
          size: 20,
        ),
        onPressed: onTap,
      );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _PrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: GarnishColors.orange,
            foregroundColor: GarnishColors.white,
            disabledBackgroundColor: GarnishColors.orange.withOpacity(0.5),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: GarnishColors.white),
          ),
        ),
      );
}
