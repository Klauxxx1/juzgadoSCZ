import 'package:flutter/material.dart';

class UserInfoScreen extends StatelessWidget {
  final String nombre;
  final String rol;
  final String correo;

  const UserInfoScreen({
    super.key,
    this.nombre = 'Lic. Parada Klaxxx',
    this.rol = 'Juez',
    this.correo = 'klaxxx.juez.@justicia.bo.scz',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
            ); // Vuelve a la pantalla anterior (con Drawer)
          },
        ),
        title: Text('Perfil de Usuario'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(
                'assets/login1.png',
              ), // agrega imagen real
            ),
            const SizedBox(height: 20),
            Text(
              nombre,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(rol, style: TextStyle(fontSize: 18, color: Colors.redAccent)),
            const SizedBox(height: 10),
            Text(correo, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}
