import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificacionesCreateScreen extends StatefulWidget {
  const NotificacionesCreateScreen({Key? key}) : super(key: key);

  @override
  State<NotificacionesCreateScreen> createState() =>
      _NotificacionesCreateScreenState();
}

class _NotificacionesCreateScreenState
    extends State<NotificacionesCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _mensajeController = TextEditingController();
  String _tipoSeleccionado = 'sistema';
  List<String> _destinatariosSeleccionados = [];
  bool _enviarAhora = true;
  DateTime _fechaProgramada = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _horaProgramada = TimeOfDay.now();
  bool _isLoading = false;

  // Lista de tipos de notificación
  final List<Map<String, dynamic>> _tiposNotificacion = [
    {
      'valor': 'audiencia',
      'titulo': 'Audiencia',
      'icono': Icons.gavel,
      'color': Colors.blue,
    },
    {
      'valor': 'expediente',
      'titulo': 'Expediente',
      'icono': Icons.folder,
      'color': Colors.green,
    },
    {
      'valor': 'urgente',
      'titulo': 'Urgente',
      'icono': Icons.priority_high,
      'color': Colors.red,
    },
    {
      'valor': 'recordatorio',
      'titulo': 'Recordatorio',
      'icono': Icons.alarm,
      'color': Colors.orange,
    },
    {
      'valor': 'sistema',
      'titulo': 'Sistema',
      'icono': Icons.notifications,
      'color': Colors.purple,
    },
  ];

  // Lista de destinatarios de ejemplo
  final List<Map<String, dynamic>> _destinatarios = [
    {'id': 1, 'nombre': 'Juan Pérez', 'rol': 'cliente'},
    {'id': 2, 'nombre': 'María González', 'rol': 'abogado'},
    {'id': 3, 'nombre': 'Carlos Ramírez', 'rol': 'juez'},
    {'id': 4, 'nombre': 'Ana López', 'rol': 'asistente'},
    {'id': 5, 'nombre': 'Pedro Sánchez', 'rol': 'cliente'},
    {'id': 6, 'nombre': 'Laura Torres', 'rol': 'abogado'},
    {'id': 7, 'nombre': 'Todos los usuarios', 'rol': 'todos'},
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  // Método para seleccionar fecha
  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaProgramada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaProgramada = fecha;
      });
    }
  }

  // Método para seleccionar hora
  Future<void> _seleccionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaProgramada,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        _horaProgramada = hora;
      });
    }
  }

  // Método para enviar la notificación
  Future<void> _enviarNotificacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_destinatariosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos un destinatario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulación de envío
    await Future.delayed(const Duration(seconds: 1));

    // Crear objeto de notificación
    final notificacion = {
      'titulo': _tituloController.text,
      'mensaje': _mensajeController.text,
      'tipo': _tipoSeleccionado,
      'destinatarios': _destinatariosSeleccionados,
      'programada': !_enviarAhora,
      'fecha_envio':
          _enviarAhora
              ? DateTime.now()
              : DateTime(
                _fechaProgramada.year,
                _fechaProgramada.month,
                _fechaProgramada.day,
                _horaProgramada.hour,
                _horaProgramada.minute,
              ),
    };

    // Aquí implementarías la lógica para enviar a tu backend
    print('Enviando notificación: $notificacion');

    setState(() {
      _isLoading = false;
    });

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _enviarAhora
              ? 'Notificación enviada con éxito'
              : 'Notificación programada para ${DateFormat('dd/MM/yyyy HH:mm').format(notificacion['fecha_envio'] as DateTime)}',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Volver a la pantalla anterior
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Notificación'), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo de notificación
                      const Text(
                        'Tipo de notificación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTipoNotificacionSelector(),
                      const SizedBox(height: 24),

                      // Título
                      TextFormField(
                        controller: _tituloController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(
                            Icons.title,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El título es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mensaje
                      TextFormField(
                        controller: _mensajeController,
                        decoration: InputDecoration(
                          labelText: 'Mensaje',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(
                            Icons.message,
                            color: Theme.of(context).primaryColor,
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El mensaje es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Destinatarios
                      const Text(
                        'Destinatarios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDestinatariosSelector(),
                      const SizedBox(height: 24),

                      // Programación de envío
                      const Text(
                        'Programación de envío',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildProgramacionSelector(),
                      const SizedBox(height: 30),

                      // Botón de enviar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _enviarNotificacion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _enviarAhora
                                ? 'Enviar Notificación'
                                : 'Programar Notificación',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTipoNotificacionSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            _tiposNotificacion.map((tipo) {
              final bool isSelected = _tipoSeleccionado == tipo['valor'];

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _tipoSeleccionado = tipo['valor'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? (tipo['color'] as Color).withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? tipo['color'] as Color
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tipo['icono'] as IconData,
                          color:
                              isSelected ? tipo['color'] as Color : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tipo['titulo'] as String,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? tipo['color'] as Color
                                    : Colors.grey[700],
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDestinatariosSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chips de destinatarios seleccionados
        if (_destinatariosSeleccionados.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                _destinatariosSeleccionados.map((id) {
                  final destinatario = _destinatarios.firstWhere(
                    (d) => d['id'].toString() == id,
                    orElse: () => {'id': 0, 'nombre': 'Desconocido', 'rol': ''},
                  );

                  return Chip(
                    label: Text(destinatario['nombre']),
                    onDeleted: () {
                      setState(() {
                        _destinatariosSeleccionados.remove(id);
                      });
                    },
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    deleteIconColor: Theme.of(context).primaryColor,
                  );
                }).toList(),
          ),

        if (_destinatariosSeleccionados.isNotEmpty) const SizedBox(height: 12),

        // Botón para mostrar el diálogo de selección
        OutlinedButton.icon(
          onPressed: _mostrarDialogoDestinatarios,
          icon: const Icon(Icons.person_add),
          label: const Text('Seleccionar destinatarios'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarDialogoDestinatarios() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> seleccionados = List.from(_destinatariosSeleccionados);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar destinatarios'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      _destinatarios.map((destinatario) {
                        final isSelected = seleccionados.contains(
                          destinatario['id'].toString(),
                        );
                        final esTodos =
                            destinatario['id'] ==
                            7; // ID de "Todos los usuarios"

                        return CheckboxListTile(
                          title: Text(destinatario['nombre']),
                          subtitle: Text('Rol: ${destinatario['rol']}'),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (esTodos && value == true) {
                                // Si selecciona "Todos los usuarios", deseleccionar los demás
                                seleccionados.clear();
                                seleccionados.add(
                                  '7',
                                ); // ID de "Todos los usuarios"
                              } else if (esTodos && value == false) {
                                // Si deselecciona "Todos los usuarios"
                                seleccionados.remove('7');
                              } else if (value == true) {
                                // Si selecciona un usuario individual, deseleccionar "Todos los usuarios"
                                seleccionados.remove('7');
                                seleccionados.add(
                                  destinatario['id'].toString(),
                                );
                              } else {
                                seleccionados.remove(
                                  destinatario['id'].toString(),
                                );
                              }
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _destinatariosSeleccionados = seleccionados;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProgramacionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de envío inmediato o programado
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _enviarAhora,
              onChanged: (value) {
                setState(() {
                  _enviarAhora = value!;
                });
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            const Text('Enviar ahora'),
            const SizedBox(width: 20),
            Radio<bool>(
              value: false,
              groupValue: _enviarAhora,
              onChanged: (value) {
                setState(() {
                  _enviarAhora = value!;
                });
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            const Text('Programar envío'),
          ],
        ),

        // Selector de fecha y hora para envío programado
        if (!_enviarAhora)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fecha y hora de envío',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _seleccionarFecha,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          DateFormat('dd/MM/yyyy').format(_fechaProgramada),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _seleccionarHora,
                        icon: const Icon(Icons.access_time),
                        label: Text(_horaProgramada.format(context)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
