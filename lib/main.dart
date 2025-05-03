// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/providers/seguimiento_provider.dart';
import 'package:si2/providers/notificacion_provider.dart';
import 'package:si2/providers/usuario_provider.dart';
import 'package:si2/screens/auth/login_screen.dart';
import 'package:si2/screens/auth/recover_password_screen.dart';
import 'package:si2/screens/auth/role_selection_screen.dart';
import 'package:si2/screens/admin/usuario_detalle_screen.dart';
import 'package:si2/screens/admin/usuario_form_screen.dart';
import 'package:si2/screens/admin/usuarios_admin_screen.dart';
import 'package:si2/screens/expediente/expediente_list_screen.dart';
import 'package:si2/screens/home/home_screen.dart';
import 'package:si2/screens/perfil/perfil_screen.dart';
import 'package:si2/screens/admin/expedientes_admin_screen.dart';
import 'package:si2/screens/admin/expediente_form_screen.dart';
import 'package:si2/screens/admin/expediente_detalle_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UsuarioProvider>(
          create: (_) => UsuarioProvider(null),
          update: (_, auth, __) => UsuarioProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExpedienteProvider>(
          create: (_) => ExpedienteProvider(null),
          update: (_, auth, __) => ExpedienteProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SeguimientoProvider>(
          create: (_) => SeguimientoProvider(null),
          update: (_, auth, __) => SeguimientoProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificacionProvider>(
          create: (_) => NotificacionProvider(null),
          update: (_, auth, __) => NotificacionProvider(auth),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Legal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFB71C1C),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFB71C1C),
          secondary: Color(0xFF1565C0),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFB71C1C),
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/recuperar-contrasena': (context) => const RecoverPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/perfil': (context) => PerfilScreen(),

        // Rutas de administración de usuarios
        '/admin/usuarios': (context) => UsuariosAdminScreen(),
        '/admin/usuarios/crear': (context) => CrearUsuarioScreen(),
        '/admin/usuarios/editar': (context) => EditarUsuarioScreen(),
        '/admin/usuarios/detalle': (context) => DetalleUsuarioScreen(),

        // Rutas de administración de expedientes
        '/admin/expedientes': (context) => ExpedientesAdminScreen(),
        '/admin/expedientes/crear': (context) => ExpedienteFormScreen(),
        '/admin/expedientes/editar':
            (context) =>
                ExpedienteFormScreen(), // La misma pantalla para editar
        '/admin/expedientes/detalle': (context) => ExpedienteDetalleScreen(),

        // Ruta de roles y permisos (implementar esta pantalla también)
        //'/admin/roles': (context) => RolesPermisosScreen(),

        // Rutas de expedientes
        '/expedientes': (context) => ExpedienteListScreen(),
        '/expedientes/detalle': (context) => ExpedienteDetalleScreen(),
        '/expedientes/abogado':
            (context) => ExpedienteListScreen(), // La misma pantalla se adapta
        // Asegúrate de tener también:
        //  '/seguimientos/crear': (context) => SeguimientoCreateScreen(),
        //  '/audiencias/detalle': (context) => AudienciaDetailScreen(),
      },
    );
  }
}
