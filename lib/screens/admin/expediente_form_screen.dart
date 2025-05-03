// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/providers/usuario_provider.dart';
import 'package:si2/models/user_model.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/widgets/common/loading_indicator.dart';

class ExpedienteFormScreen extends StatefulWidget {
  final Expediente? expediente; // Si es null, se está creando uno nuevo

  const ExpedienteFormScreen({super.key, this.expediente});

  @override
  _ExpedienteFormScreenState createState() => _ExpedienteFormScreenState();
}

class _ExpedienteFormScreenState extends State<ExpedienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  late TextEditingController _numeroController;
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;

  String _estado = 'Abierto';
  String _tipo = 'Civil';
  DateTime _fechaApertura = DateTime.now();

  // IDs para las relaciones
  int? _clienteId;
  int? _abogadoId;
  int? _juezId;
  int? _asistenteId;

  // Listas para los dropdowns
  List<User> _clientes = [];
  List<User> _abogados = [];
  List<User> _jueces = [];
  List<User> _asistentes = [];

  bool get _esNuevo => widget.expediente == null;

  @override
  void initState() {
    super.initState();
    _numeroController = TextEditingController();
    _tituloController = TextEditingController();
    _descripcionController = TextEditingController();

    _cargarUsuariosPorRol();

    if (!_esNuevo) {
      // Si estamos editando, cargar los datos del expediente
      _numeroController.text = widget.expediente!.numero;
      _tituloController.text = widget.expediente!.titulo;
      _descripcionController.text = widget.expediente!.descripcion;
      _estado = widget.expediente!.estado;
      _tipo = widget.expediente!.tipo;
      _fechaApertura = widget.expediente!.fechaApertura;
      _clienteId = widget.expediente!.clienteId;
      _abogadoId = widget.expediente!.abogadoId;
      _juezId = widget.expediente!.juezId;
      _asistenteId = widget.expediente!.asistenteId;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuariosPorRol() async {
    setState(() => _isLoading = true);

    final usuarioProvider = Provider.of<UsuarioProvider>(
      context,
      listen: false,
    );

    try {
      await usuarioProvider.cargarUsuariosPorRol('Cliente');
      _clientes = usuarioProvider.usuarios.where((u) => u.isCliente).toList();

      await usuarioProvider.cargarUsuariosPorRol('Abogado');
      _abogados = usuarioProvider.usuarios.where((u) => u.isAbogado).toList();

      await usuarioProvider.cargarUsuariosPorRol('Juez');
      _jueces = usuarioProvider.usuarios.where((u) => u.isJuez).toList();

      await usuarioProvider.cargarUsuariosPorRol('Asistente');
      _asistentes =
          usuarioProvider.usuarios.where((u) => u.isAsistente).toList();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esNuevo ? 'Crear Expediente' : 'Editar Expediente'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? LoadingIndicator()
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(),
                      SizedBox(height: 16),
                      _buildDetallesCard(),
                      SizedBox(height: 16),
                      _buildParticipantesCard(),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text(
                          _esNuevo ? 'Crear Expediente' : 'Guardar Cambios',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB71C1C),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _guardarExpediente,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            TextFormField(
              controller: _numeroController,
              decoration: InputDecoration(
                labelText: 'Número de Expediente',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El número de expediente es obligatorio';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El título es obligatorio';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: InputDecoration(
                labelText: 'Tipo de Expediente',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items:
                  [
                    'Civil',
                    'Penal',
                    'Familiar',
                    'Laboral',
                    'Administrativo',
                    'Otro',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _tipo = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles del Expediente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Text('Fecha de Apertura:')),
                TextButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    '${_fechaApertura.day}/${_fechaApertura.month}/${_fechaApertura.year}',
                  ),
                  onPressed: () async {
                    final DateTime? fechaSeleccionada = await showDatePicker(
                      context: context,
                      initialDate: _fechaApertura,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (fechaSeleccionada != null) {
                      setState(() {
                        _fechaApertura = fechaSeleccionada;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _estado,
              decoration: InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
              ),
              items:
                  ['Abierto', 'En Proceso', 'Cerrado'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _estado = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantesCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Participantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            _buildUsuarioDropdown(
              label: 'Cliente',
              icon: Icons.person,
              usuarios: _clientes,
              selectedId: _clienteId,
              onChanged: (userId) {
                setState(() {
                  _clienteId = userId;
                });
              },
            ),
            SizedBox(height: 16),
            _buildUsuarioDropdown(
              label: 'Abogado',
              icon: Icons.business_center,
              usuarios: _abogados,
              selectedId: _abogadoId,
              onChanged: (userId) {
                setState(() {
                  _abogadoId = userId;
                });
              },
            ),
            SizedBox(height: 16),
            _buildUsuarioDropdown(
              label: 'Juez',
              icon: Icons.gavel,
              usuarios: _jueces,
              selectedId: _juezId,
              onChanged: (userId) {
                setState(() {
                  _juezId = userId;
                });
              },
            ),
            SizedBox(height: 16),
            _buildUsuarioDropdown(
              label: 'Asistente',
              icon: Icons.support_agent,
              usuarios: _asistentes,
              selectedId: _asistenteId,
              onChanged: (userId) {
                setState(() {
                  _asistenteId = userId;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsuarioDropdown({
    required String label,
    required IconData icon,
    required List<User> usuarios,
    required int? selectedId,
    required Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int?>(
      value: selectedId,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items: [
        DropdownMenuItem<int?>(value: null, child: Text('Sin asignar')),
        ...usuarios.map((user) {
          return DropdownMenuItem<int?>(
            value: user.id,
            child: Text('${user.nombre} ${user.apellido}'),
          );
        }),
      ],
      onChanged: (newValue) {
        onChanged(newValue);
      },
    );
  }

  void _guardarExpediente() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final expedienteData = {
      'numero': _numeroController.text,
      'titulo': _tituloController.text,
      'descripcion': _descripcionController.text,
      'estado': _estado,
      'tipo': _tipo,
      'fechaApertura': _fechaApertura.toIso8601String(),
      'clienteId': _clienteId,
      'abogadoId': _abogadoId,
      'juezId': _juezId,
      'asistenteId': _asistenteId,
    };

    final expedienteProvider = Provider.of<ExpedienteProvider>(
      context,
      listen: false,
    );

    try {
      bool success;
      if (_esNuevo) {
        success = await expedienteProvider.crearExpediente(expedienteData);
      } else {
        success = await expedienteProvider.actualizarExpediente(
          widget.expediente!.id!,
          expedienteData,
        );
      }

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esNuevo
                  ? 'Expediente creado correctamente'
                  : 'Expediente actualizado correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${expedienteProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
