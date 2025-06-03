import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/AudienciaResponse_model.dart';
import 'package:si2/models/AudienciaUsuariosResponse_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/providers/audiencia_provider.dart';

class AudienciaDetailScreen extends StatefulWidget {
  final AudienciaResponse audiencia;

  const AudienciaDetailScreen({Key? key, required this.audiencia})
    : super(key: key);

  @override
  State<AudienciaDetailScreen> createState() => _AudienciaDetailScreenState();
}

class _AudienciaDetailScreenState extends State<AudienciaDetailScreen> {
  bool _puedeEditar = false;
  late String _estadoActual;
  bool _cargandoUsuarios = false;
  String? _errorUsuarios;
  AudienciaUsuariosResponse? _participantes;

  // Métodos para obtener TimeOfDay a partir de la fecha
  TimeOfDay get _horaInicio => TimeOfDay(
    hour: widget.audiencia.fecha.hour,
    minute: widget.audiencia.fecha.minute,
  );

  TimeOfDay get _horaFin {
    final horasAdicionales = widget.audiencia.duracion?.hours ?? 1;
    final DateTime horaFinDateTime = widget.audiencia.fecha.add(
      Duration(hours: horasAdicionales),
    );
    return TimeOfDay(
      hour: horaFinDateTime.hour,
      minute: horaFinDateTime.minute,
    );
  }

