import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/screens/home_screen.dart';
import 'package:task_management_app/utils/navigate_with_animation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.autoCheckLogin = true});

  final bool autoCheckLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoCheckLogin) {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && mounted) {
      navigateAndReplaceWithAnimation(context, const HomeScreen());
    }
    setState(() => _isLoading = false);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', _emailController.text);

        if (mounted) {
          navigateAndReplaceWithAnimation(context, const HomeScreen());
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Task Management Login',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
              : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.task_alt_rounded,
                          size: 80,
                          color: Colors.teal,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome Back!',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.teal),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          cursorColor: Colors.teal,
                          cursorErrorColor: Colors.red,
                          controller: _emailController,
                          decoration: _inputDecoration('Email', Icons.email),
                          validator: (value) {
                            if (value == null ||
                                !value.contains('@') ||
                                !value.contains('.')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          cursorColor: Colors.teal,
                          cursorErrorColor: Colors.red,
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _inputDecoration('Password', Icons.lock),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _login,
                            icon: const Icon(Icons.login, color: Colors.white),
                            label:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal),
      floatingLabelStyle: const TextStyle(color: Colors.teal),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
