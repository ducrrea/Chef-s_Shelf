

import 'package:chefs_shelf/firebase_options.dart';
import 'package:chefs_shelf/services/auth_service.dart';
import 'package:chefs_shelf/views/home_view.dart';
import 'package:chefs_shelf/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //aqui é onde vamos inicializar o Firebase com as opções específicas da plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ChefsShelfApp());
}

class ChefsShelfApp extends StatelessWidget {
  const ChefsShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chef\'s Shelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

//aqui vai criar o widget que vai verificar se o usuário está logado ou não e direcionar para a tela correta
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Exibe tela de carregamento enquanto verifica se o usuário está logado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //se tiver um usuário logado, direciona para a tela principal
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeView();
        }

        // se nao, direciona para a tela de login
        return const LoginView();
      },
    );
  }
}