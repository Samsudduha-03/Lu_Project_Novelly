import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../main_page/discover.dart';
import '../main_page/writer_profile.dart';

const Color _ink = Color(0xFF102F36);
const Color _gold = Color(0xFFC99A55);
const Color _muted = Color(0xFF777873);
const Color _line = Color(0xFFD4D0C6);
const Color _paper = Color(0xFFF6F3EA);
const List<String> _accountTypes = [
  'Writer',
  'Publisher',
  'Cover Artist',
  'Writer and Publisher',
];
const String _passwordCharacters =
    'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#\$%';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _accountType;
  late String _passwordSuggestion;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _acceptedTerms = true;

  @override
  void initState() {
    super.initState();
    _passwordSuggestion = _makePasswordSuggestion();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _makePasswordSuggestion() {
    final random = math.Random.secure();
    return List.generate(
      12,
      (_) => _passwordCharacters[random.nextInt(_passwordCharacters.length)],
    ).join();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _register() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (!_acceptedTerms) {
      _showMessage('Please agree to the Terms of Service and Privacy Policy.');
      return;
    }
    WriterProfileScreen.currentUser = WriterProfile(
      name: _nameController.text.trim(),
      isWriter:
          _accountType == 'Writer' || _accountType == 'Writer and Publisher',
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DiscoverScreen()),
      (route) => false,
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
                              child: FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                style: FilledButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: const Color(0xFFE9E5DB),
                                  foregroundColor: _ink,
                                  shape: const CircleBorder(),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Join Novelly and start connecting',
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
                                const _FieldLabel('Full Name'),
                                const SizedBox(height: 7),
                                TextFormField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  decoration: _inputDecoration(
                                    hint: 'Enter your full name',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) =>
                                      (value?.trim().isEmpty ?? true)
                                      ? 'Please enter your full name'
                                      : null,
                                ),
                                const SizedBox(height: 18),
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
                                const _FieldLabel('Register as'),
                                const SizedBox(height: 7),
                                DropdownButtonFormField<String>(
                                  initialValue: _accountType,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: _muted,
                                  ),
                                  decoration: _inputDecoration(
                                    hint: 'Choose who u are',
                                    icon: Icons.work_outline,
                                  ),
                                  items: _accountTypes
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (type) =>
                                      setState(() => _accountType = type),
                                  validator: (type) =>
                                      type == null ? 'Choose who u are' : null,
                                ),
                                const SizedBox(height: 18),
                                const _FieldLabel('Password'),
                                const SizedBox(height: 7),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_passwordVisible,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onTap: () {
                                    if (_passwordController.text.isEmpty) {
                                      _passwordController
                                        ..text = _passwordSuggestion
                                        ..selection = TextSelection.collapsed(
                                          offset: _passwordSuggestion.length,
                                        );
                                    }
                                  },
                                  decoration: _inputDecoration(
                                    hint: _passwordSuggestion,
                                    icon: Icons.lock_outline,
                                    suffix: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
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
                                        IconButton(
                                          onPressed: () => setState(
                                            () => _passwordSuggestion =
                                                _makePasswordSuggestion(),
                                          ),
                                          color: _muted,
                                          tooltip: 'Suggest another password',
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 19,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  validator: (value) => (value?.isEmpty ?? true)
                                      ? 'Please enter a password'
                                      : value!.length < 8
                                      ? 'Use at least 8 characters'
                                      : null,
                                ),
                                const SizedBox(height: 18),
                                const _FieldLabel('Confirm Password'),
                                const SizedBox(height: 7),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_confirmPasswordVisible,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onFieldSubmitted: (_) => _register(),
                                  decoration: _inputDecoration(
                                    hint: 'Confirm your password',
                                    icon: Icons.lock_outline,
                                    suffix: IconButton(
                                      onPressed: () => setState(
                                        () => _confirmPasswordVisible =
                                            !_confirmPasswordVisible,
                                      ),
                                      color: _muted,
                                      tooltip: _confirmPasswordVisible
                                          ? 'Hide password'
                                          : 'Show password',
                                      icon: Icon(
                                        _confirmPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (value) => setState(
                                    () => _acceptedTerms = value ?? false,
                                  ),
                                  activeColor: _ink,
                                  side: const BorderSide(color: _line),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        'I agree to the ',
                                        style: TextStyle(
                                          color: _ink,
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                      _termsLink(
                                        'Terms of Service',
                                        'Terms of Service will be available soon.',
                                      ),
                                      const Text(
                                        ' and ',
                                        style: TextStyle(
                                          color: _ink,
                                          fontSize: 14,
                                        ),
                                      ),
                                      _termsLink(
                                        'Privacy Policy',
                                        'Privacy Policy will be available soon.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: _register,
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
                              child: const Text('Register'),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(color: _ink, fontSize: 14),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF9C641D),
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Login',
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

  Widget _termsLink(String label, String message) {
    return TextButton(
      onPressed: () => _showMessage(message),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF9C641D),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 14),
      ),
      child: Text(label),
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
