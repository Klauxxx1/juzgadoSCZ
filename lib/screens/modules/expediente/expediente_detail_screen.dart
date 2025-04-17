import 'package:flutter/material.dart';

class ExpedienteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> expediente;

  const ExpedienteDetailScreen({super.key, required this.expediente});

  @override
  Widget build(BuildContext context) {
    final progreso = expediente['progreso'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(expediente['titulo']),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Progreso del Expediente', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progreso / 100,
              backgroundColor: Colors.grey[300],
              color: Color(0xFFB71C1C),
              minHeight: 15,
            ),
            const SizedBox(height: 10),
            Text('$progreso% completado'),
            const SizedBox(height: 30),
            Text(
              'Fecha estimada de finalización:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(expediente['fin']),
          ],
        ),
      ),
    );
  }
}
