import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:si2/screens/audiencia/audiencia_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';

class AudienciaCrearScreen extends StatefulWidget {
  const AudienciaCrearScreen({Key? key}) : super(key: key);

  @override
  State<AudienciaCrearScreen> createState() => _AudienciaCrearScreenState();
}

class _AudienciaCrearScreenState extends State<AudienciaCrearScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _tituloController = TextEditingController();
  final _expedienteController = TextEditingController();
  final _salaController = TextEditingController();
  final _descripcionController = TextEditingController();

  // Variables para almacenar los valores de fecha y hora
  DateTime _fechaSeleccionada = DateTime.now();
  TimeOfDay _horaInicio = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaFin = TimeOfDay(hour: 10, minute: 0);

  // Tipos de audiencia disponibles
  List<String> _tiposAudiencia = [
    'Conciliación',
    'Testimonial',
    'Probatoria',
    'Sentencia',
    'General',
  ];
  String _tipoSeleccionado = 'General';

  // Lista de expedientes (esto vendría de una API en un caso real)
  List<Map<String, dynamic>> _expedientes = [
    {'id': '001/2025', 'titulo': 'Caso Civil - Pérez vs. Rodríguez'},
    {'id': '002/2025', 'titulo': 'Caso Laboral - Gómez vs. Empresa ABC'},
    {'id': '003/2025', 'titulo': 'Caso Familiar - Custodia López'},
    {'id': '004/2025', 'titulo': 'Caso Mercantil - Contrato XYZ'},
  ];

  // Lista de salas disponibles
  List<String> _salas = [
    'Sala 101',
    'Sala 102',
    'Sala 103',
    'Sala 201',
    'Sala 202',
  ];

  // Lista de participantes seleccionados
  List<Map<String, dynamic>> _participantes = [];
  List<Map<String, dynamic>> _participantesDisponibles = [
    {'id': 1, 'nombre': 'Dr. Carlos Mendoza', 'rol': 'Juez'},
    {'id': 2, 'nombre': 'Lic. María González', 'rol': 'Abogado'},
    {'id': 3, 'nombre': 'Lic. Roberto Sánchez', 'rol': 'Abogado'},
    {'id': 4, 'nombre': 'Juan Pérez', 'rol': 'Demandante'},
    {'id': 5, 'nombre': 'Ana Rodríguez', 'rol': 'Demandada'},
    {'id': 6, 'nombre': 'Luis Torres', 'rol': 'Testigo'},
    {'id': 7, 'nombre': 'Sofía Martínez', 'rol': 'Perito'},
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _expedienteController.dispose();
    _salaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // Método para seleccionar fecha
  Future<void> _seleccionarFecha() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
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

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaSeleccionada = fechaSeleccionada;
      });
    }
  }

  // Método para seleccionar hora de inicio
  Future<void> _seleccionarHoraInicio() async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: _horaInicio,
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

    if (horaSeleccionada != null) {
      setState(() {
        _horaInicio = horaSeleccionada;

        // Si la hora de fin es anterior a la hora de inicio, actualizar la hora de fin
        int minutosInicio = _horaInicio.hour * 60 + _horaInicio.minute;
        int minutosFin = _horaFin.hour * 60 + _horaFin.minute;

        if (minutosFin <= minutosInicio) {
          // Establecer una duración de 1 hora por defecto
          _horaFin = TimeOfDay(
            hour: (minutosInicio + 60) ~/ 60 % 24,
            minute: (minutosInicio + 60) % 60,
          );
        }
      });
    }
  }

  // Método para seleccionar hora de fin
  Future<void> _seleccionarHoraFin() async {
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: _horaFin,
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

    if (horaSeleccionada != null) {
      // Verificar que la hora de fin sea posterior a la hora de inicio
      int minutosInicio = _horaInicio.hour * 60 + _horaInicio.minute;
      int minutosSeleccionados =
          horaSeleccionada.hour * 60 + horaSeleccionada.minute;

      if (minutosSeleccionados <= minutosInicio) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La hora de fin debe ser posterior a la hora de inicio',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          _horaFin = horaSeleccionada;
        });
      }
    }
  }

  // Método para mostrar el diálogo de selección de expediente
  void _mostrarDialogoExpediente() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Expediente'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _expedientes.length,
              itemBuilder: (context, index) {
                final expediente = _expedientes[index];
                return ListTile(
                  title: Text(expediente['titulo']),
                  subtitle: Text('Exp: ${expediente['id']}'),
                  onTap: () {
                    setState(() {
                      _expedienteController.text = expediente['id'];
                      // Generar un título automático basado en el expediente
                      if (_tituloController.text.isEmpty) {
                        _tituloController.text =
                            'Audiencia de $_tipoSeleccionado - ${expediente['titulo']}';
                      }
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar el diálogo de selección de participantes
  void _mostrarDialogoParticipantes() {
    showDialog(
      context: context,
      builder: (context) {
        // Lista temporal para almacenar selecciones
        List<Map<String, dynamic>> seleccionados = List.from(_participantes);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar Participantes'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _participantesDisponibles.length,
                  itemBuilder: (context, index) {
                    final participante = _participantesDisponibles[index];
                    final isSelected = seleccionados.any(
                      (p) => p['id'] == participante['id'],
                    );

                    return CheckboxListTile(
                      title: Text(participante['nombre']),
                      subtitle: Text('Rol: ${participante['rol']}'),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            if (!seleccionados.any(
                              (p) => p['id'] == participante['id'],
                            )) {
                              seleccionados.add(participante);
                            }
                          } else {
                            seleccionados.removeWhere(
                              (p) => p['id'] == participante['id'],
                            );
                          }
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _participantes = seleccionados;
                    });
                    Navigator.pop(context);
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

  // Método para guardar la audiencia
  Future<void> _guardarAudiencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_participantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos un participante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simular la creación de audiencia
      await Future.delayed(const Duration(seconds: 1));

      // Crear objeto de audiencia
      final nuevaAudiencia = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'titulo': _tituloController.text,
        'expedienteNumero': _expedienteController.text,
        'fecha': _fechaSeleccionada,
        'horaInicio': _horaInicio,
        'horaFin': _horaFin,
        'sala': _salaController.text,
        'tipo': _tipoSeleccionado,
        'descripcion': _descripcionController.text,
        'estado': 'Programada',
        'participantes': _participantes,
      };

      // Aquí implementarías la lógica para enviar a tu backend
      print('Enviando audiencia: $nuevaAudiencia');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audiencia creada con éxito'),
          backgroundColor: Colors.green,
        ),
      );

      // Volver a la pantalla anterior
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la audiencia: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Audiencia'),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección: Información General
                      _buildSectionTitle(
                        'Información General',
                        Icons.info_outline,
                      ),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tipo de audiencia
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Tipo de Audiencia',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.category),
                                ),
                                value: _tipoSeleccionado,
                                items:
                                    _tiposAudiencia.map((tipo) {
                                      return DropdownMenuItem(
                                        value: tipo,
                                        child: Text(tipo),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _tipoSeleccionado = value!;
                                    // Actualizar título si está basado en el tipo
                                    if (_expedienteController.text.isNotEmpty) {
                                      final expedienteInfo = _expedientes
                                          .firstWhere(
                                            (e) =>
                                                e['id'] ==
                                                _expedienteController.text,
                                            orElse: () => {'titulo': ''},
                                          );
                                      _tituloController.text =
                                          'Audiencia de $_tipoSeleccionado - ${expedienteInfo['titulo']}';
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleccione un tipo de audiencia';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Título de la audiencia
                              TextFormField(
                                controller: _tituloController,
                                decoration: InputDecoration(
                                  labelText: 'Título',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.title),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'El título es obligatorio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Expediente
                              TextFormField(
                                controller: _expedienteController,
                                decoration: InputDecoration(
                                  labelText: 'Expediente',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.folder),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: _mostrarDialogoExpediente,
                                  ),
                                ),
                                readOnly: true,
                                onTap: _mostrarDialogoExpediente,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleccione un expediente';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Descripción
                              TextFormField(
                                controller: _descripcionController,
                                decoration: InputDecoration(
                                  labelText: 'Descripción (opcional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.description),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Sección: Programación
                      _buildSectionTitle('Programación', Icons.calendar_today),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fecha
                              InkWell(
                                onTap: _seleccionarFecha,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Fecha',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'EEEE, d MMMM yyyy',
                                              'es',
                                            ).format(_fechaSeleccionada),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Horas de inicio y fin
                              Row(
                                children: [
                                  // Hora de inicio
                                  Expanded(
                                    child: InkWell(
                                      onTap: _seleccionarHoraInicio,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Inicio',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  _horaInicio.format(context),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Hora de fin
                                  Expanded(
                                    child: InkWell(
                                      onTap: _seleccionarHoraFin,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Fin',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  _horaFin.format(context),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Sala
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Sala',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.room),
                                ),
                                value: _salas.isNotEmpty ? _salas[0] : null,
                                items:
                                    _salas.map((sala) {
                                      return DropdownMenuItem(
                                        value: sala,
                                        child: Text(sala),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _salaController.text = value!;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Seleccione una sala';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Sección: Participantes
                      _buildSectionTitle('Participantes', Icons.people),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Botón para agregar participantes
                              OutlinedButton.icon(
                                onPressed: _mostrarDialogoParticipantes,
                                icon: const Icon(Icons.person_add),
                                label: const Text('Seleccionar Participantes'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Lista de participantes seleccionados
                              if (_participantes.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      'No hay participantes seleccionados',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _participantes.length,
                                  itemBuilder: (context, index) {
                                    final participante = _participantes[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: _getColorForRol(
                                          participante['rol'],
                                        ).withOpacity(0.2),
                                        child: Icon(
                                          Icons.person,
                                          color: _getColorForRol(
                                            participante['rol'],
                                          ),
                                        ),
                                      ),
                                      title: Text(participante['nombre']),
                                      subtitle: Text(participante['rol']),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _participantes.removeAt(index);
                                          });
                                        },
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Botón para guardar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _guardarAudiencia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Crear Audiencia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForRol(String rol) {
    switch (rol) {
      case 'Juez':
        return Colors.purple;
      case 'Abogado':
        return Colors.blue;
      case 'Demandante':
        return Colors.green;
      case 'Demandada':
        return Colors.orange;
      case 'Testigo':
        return Colors.brown;
      case 'Perito':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
