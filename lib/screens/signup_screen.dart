// lib/screens/signup_screen.dart
// Pantalla de registro de usuario

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _registrarse() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pop(context); // Regresa a la pantalla de inicio de sesión
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al registrarse';
      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está en uso';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo no es válido';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _registrarse,
                    child: const Text('Registrarse'),
                  ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('¿Ya tienes cuenta? Inicia sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
