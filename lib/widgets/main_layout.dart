import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/connectivity_service.dart';
import 'package:myapp/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/caja')) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/caja');
        break;
    }
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, child) {
        if (connectivity.status == ConnectivityStatus.offline) {
          return Container(
            width: double.infinity,
            color: Colors.grey.shade700,
            padding: const EdgeInsets.all(8.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Modo sin conexión',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? 'Resumen de Actividades' : 'Control de Caja'),
        actions: [
          if (selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => context.go('/caja/log'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildOfflineBanner(context),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Caja',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
