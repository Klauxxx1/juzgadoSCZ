import 'package:flutter/material.dart';
import 'expediente_detail_screen.dart';

class ExpedienteListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> expedientes = [
    {
      'titulo': 'Expediente 001/2025',
      'fecha': '12-04-2025',
      'progreso': 80,
      'fin': '05-05-2025',
    },
    {
      'titulo': 'Expediente 002/2025',
      'fecha': '10-03-2024',
      'progreso': 45,
      'fin': '01-06-2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Lista de Expedientes'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        itemCount: expedientes.length,
        itemBuilder: (context, index) {
          final expediente = expedientes[index];
          return Card(
            child: ListTile(
              title: Text(expediente['titulo']),
              subtitle: Text('Fecha: ${expediente['fecha']}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ExpedienteDetailScreen(expediente: expediente),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
