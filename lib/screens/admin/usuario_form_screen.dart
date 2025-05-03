// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/user_model.dart';
import 'package:si2/providers/usuario_provider.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/widgets/common/loading_indicator.dart';

class UsuarioFormScreen extends StatefulWidget {
  final bool isEditing;
  const UsuarioFormScreen({required this.isEditing, super.key});

  @override
  _UsuarioFormScreenState createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para los campos de texto
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _especialidadController;
  late TextEditingController _matriculaController;
  late TextEditingController _passwordController;

  String _selectedRol = 'Cliente';
  bool _isLoading = false;
  bool _showPassword = false;
  User? _originalUser;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    _emailController = TextEditingController();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _especialidadController = TextEditingController();
    _matriculaController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _especialidadController.dispose();
    _matriculaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.isEditing) {
      final userId = ModalRoute.of(context)!.settings.arguments as int?;
      if (userId != null) {
        _cargarUsuario(userId);
      }
    }
  }

  Future<void> _cargarUsuario(int id) async {
    setState(() => _isLoading = true);

    try {
      await Provider.of<UsuarioProvider>(
        context,
        listen: false,
      ).obtenerDetallesUsuario(id);

      final user =
          Provider.of<UsuarioProvider>(
            context,
            listen: false,
          ).usuarioSeleccionado;
      if (user != null) {
        _originalUser = user;
        _nombreController.text = user.nombre;
        _apellidoController.text = user.apellido;
        _emailController.text = user.email;
        _telefonoController.text = user.telefono ?? '';
        _direccionController.text = user.direccion ?? '';
        _especialidadController.text = user.especialidad ?? '';
        _matriculaController.text = user.numeroMatricula?.toString() ?? '';
        _selectedRol = user.rol;
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final isAdmin = authProvider.user?.isAdministrador ?? false;

    // Determinar si es el propio usuario editándose a sí mismo

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Usuario' : 'Crear Usuario'),
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
                      // Datos personales
                      _buildSectionTitle('Datos Personales'),
                      _buildTextField(
                        label: 'Nombre',
                        controller: _nombreController,
                        validator:
                            (val) =>
                                val!.isEmpty
                                    ? 'El nombre es obligatorio'
                                    : null,
                      ),
                      _buildTextField(
                        label: 'Apellido',
                        controller: _apellidoController,
                        validator:
                            (val) =>
                                val!.isEmpty
                                    ? 'El apellido es obligatorio'
                                    : null,
                      ),

                      // Rol (solo admin puede cambiar)
                      if (isAdmin) _buildRolSelector(),

                      // Datos de contacto
                      _buildSectionTitle('Datos de Contacto'),
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val!.isEmpty) return 'El email es obligatorio';
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          return emailRegex.hasMatch(val)
                              ? null
                              : 'Email inválido';
                        },
                      ),
                      _buildTextField(
                        label: 'Teléfono',
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        label: 'Dirección',
                        controller: _direccionController,
                      ),

                      // Datos profesionales (solo para abogados y jueces)
                      if (_selectedRol == 'Abogado' ||
                          _selectedRol == 'Juez') ...[
                        _buildSectionTitle('Datos Profesionales'),
                        _buildTextField(
                          label: 'Especialidad',
                          controller: _especialidadController,
                        ),
                        if (_selectedRol == 'Abogado')
                          _buildTextField(
                            label: 'Número de Matrícula',
                            controller: _matriculaController,
                            keyboardType: TextInputType.number,
                          ),
                      ],

                      // Contraseña (solo en creación o si es admin)
                      if (!widget.isEditing || isAdmin) ...[
                        _buildSectionTitle('Datos de Acceso'),
                        _buildTextField(
                          label: 'Contraseña',
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          validator:
                              (val) =>
                                  !widget.isEditing && val!.length < 6
                                      ? 'La contraseña debe tener al menos 6 caracteres'
                                      : null,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                      ],

                      SizedBox(height: 24),

                      // Botones de acción
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB71C1C),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed:
                            usuarioProvider.isLoading
                                ? null
                                : () =>
                                    _guardarUsuario(context, usuarioProvider),
                        child:
                            usuarioProvider.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  widget.isEditing
                                      ? 'Actualizar'
                                      : 'Crear Usuario',
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFB71C1C),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  Widget _buildRolSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Rol',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: _selectedRol,
        items: [
          DropdownMenuItem(
            value: 'Administrador',
            child: Text('Administrador'),
          ),
          DropdownMenuItem(value: 'Juez', child: Text('Juez')),
          DropdownMenuItem(value: 'Abogado', child: Text('Abogado')),
          DropdownMenuItem(value: 'Asistente', child: Text('Asistente')),
          DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedRol = value;
            });
          }
        },
      ),
    );
  }

  Future<void> _guardarUsuario(
    BuildContext context,
    UsuarioProvider provider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userData = {
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'email': _emailController.text.trim(),
      'rol': _selectedRol,
      'telefono':
          _telefonoController.text.trim().isNotEmpty
              ? _telefonoController.text.trim()
              : null,
      'direccion':
          _direccionController.text.trim().isNotEmpty
              ? _direccionController.text.trim()
              : null,
      'especialidad':
          _especialidadController.text.trim().isNotEmpty
              ? _especialidadController.text.trim()
              : null,
    };

    // Agregar matrícula si es abogado
    if (_selectedRol == 'Abogado' &&
        _matriculaController.text.trim().isNotEmpty) {
      userData['numeroMatricula'] =
          int.tryParse(_matriculaController.text.trim()) as String?;
    }

    // Agregar contraseña solo si se está creando un usuario o si se ha proporcionado una nueva
    if (!widget.isEditing || _passwordController.text.isNotEmpty) {
      userData['password'] = _passwordController.text;
    }

    bool success;

    if (widget.isEditing && _originalUser != null) {
      success = await provider.actualizarUsuario(_originalUser!.id!, userData);
    } else {
      success = await provider.crearUsuario(userData);
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Usuario ${widget.isEditing ? 'actualizado' : 'creado'} correctamente',
          ),
        ),
      );
      Navigator.pop(context);
    } else if (provider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.error!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al ${widget.isEditing ? 'actualizar' : 'crear'} el usuario',
          ),
        ),
      );
    }
  }
}

// Screen para crear usuario
class CrearUsuarioScreen extends StatelessWidget {
  const CrearUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UsuarioFormScreen(isEditing: false);
  }
}

// Screen para editar usuario
class EditarUsuarioScreen extends StatelessWidget {
  const EditarUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UsuarioFormScreen(isEditing: true);
  }
}
