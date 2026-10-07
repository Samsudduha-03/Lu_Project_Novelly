import 'package:flutter/material.dart';
import 'register.dart';

const Color _ink = Color(0xFF102F36);
const Color _gold = Color(0xFFC99A55);
const Color _muted = Color(0xFF777873);
const Color _line = Color(0xFFD4D0C6);
const Color _paper = Color(0xFFF6F3EA);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      _showMessage('Sign-in is not connected yet.');
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAF8F1), _paper, Color(0xFFEFECE2)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 38,
                              height: 38,
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: const CircleBorder(),
                                  side: const BorderSide(
                                    color: Color(0xFFA9A9A3),
                                  ),
                                  foregroundColor: _ink,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: Image.asset(
                              'assets/images/novelly_logo.png',
                              width: 146,
                              height: 146,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Welcome Back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Sign in to continue your journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF353A39),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 27),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _FieldLabel('Email'),
                                const SizedBox(height: 7),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: _inputDecoration(
                                    hint: 'Enter your email',
                                    icon: Icons.mail_outline,
                                  ),
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    if (email.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!email.contains('@') ||
                                        !email.contains('.')) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                const _FieldLabel('Password'),
                                const SizedBox(height: 7),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _login(),
                                  decoration: _inputDecoration(
                                    hint: 'Enter your password',
                                    icon: Icons.lock_outline,
                                    suffix: IconButton(
                                      onPressed: () => setState(
                                        () => _passwordVisible =
                                            !_passwordVisible,
                                      ),
                                      color: _muted,
                                      tooltip: _passwordVisible
                                          ? 'Hide password'
                                          : 'Show password',
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  validator: (value) => (value?.isEmpty ?? true)
                                      ? 'Please enter your password'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showMessage(
                                'Password reset is not connected yet.',
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: _ink,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Forgot Password?'),
                            ),
                          ),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: _login,
                              style: FilledButton.styleFrom(
                                backgroundColor: _ink,
                                foregroundColor: _gold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Row(
                            children: [
                              Expanded(child: Divider(color: _line)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(color: _muted, fontSize: 13),
                                ),
                              ),
                              Expanded(child: Divider(color: _line)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialButton(
                                onPressed: () => _showMessage(
                                  'Google sign-in is not connected yet.',
                                ),
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Color(0xFF4285F4),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Don’t have an account? ',
                                style: TextStyle(color: _ink, fontSize: 14),
                              ),
                              TextButton(
                                onPressed: _openRegister,
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFF9C641D),
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _muted, fontSize: 14),
      prefixIcon: Icon(icon, size: 20, color: _ink),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.18),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _ink, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _ink,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink,
          side: const BorderSide(color: _line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );
  }
}
