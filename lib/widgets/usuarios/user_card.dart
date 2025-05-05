import 'package:flutter/material.dart';
import 'package:si2/models/user_model.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const UserCard({
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar con iniciales
              CircleAvatar(
                radius: 24,
                backgroundColor: _getColorForRole(user.rol),
                child: Text(
                  _getInitials(user.nombre, user.apellido),
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(width: 16),

              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.nombre} ${user.apellido}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.rol,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getColorForRole(user.rol),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de acción (opcionales)
              if (showActions) ...[
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String nombre, String apellido) {
    return (nombre.isNotEmpty ? nombre[0] : '') +
        (apellido.isNotEmpty ? apellido[0] : '');
  }

  Color _getColorForRole(String role) {
    switch (role) {
      //  case 'Administrador':
      //    return Colors.purple;
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
}
