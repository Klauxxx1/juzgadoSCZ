import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/widgets/common/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema de Gestión Judicial'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con saludo personalizado
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido anashe, ${user?.nombre ?? 'Usuario'}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Panel de ${user?.rol ?? 'Usuario'}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Menú principal con accesos rápidos según el rol
            Text(
              'Accesos Rápidos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildAccessButtons(context, user?.rol ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessButtons(BuildContext context, String rol) {
    // Lista de botones que se mostrarán según el rol
    final List<Map<String, dynamic>> buttons = [];

    // Botones comunes a todos los roles
    buttons.add({
      'title': 'Mi Perfil',
      'icon': Icons.person,
      'color': Colors.blue,
      'route': '/perfil',
    });

    // Botones específicos por rol
    switch (rol) {
      case 'Administrador':
        buttons.addAll([
          {
            'title': 'Gestión de Usuarios',
            'icon': Icons.people,
            'color': Colors.purple,
            'route': '/admin/usuarios',
          },
          {
            'title': 'Todos los Expedientes',
            'icon': Icons.folder,
            'color': Colors.orange,
            'route': '/expedientes',
          },
          {
            'title': 'Calendario de Audiencias',
            'icon': Icons.calendar_today,
            'color': Colors.green,
            'route': '/audiencias',
          },
        ]);
        break;
      case 'Juez':
        buttons.addAll([
          {
            'title': 'Mis Expedientes',
            'icon': Icons.gavel,
            'color': Colors.red,
            'route': '/expedientes/juez',
          },
          {
            'title': 'Próximas Audiencias',
            'icon': Icons.event,
            'color': Colors.teal,
            'route': '/audiencias/juez',
          },
        ]);
        break;
      case 'Abogado':
        buttons.addAll([
          {
            'title': 'Mis Casos',
            'icon': Icons.work,
            'color': Colors.indigo,
            'route': '/expedientes/abogado',
          },
          {
            'title': 'Calendario de Audiencias',
            'icon': Icons.calendar_today,
            'color': Colors.amber,
            'route': '/audiencias/abogado',
          },
        ]);
        break;
      case 'Cliente':
        buttons.addAll([
          {
            'title': 'Mis Casos',
            'icon': Icons.description,
            'color': Colors.brown,
            'route': '/expedientes/cliente',
          },
          {
            'title': 'Próximas Audiencias',
            'icon': Icons.event_note,
            'color': Colors.cyan,
            'route': '/audiencias/cliente',
          },
        ]);
        break;
      case 'Asistente':
        buttons.addAll([
          {
            'title': 'Expedientes Asignados',
            'icon': Icons.assignment,
            'color': Colors.deepOrange,
            'route': '/expedientes/asistente',
          },
          {
            'title': 'Tareas Pendientes',
            'icon': Icons.check_circle,
            'color': Colors.lightGreen,
            'route': '/tareas',
          },
        ]);
        break;
    }

    // Construcción de botones en grid
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: buttons.length,
      itemBuilder: (context, index) {
        final button = buttons[index];
        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, button['route']),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(button['icon'], color: button['color'], size: 40),
                SizedBox(height: 10),
                Text(
                  button['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
