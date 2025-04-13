import 'package:flutter/material.dart';
import 'drawer/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(), // ← esto activa la barra lateral
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Color(0xFFB71C1C),
      ),
      body: const Center(
        child: Text(
          'App para Jueces, Abogados, Asistentes y Secretarios',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
