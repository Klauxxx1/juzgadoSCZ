import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/widgets/common/app_drawer.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración '),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido(a), ${user?.nombre}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildAdminCard(
                    context,
                    'Usuarios',
                    Icons.people,
                    '/admin/usuarios',
                    'Gestionar todos los usuarios del sistema',
                  ),
                  _buildAdminCard(
                    context,
                    'Expedientes',
                    Icons.folder,
                    '/admin/expedientes',
                    'Administrar y supervisar todos los expedientes',
                  ),
                  _buildAdminCard(
                    context,
                    'Audiencias',
                    Icons.event,
                    '/admin/audiencias',
                    'Programar y gestionar todas las audiencias',
                  ),
                  _buildAdminCard(
                    context,
                    'Seguimientos',
                    Icons.track_changes,
                    '/admin/seguimientos',
                    'Supervisar tareas y seguimientos de casos',
                  ),
                  _buildAdminCard(
                    context,
                    'Notificaciones',
                    Icons.notifications,
                    '/admin/notificaciones',
                    'Gestionar sistema de notificaciones',
                  ),
                  _buildAdminCard(
                    context,
                    'Configuración',
                    Icons.settings,
                    '/admin/configuracion',
                    'Parámetros generales del sistema',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    String description,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Color(0xFFB71C1C)),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
