import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/bienvenida_screen.dart';
import 'package:myapp/screens/caja_screen.dart';
import 'package:myapp/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    BienvenidaScreen(),
    CajaScreen(),
  ];

  static const List<String> _titles = <String>[
    'Resumen de Actividades',
    'Caja',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          // Mostramos el botón de historial solo si estamos en la pestaña de Caja.
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Ver Historial de Caja',
              onPressed: () {
                // Navegamos a la pantalla de logs usando la ruta anidada.
                context.go('/caja_log_screen');
              },
            ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
