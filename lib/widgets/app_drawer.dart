import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    'assets/default_avatar.png',
                  ), // Placeholder image
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hola, Usuario 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Tesorería del grupo juvenil',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text('Actividades'),
            onTap: () {
              Navigator.pop(context);
              context.go('/actividades');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Participantes'),
            onTap: () {
              Navigator.pop(context);
              context.go('/participantes_activos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Inversiones'),
            onTap: () {
              Navigator.pop(context);
              context.go('/inversiones');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reportes'),
            onTap: () {
              Navigator.pop(context);
              context.go('/reportes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
              // Placeholder for settings
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Próximamente')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () async {
              Navigator.pop(context);
              await AuthService().signOut();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
