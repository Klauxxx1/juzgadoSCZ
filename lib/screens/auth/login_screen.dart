// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("Error de autenticación: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  register(String email, String password) {}
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Juzgado Dpto. Santa Cruz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Correo electrónico'),
                onChanged: (val) => email = val,
                validator:
                    (val) =>
                        (val == null || val.isEmpty)
                            ? 'Ingresa tu correo'
                            : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator:
                    (val) =>
                        (val == null || val.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child:
                    isLoading
                        ? CircularProgressIndicator(
                          color: const Color.fromARGB(255, 234, 11, 11),
                        )
                        : Text('Iniciar Sesión'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    bool success = await AuthService().signIn(email, password);
                    setState(() => isLoading = false);
                    if (success) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error de autenticación')),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 10),
              TextButton(
                child: Text('¿No tienes cuenta? Regístrate aquí'),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
