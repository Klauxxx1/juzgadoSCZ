// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/audiencia_provider.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/providers/usuario_provider.dart';
import 'package:si2/screens/audiencia/audiencia_crear_screen.dart';
import 'package:si2/screens/audiencia/audiencia_list_screen.dart';
import 'package:si2/screens/auth/login_screen.dart';
import 'package:si2/screens/auth/recover_password_screen.dart';
import 'package:si2/screens/home/home_screen.dart';
import 'package:si2/screens/notificaciones/notifcaciones_screen.dart';
import 'package:si2/screens/notificaciones/notificaciones_create_screen.dart';
import 'package:si2/screens/perfil/perfil_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Aseguramos inicialización

  // Especificar el nombre del archivo .env
  await dotenv.load(fileName: ".env");

  await initializeDateFormatting('es', null);

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
        // Añadir AudienciaProvider
        ChangeNotifierProxyProvider<AuthProvider, AudienciaProvider>(
          create: (_) => AudienciaProvider(null),
          update: (_, auth, __) => AudienciaProvider(auth),
        ),
      ],
      child: const MyApp(),
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

      // Configuración de localización
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'), // Incluir inglés como respaldo
      ],

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
      initialRoute: '/login',
      routes: {
        // '/': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/recuperar-contrasena': (context) => const RecoverPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/perfil': (context) => PerfilScreen(),

        // Audiencias
        '/audiencias': (context) => AudienciaListScreen(),
        '/audiencias/crear': (context) => AudienciaCrearScreen(),

        // '/audiencias/detalle': (context) => AudienciaDetailScreen(), // Descomenta cuando esté listo
        '/notificaciones': (context) => const NotificacionesScreen(),
        '/notificaciones/crear':
            (context) =>
                const NotificacionesCreateScreen(), // Descomenta cuando esté listo
      },
    );
  }
}
