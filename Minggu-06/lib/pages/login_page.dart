import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_errors.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final form = GlobalKey<FormState>();
  bool obscure = true;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authStateProvider.notifier).login(email.text, password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2369F5),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        CupertinoIcons.bell_fill,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'Satu tempat.\nSemua kabar kampus.',
                      style: TextStyle(
                        fontSize: 34,
                        height: 1.14,
                        letterSpacing: -1.2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171B27),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Masuk untuk melihat pengumuman\ndan informasi penting untukmu.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF7A8091),
                      ),
                    ),
                    const SizedBox(height: 38),
                    TextFormField(
                      key: const Key('email'),
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'Email kampus',
                        prefixIcon: Icon(CupertinoIcons.mail),
                      ),
                      validator: (value) => (value?.contains('@') ?? false)
                          ? null
                          : 'Masukkan email yang valid.',
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('password'),
                      controller: password,
                      obscureText: obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) {
                        if (!auth.isLoading) login();
                      },
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        prefixIcon: const Icon(CupertinoIcons.lock),
                        suffixIcon: IconButton(
                          tooltip: obscure
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? CupertinoIcons.eye
                                : CupertinoIcons.eye_slash,
                          ),
                        ),
                      ),
                      validator: (value) => (value?.length ?? 0) >= 6
                          ? null
                          : 'Minimal 6 karakter.',
                    ),
                    if (auth.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          friendlyApiError(auth.error!),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('login'),
                      onPressed: auth.isLoading ? null : login,
                      child: auth.isLoading
                          ? const CupertinoActivityIndicator()
                          : const Text('Masuk'),
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        'CAMPUS  /  POLINEMA',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF989DAB),
                        ),
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
