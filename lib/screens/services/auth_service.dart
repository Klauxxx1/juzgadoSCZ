import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inicio de sesión
  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error en signIn: ${e.toString()}');
      }
      return false;
    }
  }

  // Registro de usuario
  Future<bool> registerUser(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Opcional: Guardar datos adicionales en Firestore (por ejemplo, nombre)
      return result.user != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error en registerUser: ${e.toString()}');
      }
      return false;
    }
  }

  // Cierre de sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
