import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _rememberMe = true;
  String? _savedEmail;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedEmail = prefs.getString('saved_email');
      if (_savedEmail != null) {
        _emailController.text = _savedEmail!;
      }
    });
  }

  Future<void> _saveEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe && _emailController.text.isNotEmpty) {
      await prefs.setString('saved_email', _emailController.text.trim());
    } else {
      await prefs.remove('saved_email');
    }
  }

  Future<void> _login() async {
    developer.log('Botón de iniciar sesión presionado');
    final authService = Provider.of<AuthService>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await authService.setPersistence(_rememberMe);
        final user = await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        developer.log('Resultado login: $user');

        // Save email if remember me is checked
        await _saveEmail();

        if (user == null) {
          setState(() {
            _errorMessage = 'Email o contraseña incorrectos. Inténtalo de nuevo.';
          });
        }
      } catch (e, stack) {
        developer.log('Error al iniciar sesión: $e');
        developer.log('Stacktrace: $stack');
        setState(() {
          _errorMessage = 'Error al iniciar sesión: $e';
        });
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  void _showPasswordResetDialog() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar contraseña'),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(
              labelText: 'Ingresa tu email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authService.sendPasswordResetEmail(resetEmailController.text);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Correo de recuperación enviado')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al enviar correo')),
                    );
                  }
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text(
                  'Iniciar Sesión',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@'))
                      ? 'Ingresa un correo válido'
                      : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                  validator: (value) => (value == null || value.length < 6)
                      ? 'La contraseña debe tener al menos 6 caracteres'
                      : null,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? true;
                        });
                      },
                    ),
                    const Text('Recordarme'),
                    const Spacer(),
                    Flexible(
                      child: TextButton(
                        onPressed: _showPasswordResetDialog,
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          child: const Text('Iniciar Sesión'),
                        ),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _navigateToRegister,
                  child: const Text('¿No tienes cuenta? Regístrate aquí'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
