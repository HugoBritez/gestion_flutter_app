import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Gestión de Stock',
          style: TextStyle(
            color: kNeutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: kPrimaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          margin: const EdgeInsets.only(
            top: 16.0,
            bottom: 16.0,
            right: 16.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Consumer<AuthProvider>(
            builder: (context, auth, child) {
              final userData = auth.userData;
              return Column(
                children: [
                  // Header del drawer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: kBackgroundLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: kPrimaryColor,
                          child: Text(
                            (userData?['nombre'] as String?)?.isNotEmpty == true
                                ? (userData!['nombre'] as String)
                                    .characters
                                    .first
                                    .toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData?['nombre'] ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kNeutralDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData?['email'] ?? 'email@ejemplo.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: kNeutralDark.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Información de la empresa
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kBackgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              const Icon(Icons.business, color: kPrimaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData?['empresa'] ?? 'Empresa',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kNeutralDark,
                                ),
                              ),
                              Text(
                                userData?['rol'] == 1
                                    ? 'Administrador'
                                    : 'Usuario',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kNeutralDark.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Menú de opciones
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        _buildMenuItem(
                          icon: Icons.inventory,
                          title: 'Inventario',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navegar a inventario
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.category,
                          title: 'Categorías',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navegar a categorías
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.store,
                          title: 'Depósitos',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: Navegar a depósitos
                          },
                        ),
                        if (userData?['rol'] == 1)
                          _buildMenuItem(
                            icon: Icons.people,
                            title: 'Usuarios',
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navegar a usuarios
                            },
                          ),
                      ],
                    ),
                  ),
                  // Footer con versión
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: kNeutralDark.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Contenido principal aquí',
          style: TextStyle(color: kNeutralDark),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kBackgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: kPrimaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: kNeutralDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: kPrimaryColor.withOpacity(0.1),
    );
  }
}
