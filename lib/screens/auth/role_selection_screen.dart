// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bienvenido al Sistema Legal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFB71C1C),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Elige tu tipo de cuenta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /* _buildRoleCard(
                      context: context,
                      role: 'Administrador',
                      icon: Icons.admin_panel_settings,
                      description: 'Gestiona todos los aspectos del sistema',
                    ),*/
                    _buildRoleCard(
                      context: context,
                      role: 'Juez',
                      icon: Icons.gavel,
                      description: 'Maneja casos y audiencias',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRoleCard(
                      context: context,
                      role: 'Abogado',
                      icon: Icons.work,
                      description: 'Representa a los clientes',
                    ),
                    _buildRoleCard(
                      context: context,
                      role: 'Cliente',
                      icon: Icons.person,
                      description: 'Consulta el estado de tu caso',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextButton(
                  onPressed: () {
                    // Navegar a pantalla de recuperación de contraseña
                    Navigator.pushNamed(context, '/recuperar-contrasena');
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Color(0xFF1565C0), fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String role,
    required IconData icon,
    required String description,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Al seleccionar un rol, navega a la pantalla de login con el rol seleccionado
          Navigator.pushNamed(context, '/login', arguments: {'role': role});
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 48, color: Color(0xFFB71C1C)),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  role.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
