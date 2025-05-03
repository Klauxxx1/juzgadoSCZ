// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/expediente_model.dart';
import 'package:si2/providers/expediente_provider.dart';
import 'package:si2/widgets/common/app_drawer.dart';
import 'package:si2/widgets/common/loading_indicator.dart';

class ExpedienteListScreen extends StatefulWidget {
  const ExpedienteListScreen({super.key});

  @override
  _ExpedienteListScreenState createState() => _ExpedienteListScreenState();
}

class _ExpedienteListScreenState extends State<ExpedienteListScreen> {
  String _filtroEstado = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarExpedientes();
    });
  }

  Future<void> _cargarExpedientes() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<ExpedienteProvider>(
        context,
        listen: false,
      ).cargarExpedientes();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Expedientes'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarExpedientes,
            tooltip: 'Actualizar expedientes',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body:
          _isLoading
              ? LoadingIndicator(message: 'Cargando expedientes...')
              : _buildExpedientesBody(),
    );
  }

  Widget _buildExpedientesBody() {
    return Consumer<ExpedienteProvider>(
      builder: (context, expedienteProvider, child) {
        if (expedienteProvider.isLoading) {
          return LoadingIndicator();
        }

        if (expedienteProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error al cargar expedientes: ${expedienteProvider.error}',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _cargarExpedientes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB71C1C),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final expedientes = expedienteProvider.expedientes;

        if (expedientes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay expedientes disponibles',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildFiltros(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _cargarExpedientes,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: expedientes.length,
                  itemBuilder: (context, index) {
                    return _buildExpedienteCard(expedientes[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar Expedientes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar expediente...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filtroEstado.isEmpty ? null : _filtroEstado,
                    hint: Text('Estado'),
                    items: [
                      DropdownMenuItem(value: '', child: Text('Todos')),
                      DropdownMenuItem(
                        value: 'Abierto',
                        child: Text('Abierto'),
                      ),
                      DropdownMenuItem(
                        value: 'En resolución',
                        child: Text('En resolución'),
                      ),
                      DropdownMenuItem(
                        value: 'Cerrado',
                        child: Text('Cerrado'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtroEstado = value ?? '';
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpedienteCard(Expediente expediente) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/expedientes/detalle',
            arguments: expediente.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: _getColorPorEstado(expediente.estado),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    expediente.numero,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    expediente.estado,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expediente.titulo,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    expediente.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tipo: ${expediente.tipo}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        'Abierto: ${_formatDate(expediente.fechaApertura)}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  if (expediente.cliente != null) ...[
                    SizedBox(height: 8),
                    Text(
                      'Cliente: ${expediente.cliente!.nombre} ${expediente.cliente!.apellido}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (expediente.juez != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Juez: ${expediente.juez!.nombre} ${expediente.juez!.apellido}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'Abierto':
        return Colors.green;
      case 'En resolución':
        return Colors.orange;
      case 'Cerrado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
