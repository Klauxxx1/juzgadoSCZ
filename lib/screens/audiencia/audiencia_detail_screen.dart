import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:si2/screens/audiencia/audiencia_list_screen.dart';

class AudienciaDetailScreen extends StatefulWidget {
  final Audiencia audiencia;

  const AudienciaDetailScreen({Key? key, required this.audiencia})
    : super(key: key);

  @override
  State<AudienciaDetailScreen> createState() => _AudienciaDetailScreenState();
}

class _AudienciaDetailScreenState extends State<AudienciaDetailScreen> {
  bool _puedeEditar = false;
  late String _estadoActual;

  @override
  void initState() {
    super.initState();
    _estadoActual = widget.audiencia.estado;
    // Solo permitir edición si la audiencia está programada
    _puedeEditar = widget.audiencia.estado == 'Programada';
  }

  @override
  Widget build(BuildContext context) {
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
            _buildAccionesAudiencia(),
            _buildParticipantes(),
            _buildHistorialEstados(),
          ],
        ),
      ),
      bottomNavigationBar:
          _puedeEditar
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
                  color: widget.audiencia.getColorPorEstado().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.audiencia.getColorPorEstado(),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: widget.audiencia.getColorPorEstado(),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _estadoActual,
                      style: TextStyle(
                        color: widget.audiencia.getColorPorEstado(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                'ID: ${widget.audiencia.id}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            widget.audiencia.titulo,
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
                '${widget.audiencia.horaInicio.format(context)} - ${widget.audiencia.horaFin.format(context)}',
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
            _buildInfoRow('Sala:', widget.audiencia.sala, Icons.room),
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
              widget.audiencia.expedienteNumero,
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
              'Este caso se refiere a un litigio por incumplimiento contractual entre las partes involucradas. Se requiere resolución urgente debido a los plazos establecidos en el contrato original.',
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

  Widget _buildParticipantes() {
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
              'Participantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Divider(),
            _buildParticipanteItem(
              'Dr. Carlos Mendoza',
              'Juez',
              'assets/images/avatar_juez.png',
              Colors.purple,
            ),
            Divider(height: 16, indent: 60),
            _buildParticipanteItem(
              'Lic. María González',
              'Abogado Demandante',
              'assets/images/avatar_abogado1.png',
              Colors.blue,
            ),
            Divider(height: 16, indent: 60),
            _buildParticipanteItem(
              'Lic. Roberto Sánchez',
              'Abogado Demandado',
              'assets/images/avatar_abogado2.png',
              Colors.red,
            ),
            Divider(height: 16, indent: 60),
            _buildParticipanteItem(
              'Juan Pérez',
              'Demandante',
              'assets/images/avatar_demandante.png',
              Colors.green,
            ),
            Divider(height: 16, indent: 60),
            _buildParticipanteItem(
              'Ana Rodríguez',
              'Demandada',
              'assets/images/avatar_demandado.png',
              Colors.orange,
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
              widget.audiencia.getColorPorEstado(),
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
    String rol,
    String avatarPath,
    Color color,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(Icons.person, color: color),
        // En caso de tener imágenes reales:
        // backgroundImage: AssetImage(avatarPath),
      ),
      title: Text(nombre, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(rol),
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
        backgroundColor:
            nuevoEstado == 'En curso'
                ? Colors.green
                : nuevoEstado == 'Cancelada'
                ? Colors.red
                : nuevoEstado == 'Finalizada'
                ? Colors.blue
                : Colors.grey,
      ),
    );
  }

  String _calcularDuracion() {
    // Calcular la duración entre hora inicio y hora fin
    final horaInicio = TimeOfDay(
      hour: widget.audiencia.horaInicio.hour,
      minute: widget.audiencia.horaInicio.minute,
    );
    final horaFin = TimeOfDay(
      hour: widget.audiencia.horaFin.hour,
      minute: widget.audiencia.horaFin.minute,
    );

    int minInicio = horaInicio.hour * 60 + horaInicio.minute;
    int minFin = horaFin.hour * 60 + horaFin.minute;
    int duracionMinutos = minFin - minInicio;

    int horas = duracionMinutos ~/ 60;
    int minutos = duracionMinutos % 60;

    if (horas > 0) {
      return '$horas ${horas == 1 ? 'hora' : 'horas'} $minutos ${minutos == 1 ? 'minuto' : 'minutos'}';
    } else {
      return '$minutos ${minutos == 1 ? 'minuto' : 'minutos'}';
    }
  }

  String _obtenerTipoAudiencia() {
    // Aquí puedes determinar el tipo basado en el título o alguna otra lógica
    if (widget.audiencia.titulo.contains('conciliación')) {
      return 'Conciliación';
    } else if (widget.audiencia.titulo.contains('sentencia')) {
      return 'Sentencia';
    } else if (widget.audiencia.titulo.contains('testigos')) {
      return 'Testimonial';
    } else if (widget.audiencia.titulo.contains('pruebas')) {
      return 'Probatoria';
    } else {
      return 'General';
    }
  }
}
