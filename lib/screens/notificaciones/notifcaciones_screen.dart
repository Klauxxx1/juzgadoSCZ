import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';

class Notificacion {
  final int id;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final String tipo; // 'audiencia', 'expediente', 'sistema', etc.
  final bool leida;
  final String? icono;
  final String? accion; // Ruta a la que dirigirse al pulsar

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.tipo,
    this.leida = false,
    this.icono,
    this.accion,
  });

  // Obtiene el color según el tipo de notificación
  Color getColor() {
    switch (tipo) {
      case 'audiencia':
        return Colors.blue;
      case 'expediente':
        return Colors.green;
      case 'urgente':
        return Colors.red;
      case 'recordatorio':
        return Colors.orange;
      case 'sistema':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Obtiene el icono según el tipo de notificación
  IconData getIconData() {
    switch (tipo) {
      case 'audiencia':
        return Icons.gavel;
      case 'expediente':
        return Icons.folder;
      case 'urgente':
        return Icons.priority_high;
      case 'recordatorio':
        return Icons.alarm;
      case 'sistema':
        return Icons.notifications;
      default:
        return Icons.circle_notifications;
    }
  }
}

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({Key? key}) : super(key: key);

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _mostrarFiltros = false;
  String _filtroTipo = 'todas';
  bool _ordenarPorFecha = true;
  List<Notificacion> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarNotificaciones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Simulación de carga de notificaciones
  Future<void> _cargarNotificaciones() async {
    setState(() {
      _isLoading = true;
    });

    // Simulamos una carga de datos
    await Future.delayed(const Duration(milliseconds: 800));

    // Datos de ejemplo
    final notificaciones = [
      Notificacion(
        id: 1,
        titulo: 'Audiencia programada',
        mensaje:
            'Se ha programado una audiencia para el caso #123456 el día 10/05/2025 a las 10:00 AM.',
        fecha: DateTime.now().subtract(const Duration(hours: 2)),
        tipo: 'audiencia',
        accion: '/audiencias/detalle',
      ),
      Notificacion(
        id: 2,
        titulo: 'Nuevo documento en expediente',
        mensaje: 'Se ha añadido un nuevo documento al expediente #789012.',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        tipo: 'expediente',
        leida: true,
        accion: '/expedientes/detalle',
      ),
      Notificacion(
        id: 3,
        titulo: 'Cambio de estado en expediente',
        mensaje: 'El expediente #456789 ha cambiado su estado a "En proceso".',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        tipo: 'expediente',
        accion: '/expedientes/detalle',
      ),
      Notificacion(
        id: 4,
        titulo: 'Recordatorio de audiencia',
        mensaje: 'La audiencia del caso #123456 comenzará en 24 horas.',
        fecha: DateTime.now().subtract(const Duration(hours: 5)),
        tipo: 'recordatorio',
        accion: '/audiencias/detalle',
      ),
      Notificacion(
        id: 5,
        titulo: 'Notificación urgente',
        mensaje:
            'Su presencia es requerida urgentemente en el juzgado para el caso #789012.',
        fecha: DateTime.now().subtract(const Duration(minutes: 30)),
        tipo: 'urgente',
      ),
      Notificacion(
        id: 6,
        titulo: 'Actualización del sistema',
        mensaje:
            'El sistema estará en mantenimiento el día 15/05/2025 de 22:00 a 23:00.',
        fecha: DateTime.now().subtract(const Duration(days: 3)),
        tipo: 'sistema',
        leida: true,
      ),
      Notificacion(
        id: 7,
        titulo: 'Nueva asignación',
        mensaje: 'Ha sido asignado como responsable del expediente #101112.',
        fecha: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        tipo: 'expediente',
      ),
      Notificacion(
        id: 8,
        titulo: 'Confirmación de audiencia',
        mensaje:
            'Se requiere su confirmación para la audiencia del caso #131415 programada para el 12/05/2025.',
        fecha: DateTime.now().subtract(const Duration(hours: 12)),
        tipo: 'audiencia',
        accion: '/audiencias/detalle',
      ),
    ];

    setState(() {
      _notificaciones = notificaciones;
      _isLoading = false;
    });
  }

  List<Notificacion> _getNotificacionesFiltradas() {
    List<Notificacion> resultado = [..._notificaciones];

    // Aplicar filtro por tipo
    if (_filtroTipo != 'todas') {
      resultado = resultado.where((n) => n.tipo == _filtroTipo).toList();
    }

    // Aplicar filtro por tab (leídas/no leídas)
    if (_tabController.index == 0) {
      resultado = resultado.where((n) => !n.leida).toList();
    } else {
      resultado = resultado.where((n) => n.leida).toList();
    }

    // Ordenar por fecha
    if (_ordenarPorFecha) {
      resultado.sort((a, b) => b.fecha.compareTo(a.fecha));
    }

    return resultado;
  }

  void _marcarComoLeida(Notificacion notificacion) {
    // Aquí implementarías la lógica para marcar como leída en tu backend
    setState(() {
      final index = _notificaciones.indexWhere((n) => n.id == notificacion.id);
      if (index != -1) {
        _notificaciones[index] = Notificacion(
          id: notificacion.id,
          titulo: notificacion.titulo,
          mensaje: notificacion.mensaje,
          fecha: notificacion.fecha,
          tipo: notificacion.tipo,
          leida: true,
          icono: notificacion.icono,
          accion: notificacion.accion,
        );
      }
    });
  }

  void _eliminarNotificacion(Notificacion notificacion) {
    // Aquí implementarías la lógica para eliminar en tu backend
    setState(() {
      _notificaciones.removeWhere((n) => n.id == notificacion.id);
    });
  }

  void _marcarTodasComoLeidas() {
    // Aquí implementarías la lógica para marcar todas como leídas en tu backend
    setState(() {
      _notificaciones =
          _notificaciones
              .map(
                (n) =>
                    n.leida
                        ? n
                        : Notificacion(
                          id: n.id,
                          titulo: n.titulo,
                          mensaje: n.mensaje,
                          fecha: n.fecha,
                          tipo: n.tipo,
                          leida: true,
                          icono: n.icono,
                          accion: n.accion,
                        ),
              )
              .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todas las notificaciones marcadas como leídas'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificacionesFiltradas = _getNotificacionesFiltradas();
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _mostrarFiltros ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _mostrarFiltros = !_mostrarFiltros;
              });
            },
            tooltip: 'Filtros',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'marcar_todas') {
                _marcarTodasComoLeidas();
              } else if (value == 'refresh') {
                _cargarNotificaciones();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'marcar_todas',
                    child: Text('Marcar todas como leídas'),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Text('Actualizar'),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'No leídas'), Tab(text: 'Leídas')],
          onTap: (_) {
            setState(() {});
          },
          // Añade estas propiedades para cambiar los colores
          labelColor: Colors.white, // Color rojo para la pestaña seleccionada
          unselectedLabelColor:
              Colors.white, // Color gris para pestañas no seleccionadas
          indicatorColor: Color(
            0xFFB71C1C,
          ), // Color del indicador bajo la pestaña seleccionada
          // Opcional: personalizar la apariencia del indicador
          indicatorWeight: 3, // Grosor del indicador
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Panel de filtros
                  if (_mostrarFiltros)
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filtrar por:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('Todas', 'todas'),
                                _buildFilterChip('Audiencias', 'audiencia'),
                                _buildFilterChip('Expedientes', 'expediente'),
                                _buildFilterChip('Urgentes', 'urgente'),
                                _buildFilterChip(
                                  'Recordatorios',
                                  'recordatorio',
                                ),
                                _buildFilterChip('Sistema', 'sistema'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Ordenar por fecha más reciente:'),
                              const Spacer(),
                              Switch(
                                value: _ordenarPorFecha,
                                onChanged: (value) {
                                  setState(() {
                                    _ordenarPorFecha = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Contador de notificaciones
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Text(
                          '${notificacionesFiltradas.length} notificaciones',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (_tabController.index == 0 &&
                            notificacionesFiltradas.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.done_all),
                            label: const Text('Marcar todas como leídas'),
                            onPressed: _marcarTodasComoLeidas,
                          ),
                      ],
                    ),
                  ),

                  // Lista de notificaciones
                  Expanded(
                    child:
                        notificacionesFiltradas.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                              itemCount: notificacionesFiltradas.length,
                              itemBuilder: (context, index) {
                                final notificacion =
                                    notificacionesFiltradas[index];
                                return _buildNotificacionItem(notificacion);
                              },
                            ),
                  ),
                ],
              ),
      // Agregar después del cierre del body en el Scaffold
      floatingActionButton:
          user != null && user.idRol == "Juez"
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/notificaciones/crear').then(
                    (value) {
                      if (value == true) {
                        // Recargar notificaciones si se creó una nueva
                        _cargarNotificaciones();
                      }
                    },
                  );
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
                tooltip: 'Crear notificación',
              )
              : null,
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filtroTipo == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        onSelected: (selected) {
          setState(() {
            _filtroTipo = selected ? value : 'todas';
          });
        },
      ),
    );
  }

  Widget _buildNotificacionItem(Notificacion notificacion) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    final esFechaHoy =
        notificacion.fecha.day == DateTime.now().day &&
        notificacion.fecha.month == DateTime.now().month &&
        notificacion.fecha.year == DateTime.now().year;

    final fechaTexto =
        esFechaHoy
            ? 'Hoy ${timeFormat.format(notificacion.fecha)}'
            : dateFormat.format(notificacion.fecha);

    return Dismissible(
      key: Key('notificacion_${notificacion.id}'),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.done_all, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _eliminarNotificacion(notificacion);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Notificación eliminada')));
        } else {
          _marcarComoLeida(notificacion);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notificación marcada como leída')),
          );
        }
      },
      child: Card(
        elevation: notificacion.leida ? 1 : 3,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              notificacion.leida
                  ? BorderSide.none
                  : BorderSide(
                    color: notificacion.getColor().withOpacity(0.5),
                    width: 1,
                  ),
        ),
        child: InkWell(
          onTap: () {
            if (!notificacion.leida) {
              _marcarComoLeida(notificacion);
            }

            // Navegar a la acción correspondiente si existe
            if (notificacion.accion != null) {
              // Aquí implementarías la navegación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navegar a: ${notificacion.accion}')),
              );
            }
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: notificacion.getColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notificacion.getIconData(),
                        color: notificacion.getColor(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notificacion.titulo,
                            style: TextStyle(
                              fontWeight:
                                  notificacion.leida
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fechaTexto,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!notificacion.leida)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: notificacion.getColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notificacion.mensaje,
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                ),
                if (notificacion.accion != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navegar a la acción correspondiente
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Navegar a: ${notificacion.accion}'),
                          ),
                        );
                      },
                      child: const Text('Ver más'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _tabController.index == 0
                ? 'No tienes notificaciones pendientes'
                : 'No tienes notificaciones leídas',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_filtroTipo != 'todas')
            OutlinedButton.icon(
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Quitar filtros'),
              onPressed: () {
                setState(() {
                  _filtroTipo = 'todas';
                });
              },
            ),
        ],
      ),
    );
  }
}
