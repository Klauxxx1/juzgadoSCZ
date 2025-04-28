import 'package:flutter/material.dart';
import 'package:si2/services/api_service.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService _apiService = ApiService();

    return Drawer(
      // Mantenemos el mismo contenido pero cambiamos la función de logout
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFB71C1C)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(radius: 30, backgroundColor: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Seguimiento Documental Judicial',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.person, 'Usuario', '/usuario'),
            _buildDrawerItem(
              context,
              Icons.folder,
              'Expedientes',
              '/expedientes',
            ),
            _buildDrawerItem(
              context,
              Icons.track_changes,
              'Seguimiento',
              '/seguimiento',
            ),
            _buildDrawerItem(
              context,
              Icons.notifications,
              'Notificaciones',
              '/notificaciones',
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFB71C1C)),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                // Usamos el nuevo servicio de API
                await _apiService.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String routeName,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFB71C1C)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // cerrar el Drawer primero
        Navigator.pushNamed(context, routeName); // navegar sin reemplazar
      },
    );
  }
}
