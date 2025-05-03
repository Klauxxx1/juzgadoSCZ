// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/usuario_provider.dart';
import 'package:si2/widgets/common/app_drawer.dart';
import 'package:si2/widgets/usuarios/user_card.dart';
import 'package:si2/widgets/common/error_view.dart';
import 'package:si2/widgets/common/loading_indicator.dart';

class UsuariosAdminScreen extends StatefulWidget {
  const UsuariosAdminScreen({super.key});

  @override
  State<UsuariosAdminScreen> createState() => _UsuariosAdminScreenState();
}

class _UsuariosAdminScreenState extends State<UsuariosAdminScreen> {
  String _filtroRol = '';
  String _busqueda = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Buscar usuarios...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) => setState(() => _busqueda = value),
                )
                : Text('Administración de Usuarios'),
        backgroundColor: Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _busqueda = '';
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed:
                () => Navigator.pushNamed(context, '/admin/usuarios/crear'),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Filtros de rol
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 8),
                _buildFilterChip('Todos', ''),
                _buildFilterChip('Administradores', 'Administrador'),
                _buildFilterChip('Jueces', 'Juez'),
                _buildFilterChip('Abogados', 'Abogado'),
                _buildFilterChip('Asistentes', 'Asistente'),
                _buildFilterChip('Clientes', 'Cliente'),
              ],
            ),
          ),
          Divider(),

          // Lista de usuarios filtrada
          Expanded(
            child: Consumer<UsuarioProvider>(
              builder: (context, usuarioProvider, child) {
                if (usuarioProvider.isLoading) {
                  return LoadingIndicator();
                }

                if (usuarioProvider.error != null) {
                  return ErrorView(
                    message: usuarioProvider.error!,
                    onRetry: () => usuarioProvider.cargarUsuarios(),
                  );
                }

                // Filtrar la lista según búsqueda y filtro de rol
                final usuarios =
                    usuarioProvider.usuarios
                        .where(
                          (user) =>
                              (_filtroRol.isEmpty || user.rol == _filtroRol) &&
                              (_busqueda.isEmpty ||
                                  user.nombre.toLowerCase().contains(
                                    _busqueda.toLowerCase(),
                                  ) ||
                                  user.apellido.toLowerCase().contains(
                                    _busqueda.toLowerCase(),
                                  ) ||
                                  user.email.toLowerCase().contains(
                                    _busqueda.toLowerCase(),
                                  )),
                        )
                        .toList();

                if (usuarios.isEmpty) {
                  return Center(
                    child: Text(
                      _busqueda.isNotEmpty || _filtroRol.isNotEmpty
                          ? 'No se encontraron usuarios con los filtros actuales'
                          : 'No hay usuarios registrados',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final user = usuarios[index];
                    return UserCard(
                      user: user,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/admin/usuarios/detalle',
                            arguments: user.id,
                          ),
                      onEdit:
                          () => Navigator.pushNamed(
                            context,
                            '/admin/usuarios/editar',
                            arguments: user.id,
                          ),
                      onDelete:
                          () => _mostrarDialogoConfirmacion(
                            context,
                            usuarioProvider,
                            user,
                          ),
                      showActions: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String rol) {
    final isSelected = _filtroRol == rol;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Color(0xFFB71C1C).withOpacity(0.2),
        checkmarkColor: Color(0xFFB71C1C),
        onSelected: (selected) {
          setState(() {
            _filtroRol = selected ? rol : '';
          });
        },
      ),
    );
  }

  void _mostrarDialogoConfirmacion(
    BuildContext context,
    UsuarioProvider provider,
    dynamic usuario,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Eliminar Usuario'),
          content: Text(
            '¿Está seguro que desea eliminar a ${usuario.nombre} ${usuario.apellido}?',
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
                provider.eliminarUsuario(usuario.id!).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Usuario eliminado correctamente')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}
