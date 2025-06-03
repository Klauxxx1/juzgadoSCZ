import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:si2/providers/auth_provider.dart';

class RoleBasedRoute extends StatelessWidget {
  final Widget adminRoute;
  final Widget clienteRoute;
  final Widget abogadoRoute;
  final Widget juezRoute;
  final Widget asistenteRoute;
  final Widget unauthorizedRoute;

  const RoleBasedRoute({
    super.key,
    required this.adminRoute,
    required this.clienteRoute,
    required this.abogadoRoute,
    required this.juezRoute,
    required this.asistenteRoute,
    required this.unauthorizedRoute,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return unauthorizedRoute;
    }

    switch (user.idRol) {
      case 'Administrador':
        return adminRoute;
      case 'Cliente':
        return clienteRoute;
      case 'Abogado':
        return abogadoRoute;
      case 'Juez':
        return juezRoute;
      case 'Asistente':
        return asistenteRoute;
      default:
        return unauthorizedRoute;
    }
  }
}
