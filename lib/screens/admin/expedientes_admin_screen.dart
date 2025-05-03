// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/widgets/common/app_drawer.dart';
import 'package:si2/widgets/common/loading_indicator.dart';
import 'package:si2/widgets/common/error_view.dart';

class ExpedientesAdminScreen extends StatefulWidget {
  const ExpedientesAdminScreen({super.key});

  @override
  _ExpedientesAdminScreenState createState() => _ExpedientesAdminScreenState();
}

class _ExpedientesAdminScreenState extends State<ExpedientesAdminScreen> {
  String _busqueda = '';
  String _filtroEstado = '';
  String _filtroTipo = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpedienteProvider>(
        context,
        listen: false,
      ).cargarExpedientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Expedientes'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ExpedienteProvider>(
                context,
                listen: false,
              ).cargarExpedientes();
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFB71C1C),
        child: Icon(Icons.add, color: Colors.white),
        onPressed:
            () => Navigator.pushNamed(context, '/admin/expedientes/crear'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildExpedientesList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar expediente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value;
                });
              },
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Todos',
                    selected: _filtroEstado.isEmpty,
                    onSelected: (selected) {
                      setState(() {
                        _filtroEstado = '';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Abierto',
                    selected: _filtroEstado == 'Abierto',
                    onSelected: (selected) {
                      setState(() {
                        _filtroEstado = selected ? 'Abierto' : '';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'En Proceso',
                    selected: _filtroEstado == 'En Proceso',
                    onSelected: (selected) {
                      setState(() {
                        _filtroEstado = selected ? 'En Proceso' : '';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Cerrado',
                    selected: _filtroEstado == 'Cerrado',
                    onSelected: (selected) {
                      setState(() {
                        _filtroEstado = selected ? 'Cerrado' : '';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  // Tipos de expediente (ejemplos)
                  _buildFilterChip(
                    label: 'Civil',
                    selected: _filtroTipo == 'Civil',
                    onSelected: (selected) {
                      setState(() {
                        _filtroTipo = selected ? 'Civil' : '';
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Penal',
                    selected: _filtroTipo == 'Penal',
                    onSelected: (selected) {
                      setState(() {
                        _filtroTipo = selected ? 'Penal' : '';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Color(0xFFB71C1C).withOpacity(0.3),
      checkmarkColor: Color(0xFFB71C1C),
    );
  }

  Widget _buildExpedientesList() {
    return Consumer<ExpedienteProvider>(
      builder: (context, expedienteProvider, child) {
        if (expedienteProvider.isLoading) {
          return LoadingIndicator();
        }

        if (expedienteProvider.error != null) {
          return ErrorView(
            message: expedienteProvider.error!,
            onRetry: () => expedienteProvider.cargarExpedientes(),
          );
        }

        // Filtrar la lista según búsqueda y filtros
        final expedientes =
            expedienteProvider.expedientes.where((exp) {
              bool matchesSearch =
                  _busqueda.isEmpty ||
                  exp.numero.toLowerCase().contains(_busqueda.toLowerCase()) ||
                  exp.titulo.toLowerCase().contains(_busqueda.toLowerCase()) ||
                  exp.descripcion.toLowerCase().contains(
                    _busqueda.toLowerCase(),
                  );

              bool matchesEstado =
                  _filtroEstado.isEmpty || exp.estado == _filtroEstado;
              bool matchesTipo = _filtroTipo.isEmpty || exp.tipo == _filtroTipo;

              return matchesSearch && matchesEstado && matchesTipo;
            }).toList();

        if (expedientes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off, size: 80, color: Colors.grey),
                Text(
                  'No se encontraron expedientes',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: expedientes.length,
          itemBuilder: (context, index) {
            final expediente = expedientes[index];
            return _buildExpedienteCard(expediente);
          },
        );
      },
    );
  }

  Widget _buildExpedienteCard(Expediente expediente) {
    Color estadoColor;
    switch (expediente.estado) {
      case 'Abierto':
        estadoColor = Colors.green;
        break;
      case 'En Proceso':
        estadoColor = Colors.amber;
        break;
      case 'Cerrado':
        estadoColor = Colors.red;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFB71C1C),
          child: Text(expediente.numero.substring(0, 2)),
        ),
        title: Text(
          expediente.titulo,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('N° ${expediente.numero}'),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    expediente.estado,
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    expediente.tipo,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'ver':
                Navigator.pushNamed(
                  context,
                  '/admin/expedientes/detalle',
                  arguments: {'id': expediente.id},
                );
                break;
              case 'editar':
                Navigator.pushNamed(
                  context,
                  '/admin/expedientes/editar',
                  arguments: {'id': expediente.id},
                );
                break;
              case 'eliminar':
                _confirmarEliminacion(expediente);
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'ver',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Ver detalles'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/admin/expedientes/detalle',
            arguments: {'id': expediente.id},
          );
        },
      ),
    );
  }

  void _confirmarEliminacion(Expediente expediente) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Eliminar expediente'),
            content: Text(
              '¿Está seguro que desea eliminar el expediente ${expediente.numero}?',
            ),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                  _eliminarExpediente(expediente.id!);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _eliminarExpediente(int id) async {
    final expedienteProvider = Provider.of<ExpedienteProvider>(
      context,
      listen: false,
    );
    final result = await expedienteProvider.eliminarExpediente(id);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expediente eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al eliminar el expediente: ${expedienteProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
