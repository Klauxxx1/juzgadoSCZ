// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/widgets/common/loading_indicator.dart';
import 'package:si2/widgets/common/app_drawer.dart';

class ExpedienteDetalleScreen extends StatefulWidget {
  const ExpedienteDetalleScreen({super.key});

  @override
  _ExpedienteDetalleScreenState createState() =>
      _ExpedienteDetalleScreenState();
}

class _ExpedienteDetalleScreenState extends State<ExpedienteDetalleScreen> {
  late int expedienteId;
  bool _loadingCambioEstado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args.containsKey('id')) {
      expedienteId = args['id'];
      Provider.of<ExpedienteProvider>(
        context,
        listen: false,
      ).obtenerDetallesExpediente(expedienteId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Expediente'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              final expediente =
                  Provider.of<ExpedienteProvider>(
                    context,
                    listen: false,
                  ).expedienteSeleccionado;
              if (expediente != null) {
                Navigator.pushNamed(
                  context,
                  '/admin/expedientes/editar',
                  arguments: {'id': expediente.id},
                );
              }
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Consumer<ExpedienteProvider>(
        builder: (context, expedienteProvider, child) {
          if (expedienteProvider.isLoading) {
            return LoadingIndicator();
          }

          final expediente = expedienteProvider.expedienteSeleccionado;

          if (expediente == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'No se encontró el expediente',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      expedienteProvider.obtenerDetallesExpediente(
                        expedienteId,
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCabeceraExpediente(expediente),
                SizedBox(height: 16),
                _buildEstadoExpediente(expediente),
                SizedBox(height: 16),
                _buildDetallesExpediente(expediente),
                SizedBox(height: 16),
                _buildParticipantesExpediente(expediente),
                SizedBox(height: 24),
                _buildBotonesAccion(expediente),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCabeceraExpediente(Expediente expediente) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expediente.titulo,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Expediente N° ${expediente.numero}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getColorForTipo(expediente.tipo).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    expediente.tipo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColorForTipo(expediente.tipo),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            Text(
              'Descripción:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(expediente.descripcion, style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoExpediente(Expediente expediente) {
    Color estadoColor = _getColorForEstado(expediente.estado);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            Divider(),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    expediente.estado,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: estadoColor,
                    ),
                  ),
                ),
                Spacer(),
                if (_loadingCambioEstado)
                  CircularProgressIndicator(strokeWidth: 2)
                else
                  PopupMenuButton<String>(
                    icon: Icon(Icons.change_circle),
                    tooltip: 'Cambiar estado',
                    onSelected: (String nuevoEstado) async {
                      if (nuevoEstado != expediente.estado) {
                        await _cambiarEstado(expediente.id!, nuevoEstado);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return ['Abierto', 'En Proceso', 'Cerrado']
                          .where((estado) => estado != expediente.estado)
                          .map((String estado) {
                            return PopupMenuItem<String>(
                              value: estado,
                              child: Row(
                                children: [
                                  Icon(
                                    _getIconForEstado(estado),
                                    color: _getColorForEstado(estado),
                                  ),
                                  SizedBox(width: 10),
                                  Text(estado),
                                ],
                              ),
                            );
                          })
                          .toList();
                    },
                  ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                SizedBox(width: 8),
                Text(
                  'Fecha de apertura: ${_formatDate(expediente.fechaApertura)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            if (expediente.fechaCierre != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event_available, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Fecha de cierre: ${_formatDate(expediente.fechaCierre!)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesExpediente(Expediente expediente) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clasificación y Etiquetas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.category, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tipo: ${expediente.tipo}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...(expediente.etiquetas ?? []).map(
                  (etiqueta) => Chip(
                    label: Text(etiqueta),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: TextStyle(color: Colors.blue[700]),
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: () {
                      // Implementar eliminación de etiqueta
                    },
                  ),
                ),
                ActionChip(
                  avatar: Icon(Icons.add, size: 18),
                  label: Text('Añadir'),
                  onPressed: () {
                    // Implementar añadir etiqueta
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantesExpediente(Expediente expediente) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            _buildParticipanteItem(
              'Cliente',
              expediente.cliente?.nombre ?? 'No asignado',
              expediente.cliente?.apellido ?? '',
              Icons.person,
              Colors.blue,
            ),
            Divider(height: 16),
            _buildParticipanteItem(
              'Abogado',
              expediente.abogado?.nombre ?? 'No asignado',
              expediente.abogado?.apellido ?? '',
              Icons.business_center,
              Colors.orange,
            ),
            Divider(height: 16),
            _buildParticipanteItem(
              'Juez',
              expediente.juez?.nombre ?? 'No asignado',
              expediente.juez?.apellido ?? '',
              Icons.gavel,
              Colors.red,
            ),
            Divider(height: 16),
            _buildParticipanteItem(
              'Asistente',
              expediente.asistente?.nombre ?? 'No asignado',
              expediente.asistente?.apellido ?? '',
              Icons.support_agent,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipanteItem(
    String rol,
    String nombre,
    String apellido,
    IconData icono,
    Color color,
  ) {
    bool asignado = nombre != 'No asignado';

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                asignado
                    ? color.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: asignado ? color : Colors.grey),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rol, style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(
                asignado ? '$nombre $apellido' : 'No asignado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: asignado ? FontWeight.bold : FontWeight.normal,
                  color: asignado ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (asignado)
          IconButton(
            icon: Icon(Icons.visibility, color: color),
            onPressed: () {
              // Navegar al detalle del usuario
            },
          ),
      ],
    );
  }

  Widget _buildBotonesAccion(Expediente expediente) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.document_scanner),
            label: Text('Seguimientos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/seguimientos',
                arguments: {'expedienteId': expediente.id},
              );
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.event),
            label: Text('Audiencias'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/audiencias',
                arguments: {'expedienteId': expediente.id},
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _cambiarEstado(int expedienteId, String nuevoEstado) async {
    setState(() => _loadingCambioEstado = true);

    try {
      final expedienteProvider = Provider.of<ExpedienteProvider>(
        context,
        listen: false,
      );
      final success = await expedienteProvider.cambiarEstadoExpediente(
        expedienteId,
        nuevoEstado,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado cambiado a "$nuevoEstado" correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cambiar el estado: ${expedienteProvider.error}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loadingCambioEstado = false);
    }
  }

  // Funciones auxiliares
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getColorForEstado(String estado) {
    switch (estado) {
      case 'Abierto':
        return Colors.green;
      case 'En Proceso':
        return Colors.amber;
      case 'Cerrado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForEstado(String estado) {
    switch (estado) {
      case 'Abierto':
        return Icons.folder_open;
      case 'En Proceso':
        return Icons.pending_actions;
      case 'Cerrado':
        return Icons.folder_off;
      default:
        return Icons.folder;
    }
  }

  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'Civil':
        return Colors.blue;
      case 'Penal':
        return Colors.red;
      case 'Familiar':
        return Colors.green;
      case 'Laboral':
        return Colors.orange;
      case 'Administrativo':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }
}
