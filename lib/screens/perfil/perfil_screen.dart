// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/AuthResponse_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/screens/perfil/editarPerfil_screen.dart';
import 'package:si2/widgets/common/app_drawer.dart';
import 'package:si2/widgets/common/loading_indicator.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _especialidadController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _especialidadController = TextEditingController();

    // Cargar los datos del usuario al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _especialidadController.dispose();
    super.dispose();
  }

  // Carga los datos del usuario desde el provider
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Forzar la recarga de los datos del usuario
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // await authProvider
    //     .checkAuthStatus(); // Esto va a recargar los datos del usuario del API

    setState(() {
      final user = authProvider.user;
      if (user != null) {
        _nombreController.text = user.nombre;
        _apellidoController.text = user.apellido;
        _telefonoController.text = user.telefono ?? '';
        _direccionController.text = user.ciudad ?? '';
        _especialidadController.text = user.idRol ?? '';
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading || _isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mi Perfil'),
          backgroundColor: Color(0xFFB71C1C),
          foregroundColor: Colors.white,
        ),
        body: LoadingIndicator(message: 'Cargando datos del perfil...'),
      );
    }

    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mi Perfil'),
          backgroundColor: Color(0xFFB71C1C),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cambia este icono que no se ve correctamente
              Icon(
                Icons
                    .account_circle, // Usar un icono estándar de Material Design
                size: 80,
                color: Color(0xFFB71C1C), // Color principal de tu app
              ),
              SizedBox(height: 16),
              Text(
                'No has iniciado sesión',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.login), // Icono estándar de login
                label: Text('Ir a iniciar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sección superior con foto de perfil y datos principales
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Foto de perfil
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: _getColorForRole(user.idRol),
                        child: Text(
                          _getInitials(user.nombre, user.apellido),
                          style: TextStyle(fontSize: 42, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Nombre completo
                      Text(
                        '${user.nombre} ${user.apellido}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Rol del usuario
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getColorForRole(user.idRol).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.idRol,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getColorForRole(user.idRol),
                          ),
                        ),
                      ),

                      // Email
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.email, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              user.correo,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Botón editar perfil
                      /*if (!_isEditing)
                        ElevatedButton.icon(
                          icon: Icon(Icons.edit),
                          label: Text('Editar Perfil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB71C1C),
                            foregroundColor: Colors.white,
                            minimumSize: Size(200, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                        ),*/
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Modo edición o modo visualización
              if (_isEditing)
                _buildEditForm(user, authProvider)
              else
                _buildProfileDetails(user),
            ],
          ),
        ),
      ),
    );
  }

  // Construye el formulario de edición
  Widget _buildEditForm(User user, AuthProvider authProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar información',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB71C1C),
                ),
              ),
              Divider(),
              SizedBox(height: 8),

              // Campos editables
              _buildTextField(
                label: 'Nombre',
                controller: _nombreController,
                prefixIcon: Icons.person,
                validator:
                    (val) => val!.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              _buildTextField(
                label: 'Apellido',
                controller: _apellidoController,
                prefixIcon: Icons.person,
                validator:
                    (val) => val!.isEmpty ? 'El apellido es obligatorio' : null,
              ),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.cancel),
                    label: Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _loadUserData(); // Restablecer datos originales
                      });
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => _saveChanges(authProvider),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construye la vista de detalles del perfil (modo no edición)
  Widget _buildProfileDetails(User user) {
    return Column(
      children: [
        // Sección de Información Personal
        _buildInfoCard('Información Personal', Icons.person_outline, [
          _buildInfoRow('Nombre', user.nombre),
          _buildInfoRow('Apellido', user.apellido),
          _buildInfoRow('Teléfono', user.telefono ?? 'No especificado'),
          _buildInfoRow('Ciudad', user.ciudad ?? 'No especificada'),
          _buildInfoRow('Calle', user.calle ?? 'No especificada'),
          _buildInfoRow(
            'Codigo Postal',
            user.codigoPostal ?? 'No especificada',
          ),
          _buildInfoRow('Especialidad', user.idRol ?? 'No especificada'),
          if (user.fechaRegistro != null)
            _buildInfoRow(
              'Fecha de registro',
              _formatDate(user.fechaRegistro!),
            ),
        ]),

        SizedBox(height: 16),

        // Sección de Contacto
        _buildInfoCard('Información de Contacto', Icons.contact_phone, [
          _buildInfoRow('Email', user.correo),
          // _buildInfoRow('Teléfono', user.telefono ?? 'No especificado'),
          // _buildInfoRow('Dirección', user.direccion ?? 'No especificada'),
        ]),

        // Botón de cambio de contraseña
        ElevatedButton.icon(
          icon: Icon(Icons.lock_outline),
          label: Text('Cambiar Contraseña'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed:
              () => _mostrarDialogoCambiarPassword(
                context,
                user.idUsuario!,
                Provider.of<AuthProvider>(context, listen: false),
              ),
        ),

        SizedBox(height: 16),

        ElevatedButton.icon(
          icon: Icon(Icons.person),
          label: Text('Editar Usuario'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            // Navegar a la pantalla de edición de perfil
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => EditarPerfilScreen()),
            );
          },
        ),
      ],
    );
  }

  // Construye una tarjeta de información para el perfil
  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Color(0xFFB71C1C)),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C),
                  ),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  // Construye una fila de información para el perfil
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  // Construye un campo de texto para el formulario
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  // Funciones auxiliares
  String _getInitials(String nombre, String apellido) {
    return (nombre.isNotEmpty ? nombre[0] : '') +
        (apellido.isNotEmpty ? apellido[0] : '');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  // Manejo de cambio de contraseña
  void _mostrarDialogoCambiarPassword(
    BuildContext context,
    int userId,
    AuthProvider authProvider,
  ) {
    final _actualPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.lock, color: Color(0xFFB71C1C)),
                  SizedBox(width: 8),
                  Text('Cambiar Contraseña'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _actualPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB71C1C),
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_newPasswordController.text !=
                                _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Las contraseñas no coinciden'),
                                ),
                              );
                              return;
                            }

                            if (_newPasswordController.text.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'La contraseña debe tener al menos 6 caracteres',
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);

                            final success = await authProvider
                                .cambiarContrasena(
                                  _actualPasswordController.text,
                                  _newPasswordController.text,
                                );

                            setState(() => _isLoading = false);

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
                          },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Guardar cambios del perfil
  Future<void> _saveChanges(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userData = {
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
    };

    final success = await authProvider.actualizarPerfil(userData);

    setState(() {
      _isLoading = false;
      if (success) {
        _isEditing = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Perfil actualizado correctamente'
              : 'Error al actualizar el perfil',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
