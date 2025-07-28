// lib/screens/auth_wrapper.dart
// Pantalla Wraper que verifica el estaado de autenticación del usuario

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras se determina el estado de autenticación, muestra un loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si el usuario está autenticado
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Si no hay usuario autenticado
        return const LoginScreen();
      },
    );
  }
}
