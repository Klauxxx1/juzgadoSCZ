// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        children: [
          // Encabezado con información del usuario
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xFFB71C1C)),
            accountName: Text(
              user?.nombre != null
                  ? '${user?.nombre} ${user?.apellido}'
                  : 'Usuario',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: _getColorForRole(user?.rol ?? ''),
              child: Text(
                _getInitials(user?.nombre ?? '', user?.apellido ?? ''),
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),

          // Opción Inicio
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),

          // Opciones según el rol
          /*if (user?.isAdministrador == true) ...[
            Divider(),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('Panel de Administración'),
              tileColor: Colors.grey[200],
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Gestión de Usuarios'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/usuarios');
              },
            ),
            ListTile(
              leading: Icon(Icons.folder_special),
              title: Text('Gestión de Expedientes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/expedientes');
              },
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts),
              title: Text('Roles y Permisos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin/roles');
              },
            ),
          ],*/

          // Sección de expedientes
          Divider(),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text('Expedientes'),
            onTap: () {
              Navigator.pop(context);
              // Usar una única ruta que maneja todos los roles
              Navigator.pushNamed(context, '/expedientes');
            },
          ),

          // Sección de audiencias
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Audiencias'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                user?.isAdministrador == true
                    ? '/audiencias'
                    : user?.isJuez == true
                    ? '/audiencias/juez'
                    : user?.isAbogado == true
                    ? '/audiencias/abogado'
                    : user?.isAsistente == true
                    ? '/audiencias/asistente'
                    : '/audiencias/cliente',
              );
            },
          ),

          // Sección de seguimientos (excepto clientes)
          if (user?.isCliente == false)
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Seguimientos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/seguimientos');
              },
            ),

          // Notificaciones para todos
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notificaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notificaciones');
            },
          ),

          // Perfil y Cerrar sesión
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Mi Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/perfil');
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Cerrar Sesión'),
            onTap: () async {
              await authProvider.signOut();
              Navigator.pushReplacementNamed(
                context,
                '/',
                arguments: (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  String _getInitials(String nombre, String apellido) {
    return (nombre.isNotEmpty ? nombre[0] : '') +
        (apellido.isNotEmpty ? apellido[0] : '');
  }

  Color _getColorForRole(String role) {
    switch (role) {
      case 'Juez':
        return Colors.red;
      case 'Abogado':
        return Colors.blue;
      case 'Asistente':
        return Colors.green;
      case 'Cliente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
