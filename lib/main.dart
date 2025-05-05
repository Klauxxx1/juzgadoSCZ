// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/providers/usuario_provider.dart';
import 'package:si2/screens/audiencia/audiencia_list_screen.dart';
import 'package:si2/screens/auth/login_screen.dart';
import 'package:si2/screens/auth/recover_password_screen.dart';
import 'package:si2/screens/auth/role_selection_screen.dart';
import 'package:si2/screens/home/home_screen.dart';
import 'package:si2/screens/perfil/perfil_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Aseguramos inicialización
  initializeDateFormatting('es', null).then((_) {
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

          // ChangeNotifierProxyProvider<AuthProvider, SeguimientoProvider>(
          //   create: (_) => SeguimientoProvider(null),
          //   update: (_, auth, __) => SeguimientoProvider(auth),
          // ),
          // ChangeNotifierProxyProvider<AuthProvider, NotificacionProvider>(
          //   create: (_) => NotificacionProvider(null),
          //   update: (_, auth, __) => NotificacionProvider(auth),
          // ),
        ],
        child: MyApp(),
      ),
    );
  });
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
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/recuperar-contrasena': (context) => const RecoverPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/perfil': (context) => PerfilScreen(),

        // Audiencias
        '/audiencias': (context) => AudienciaListScreen(),
        // '/audiencias/detalle': (context) => AudienciaDetailScreen(), // Descomenta cuando esté listo
      },
    );
  }
}
