// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/user_model.dart';
import 'package:si2/providers/usuario_provider.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/widgets/common/loading_indicator.dart';
import 'package:si2/widgets/common/error_view.dart';

class DetalleUsuarioScreen extends StatefulWidget {
  const DetalleUsuarioScreen({super.key});

  @override
  _DetalleUsuarioScreenState createState() => _DetalleUsuarioScreenState();
}

class _DetalleUsuarioScreenState extends State<DetalleUsuarioScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userId = ModalRoute.of(context)!.settings.arguments as int?;
    if (userId != null) {
      Provider.of<UsuarioProvider>(
        context,
        listen: false,
      ).obtenerDetallesUsuario(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)!.settings.arguments as int?;
    Provider.of<UsuarioProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.user?.isAdministrador ?? false;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalle de Usuario'),
          backgroundColor: Color(0xFFB71C1C),
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text('ID de usuario no proporcionado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Usuario'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          if (isAdmin || authProvider.user?.id == userId)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    '/admin/usuarios/editar',
                    arguments: userId,
                  ),
            ),
        ],
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return LoadingIndicator();
          }

          if (provider.error != null) {
            return ErrorView(
              message: provider.error!,
              onRetry: () => provider.obtenerDetallesUsuario(userId),
            );
          }

          final user = provider.usuarioSeleccionado;
          if (user == null) {
            return Center(child: Text('Usuario no encontrado'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto de perfil y datos principales
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: _getColorForRole(user.rol),
                        child: Text(
                          user.nombre.substring(0, 1) +
                              user.apellido.substring(0, 1),
                          style: TextStyle(fontSize: 36, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${user.nombre} ${user.apellido}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        user.rol,
                        style: TextStyle(
                          fontSize: 18,
                          color: _getColorForRole(user.rol),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Información de contacto
                _buildSection('Información de Contacto', [
                  _buildInfoItem(Icons.email, 'Email', user.email),
                  if (user.telefono != null)
                    _buildInfoItem(Icons.phone, 'Teléfono', user.telefono!),
                  if (user.direccion != null)
                    _buildInfoItem(
                      Icons.location_on,
                      'Dirección',
                      user.direccion!,
                    ),
                ]),

                // Información profesional
                if (user.isAbogado || user.isJuez)
                  _buildSection('Información Profesional', [
                    if (user.especialidad != null)
                      _buildInfoItem(
                        Icons.business,
                        'Especialidad',
                        user.especialidad!,
                      ),
                    if (user.numeroMatricula != null && user.isAbogado)
                      _buildInfoItem(
                        Icons.badge,
                        'Nº Matrícula',
                        user.numeroMatricula!.toString(),
                      ),
                  ]),

                // Información de cuenta
                _buildSection('Información de Cuenta', [
                  if (user.fechaRegistro != null)
                    _buildInfoItem(
                      Icons.calendar_today,
                      'Fecha de Registro',
                      '${user.fechaRegistro!.day}/${user.fechaRegistro!.month}/${user.fechaRegistro!.year}',
                    ),
                ]),

                // Botones de acciones (solo para administrador o el propio usuario)
                if (isAdmin || authProvider.user?.id == userId)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.lock),
                          label: Text('Cambiar Contraseña'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB71C1C),
                            foregroundColor: Colors.white,
                          ),
                          onPressed:
                              () => _mostrarDialogoCambiarPassword(
                                context,
                                userId,
                              ),
                        ),
                        if (isAdmin && authProvider.user?.id != userId)
                          ElevatedButton.icon(
                            icon: Icon(Icons.delete),
                            label: Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed:
                                () => _confirmarEliminarUsuario(
                                  context,
                                  provider,
                                  user,
                                ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB71C1C),
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFFB71C1C), size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(value, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForRole(String role) {
    switch (role) {
      case 'Administrador':
        return Colors.purple;
      case 'Juez':
        return Colors.red;
      case 'Abogado':
        return Colors.blue;
      case 'Asistente':
        return Colors.green;
      case 'Cliente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _mostrarDialogoCambiarPassword(BuildContext context, int userId) {
    final actualPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Cambiar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actualPasswordController,
                decoration: InputDecoration(labelText: 'Contraseña actual'),
                obscureText: true,
              ),
              SizedBox(height: 8),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'Nueva contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 8),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirmar contraseña'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Las contraseñas no coinciden')),
                  );
                  return;
                }

                Provider.of<UsuarioProvider>(context, listen: false)
                    .cambiarContrasena(
                      userId,
                      actualPasswordController.text,
                      newPasswordController.text,
                    )
                    .then((success) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Contraseña actualizada correctamente'
                                : 'Error al cambiar la contraseña',
                          ),
                        ),
                      );
                    });
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmarEliminarUsuario(
    BuildContext context,
    UsuarioProvider provider,
    User user,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar Usuario'),
          content: Text(
            '¿Está seguro que desea eliminar a ${user.nombre} ${user.apellido}? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                provider.eliminarUsuario(user.id!).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Usuario eliminado correctamente'),
                      ),
                    );
                    Navigator.of(context).pop(); // Volver a la lista
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar el usuario')),
                    );
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
