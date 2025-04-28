import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/screens/home_screen.dart';
import 'package:si2/screens/login_screen.dart';
import 'package:si2/screens/register_screen.dart';
import 'package:si2/services/auth_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(create: (context) => AuthProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App para Jueces, Abogados, Asistentes y Secretarios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFB71C1C),
        scaffoldBackgroundColor: const Color.fromRGBO(241, 222, 190, 1),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFB71C1C),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFB71C1C)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthChecker(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
