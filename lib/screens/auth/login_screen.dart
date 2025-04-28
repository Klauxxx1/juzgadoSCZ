// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
              if (authProvider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    authProvider.error!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                child:
                    authProvider.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Iniciar Sesión'),
                onPressed:
                    authProvider.isLoading
                        ? null
                        : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await authProvider.login(
                              email,
                              password,
                            );

                            if (success) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          }
                        },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
