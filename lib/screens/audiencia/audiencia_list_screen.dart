import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/user_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/screens/audiencia/audiencia_detail_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Audiencia {
  final int id;
  final String titulo;
  final String expedienteNumero;
  final DateTime fecha;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;
  final String sala;
  final String estado; // "Programada", "En curso", "Finalizada", "Cancelada"

  Audiencia({
    required this.id,
    required this.titulo,
    required this.expedienteNumero,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.sala,
    required this.estado,
  });

  // Método para obtener color según estado
  Color getColorPorEstado() {
    switch (estado) {
      case 'Programada':
        return Colors.blue;
      case 'En curso':
        return Colors.green;
      case 'Finalizada':
        return Colors.grey;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

class AudienciaListScreen extends StatefulWidget {
  const AudienciaListScreen({super.key});

  @override
  State<AudienciaListScreen> createState() => _AudienciaListScreenState();
}

class _AudienciaListScreenState extends State<AudienciaListScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  // Mapa para almacenar eventos por día
  Map<DateTime, List<Audiencia>> _audienciasPorDia = {};

  // Mock data para audiencias
  final List<Audiencia> _audiencias = [
    Audiencia(
      id: 1,
      titulo: 'Audiencia de conciliación',
      expedienteNumero: '001/2025',
      fecha: DateTime(2025, 5, 5),
      horaInicio: TimeOfDay(hour: 9, minute: 0),
      horaFin: TimeOfDay(hour: 10, minute: 30),
      sala: 'Sala 101',
      estado: 'Programada',
    ),
    Audiencia(
      id: 2,
      titulo: 'Lectura de sentencia',
      expedienteNumero: '002/2025',
      fecha: DateTime(2025, 5, 5),
      horaInicio: TimeOfDay(hour: 11, minute: 0),
      horaFin: TimeOfDay(hour: 12, minute: 0),
      sala: 'Sala 102',
      estado: 'Programada',
    ),
    Audiencia(
      id: 3,
      titulo: 'Declaración de testigos',
      expedienteNumero: '003/2025',
      fecha: DateTime(2025, 5, 7),
      horaInicio: TimeOfDay(hour: 14, minute: 30),
      horaFin: TimeOfDay(hour: 16, minute: 0),
      sala: 'Sala 103',
      estado: 'Programada',
    ),
    Audiencia(
      id: 4,
      titulo: 'Revisión de pruebas',
      expedienteNumero: '004/2025',
      fecha: DateTime(2025, 5, 10),
      horaInicio: TimeOfDay(hour: 9, minute: 0),
      horaFin: TimeOfDay(hour: 11, minute: 0),
      sala: 'Sala 201',
      estado: 'Programada',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    // Cargar audiencias en el mapa
    _cargarAudiencias();
  }

  void _cargarAudiencias() {
    _audienciasPorDia = {};
    for (var audiencia in _audiencias) {
      final fecha = DateTime(
        audiencia.fecha.year,
        audiencia.fecha.month,
        audiencia.fecha.day,
      );

      if (_audienciasPorDia[fecha] == null) {
        _audienciasPorDia[fecha] = [];
      }

      _audienciasPorDia[fecha]!.add(audiencia);
    }
  }

  List<Audiencia> _getAudienciasParaFecha(DateTime fecha) {
    final diaFormateado = DateTime(fecha.year, fecha.month, fecha.day);
    return _audienciasPorDia[diaFormateado] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Audiencias'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                eventLoader: (day) {
                  return _getAudienciasParaFecha(day);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.event, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Audiencias para el ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildAudienciasList()),
        ],
      ),
      floatingActionButton:
          user?.rol == 'juez'
              ? FloatingActionButton(
                onPressed: () {
                  // Cambiamos el SnackBar por la navegación real a la pantalla de creación
                  Navigator.of(context).pushNamed('/audiencias/crear').then((
                    value,
                  ) {
                    if (value == true) {
                      // Recargar audiencias si se creó una nueva
                      setState(() {
                        _cargarAudiencias();
                      });
                    }
                  });
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.add, color: Colors.white),
                tooltip: 'Crear nueva audiencia',
              )
              : null,
    );
  }

  Widget _buildAudienciasList() {
    final audienciasDelDia = _getAudienciasParaFecha(_selectedDay);

    if (audienciasDelDia.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay audiencias programadas para este día',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: audienciasDelDia.length,
      itemBuilder: (context, index) {
        final audiencia = audienciasDelDia[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AudienciaDetailScreen(audiencia: audiencia),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: audiencia.getColorPorEstado(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        audiencia.estado,
                        style: TextStyle(
                          color: audiencia.getColorPorEstado(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Exp: ${audiencia.expedienteNumero}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    audiencia.titulo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${audiencia.horaInicio.format(context)} - ${audiencia.horaFin.format(context)}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.room, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        audiencia.sala,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
