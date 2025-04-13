import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                    'Smart Cart Judicial',
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
            _buildDrawerItem(context, Icons.event, 'Audiencias', '/audiencias'),
            _buildDrawerItem(
              context,
              Icons.insert_drive_file,
              'Documentos',
              '/documentos',
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
                await FirebaseAuth.instance.signOut();
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
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}
