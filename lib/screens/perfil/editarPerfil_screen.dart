import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/models/AuthResponse_model.dart';
import 'package:si2/providers/auth_provider.dart';
import 'package:si2/providers/usuario_provider.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _codigoPostalController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos del usuario actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosUsuario();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _calleController.dispose();
    _ciudadController.dispose();
    _codigoPostalController.dispose();
    super.dispose();
  }

  void _cargarDatosUsuario() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      _nombreController.text = user.nombre;
      _apellidoController.text = user.apellido;
      _correoController.text = user.correo;
      _telefonoController.text = user.telefono ?? '';
      _calleController.text = user.calle ?? '';
      _ciudadController.text = user.ciudad ?? '';
      _codigoPostalController.text = user.codigoPostal ?? '';
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userData = {
      'nombre': _nombreController.text,
      'apellido': _apellidoController.text,
      'correo': _correoController.text,
      'telefono': _telefonoController.text,
      'calle': _calleController.text,
      'ciudad': _ciudadController.text,
      'codigo_postal': _codigoPostalController.text,
    };

    final usuarioProvider = Provider.of<UsuarioProvider>(
      context,
      listen: false,
    );
    final resultado = await usuarioProvider.editarPerfil(userData);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (resultado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${usuarioProvider.error ?? "No se pudo actualizar el perfil"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil'), elevation: 0),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final User? user = authProvider.user;

          if (user == null) {
            return const Center(child: Text('No hay usuario autenticado'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.2),
                        child: Text(
                          '${user.nombre[0]}${user.apellido[0]}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sección de información personal
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información Personal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Nombre
                            TextFormField(
                              controller: _nombreController,
                              decoration: InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Apellido
                            TextFormField(
                              controller: _apellidoController,
                              decoration: InputDecoration(
                                labelText: 'Apellido',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu apellido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Correo
                            TextFormField(
                              controller: _correoController,
                              decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu correo';
                                }
                                if (!value.contains('@')) {
                                  return 'Ingresa un correo válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Teléfono
                            TextFormField(
                              controller: _telefonoController,
                              decoration: InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sección de dirección
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dirección',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Calle
                            TextFormField(
                              controller: _calleController,
                              decoration: InputDecoration(
                                labelText: 'Calle',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.home),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Ciudad
                            TextFormField(
                              controller: _ciudadController,
                              decoration: InputDecoration(
                                labelText: 'Ciudad',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.location_city),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Código Postal
                            TextFormField(
                              controller: _codigoPostalController,
                              decoration: InputDecoration(
                                labelText: 'Código Postal',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(
                                  Icons.markunread_mailbox,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'Guardar Cambios',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