  // Método para obtener color según estado
  Color _getColorPorEstado(String estado) {
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

  // Método para obtener color según rol
  Color _getColorPorRol(String rol) {
    switch (rol.toLowerCase()) {
      case 'juez':
        return Colors.purple;
      case 'abogado':
        return Colors.blue;
      case 'demandante':
        return Colors.green;
      case 'demandado':
        return Colors.red;
      case 'testigo':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.audiencia.estado;
    // Solo permitir edición si la audiencia está programada
    _puedeEditar = widget.audiencia.estado == 'Programada';

    // Cargar participantes al iniciar
    _cargarParticipantes();
  }

  Future<void> _cargarParticipantes() async {
    setState(() {
      _cargandoUsuarios = true;
      _errorUsuarios = null;
    });

    try {
      final audienciaProvider = Provider.of<AudienciaProvider>(
        context,
        listen: false,
      );
      final result = await audienciaProvider.obtenerUsuariosAudiencia(
        widget.audiencia.idAudiencia,
      );

      setState(() {
        _participantes = result;
        _cargandoUsuarios = false;
      });
    } catch (e) {
      setState(() {
        _errorUsuarios = e.toString();
        _cargandoUsuarios = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Audiencia'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_puedeEditar)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Aquí irá la navegación a la pantalla de edición
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Editar audiencia')));
              },
            ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Funcionalidad para compartir detalles de la audiencia
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Compartir detalles')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildDatosBasicos(),
            _buildDetallesExpediente(),
            // _buildAccionesAudiencia(),
            _buildParticipantes(),
            // _buildHistorialEstados(),
          ],
        ),
      ),
      bottomNavigationBar:
          (user?.idRol == "Juez") && _puedeEditar
              ? BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          onPressed: () {
                            _mostrarDialogoCancelar();
                          },
                          child: Text('Cancelar Audiencia'),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                          ),
                          onPressed: () {
                            _actualizarEstado('En curso');
                          },
                          child: Text('Iniciar Audiencia'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildParticipantes() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participantes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (_cargandoUsuarios)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_errorUsuarios != null)
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.red),
                    onPressed: _cargarParticipantes,
                    tooltip: 'Reintentar',
                  ),
              ],
            ),
            Divider(),
            if (_cargandoUsuarios)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorUsuarios != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'Error al cargar participantes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _errorUsuarios!,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _cargarParticipantes,
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_participantes == null || _participantes!.usuarios.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        color: Colors.grey,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No hay participantes registrados para esta audiencia',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _participantes!.usuarios.length,
                separatorBuilder:
                    (context, index) => Divider(height: 16, indent: 60),
                itemBuilder: (context, index) {
                  final usuario = _participantes!.usuarios[index];
                  return _buildParticipanteItem(
                    '${usuario.nombre} ${usuario.apellido}',
                    usuario.cargoEnAudiencia,
                    usuario.rol,
                    _getColorPorRol(usuario.cargoEnAudiencia),
                    usuario.idUsuario,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getColorPorEstado(_estadoActual).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getColorPorEstado(_estadoActual),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: _getColorPorEstado(_estadoActual),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _estadoActual,
                      style: TextStyle(
                        color: _getColorPorEstado(_estadoActual),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                'ID: ${widget.audiencia.idAudiencia}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            widget.audiencia.observacion,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
              SizedBox(width: 8),
              Text(
                DateFormat(
                  'EEEE, d MMMM yyyy',
                  'es',
                ).format(widget.audiencia.fecha),
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.grey[700]),
              SizedBox(width: 8),
              Text(
                '${_horaInicio.format(context)} - ${_horaFin.format(context)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatosBasicos() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(),
            _buildInfoRow('Ubicación:', widget.audiencia.ubicacion, Icons.room),
            _buildInfoRow('Duración:', _calcularDuracion(), Icons.timelapse),
            _buildInfoRow(
              'Tipo de Audiencia:',
              _obtenerTipoAudiencia(),
              Icons.category,
            ),
            _buildInfoRow('Prioridad:', 'Alta', Icons.flag, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesExpediente() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(),
            _buildInfoRow(
              'Número de Expediente:',
              widget.audiencia.idExpediente.toString(),
              Icons.folder,
            ),
            _buildInfoRow('Tipo de Caso:', 'Civil', Icons.gavel),
            _buildInfoRow(
              'Fecha de Apertura:',
              DateFormat('dd/MM/yyyy').format(DateTime(2025, 1, 15)),
              Icons.date_range,
            ),
            SizedBox(height: 16),
            Text(
              'Descripción del Caso:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: 8),
            Text(
              widget.audiencia.observacion,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccionesAudiencia() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  'Documentos',
                  Icons.description,
                  Colors.blue,
                  () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Ver documentos')));
                  },
                ),
                _buildActionButton(
                  'Notificar',
                  Icons.notifications,
                  Colors.orange,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Enviar notificaciones')),
                    );
                  },
                ),
                _buildActionButton('Acta', Icons.note_add, Colors.green, () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Generar acta')));
                }),
                _buildActionButton('Posponer', Icons.update, Colors.purple, () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Posponer audiencia')));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialEstados() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial de Estados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(),
            _buildEstadoHistorial(
              'Creada',
              'Audiencia programada por el sistema',
              '01/04/2025 09:15',
              Colors.grey,
              true,
            ),
            _buildEstadoHistorial(
              'Confirmada',
              'Todos los participantes confirmaron asistencia',
              '15/04/2025 14:30',
              Colors.blue,
              true,
            ),
            _buildEstadoHistorial(
              _estadoActual,
              _estadoActual == 'Programada'
                  ? 'Audiencia lista para realizarse en la fecha programada'
                  : _estadoActual == 'En curso'
                  ? 'Audiencia actualmente en progreso'
                  : _estadoActual == 'Finalizada'
                  ? 'Audiencia realizada correctamente'
                  : 'Audiencia cancelada por motivos de fuerza mayor',
              DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
              _getColorPorEstado(_estadoActual),
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[700]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: color ?? Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(title, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildParticipanteItem(
    String nombre,
    String cargo,
    String rol,
    Color color,
    int idUsuario,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Text(
          nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(nombre, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cargo),
          Text(rol, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.email_outlined, color: Colors.grey),
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Contactar a $nombre')));
        },
      ),
    );
  }

  Widget _buildEstadoHistorial(
    String estado,
    String descripcion,
    String fecha,
    Color color,
    bool showLine,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(Icons.check, size: 14, color: Colors.white),
            ),
            if (showLine)
              Container(width: 2, height: 50, color: Colors.grey[300]),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    estado,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    fecha,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                descripcion,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: showLine ? 30 : 10),
            ],
          ),
        ),
      ],
    );
  }

  void _mostrarDialogoCancelar() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cancelar Audiencia'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Está seguro que desea cancelar esta audiencia?'),
                SizedBox(height: 16),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Motivo de cancelación',
                    border: OutlineInputBorder(),
                    hintText: 'Ingrese el motivo de la cancelación',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No, volver'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _actualizarEstado('Cancelada');
                },
                child: Text('Sí, cancelar'),
              ),
            ],
          ),
    );
  }

  void _actualizarEstado(String nuevoEstado) {
    setState(() {
      _estadoActual = nuevoEstado;
      if (nuevoEstado != 'Programada') {
        _puedeEditar = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado actualizado a: $nuevoEstado'),
        backgroundColor: _getColorPorEstado(nuevoEstado),
      ),
    );
  }

  String _calcularDuracion() {
    final horas = widget.audiencia.duracion?.hours ?? 1;

    if (horas == 1) {
      return '1 hora';
    } else {
      return '$horas horas';
    }
  }

  String _obtenerTipoAudiencia() {
    // Determinar el tipo basado en el texto de la observación
    final observacion = widget.audiencia.observacion.toLowerCase();
    if (observacion.contains('conciliación')) {
      return 'Conciliación';
    } else if (observacion.contains('sentencia')) {
      return 'Sentencia';
    } else if (observacion.contains('testigos')) {
      return 'Testimonial';
    } else if (observacion.contains('pruebas')) {
      return 'Probatoria';
    } else {
      return 'General';
    }
  }
}
