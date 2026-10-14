import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main_page/discover.dart';
import 'register.dart';

const Color _ink = Color(0xFF102F36);
const Color _gold = Color(0xFFC99A55);
const Color _muted = Color(0xFF777873);
const Color _line = Color(0xFFD4D0C6);
const Color _paper = Color(0xFFF6F3EA);
const String _googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#4285F4" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#34A853" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.77 7.18l7.73 6c4.51-4.18 7.08-10.34 7.08-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59A14.4 14.4 0 0 1 9.75 24c0-1.59.27-3.12.76-4.59l-7.98-6.19A23.9 23.9 0 0 0 0 24c0 3.87.93 7.52 2.56 10.78l7.97-6.19z"/>
  <path fill="#EA4335" d="M24 48c6.48 0 11.93-2.13 15.91-5.8l-7.73-6c-2.15 1.45-4.92 2.3-8.18 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>
''';

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
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DiscoverScreen()),
      (route) => false,
    );
  }

  void _openRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
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
                                    if (!RegExp(r'^[A-Za-z]').hasMatch(email)) {
                                      return 'Email must start with a letter';
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
                                child: SvgPicture.string(
                                  _googleLogoSvg,
                                  width: 24,
                                  height: 24,
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
