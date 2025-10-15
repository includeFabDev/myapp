import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/movimiento_caja.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:myapp/widgets/app_drawer.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportesGeneralesCajaScreen extends StatefulWidget {
  const ReportesGeneralesCajaScreen({super.key});

  @override
  _ReportesGeneralesCajaScreenState createState() => _ReportesGeneralesCajaScreenState();
}

class _ReportesGeneralesCajaScreenState extends State<ReportesGeneralesCajaScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes Generales de Caja'),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<MovimientoCaja>>(
        stream: _firebaseService.getMovimientosCajaStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay movimientos registrados.'),
            );
          }

          final movimientos = snapshot.data!;
          final datosMensuales = _procesarDatosMensuales(movimientos);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildResumenCard(movimientos),
                const SizedBox(height: 24),
                _buildGraficoMensual(datosMensuales),
                const SizedBox(height: 24),
                _buildTablaMovimientos(movimientos),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, Map<String, double>> _procesarDatosMensuales(List<MovimientoCaja> movimientos) {
    final Map<String, Map<String, double>> datos = {};

    for (final movimiento in movimientos) {
      final mes = DateFormat('yyyy-MM').format(movimiento.fecha);
      datos.putIfAbsent(mes, () => {'ingresos': 0, 'egresos': 0});

      if (movimiento.tipo == 'ingreso') {
        datos[mes]!['ingresos'] = datos[mes]!['ingresos']! + movimiento.monto;
      } else {
        datos[mes]!['egresos'] = datos[mes]!['egresos']! + movimiento.monto;
      }
    }

    return datos;
  }

  Widget _buildResumenCard(List<MovimientoCaja> movimientos) {
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);

    double totalIngresos = 0;
    double totalEgresos = 0;

    for (final movimiento in movimientos) {
      if (movimiento.tipo == 'ingreso') {
        totalIngresos += movimiento.monto;
      } else {
        totalEgresos += movimiento.monto;
      }
    }

    final balance = totalIngresos - totalEgresos;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResumenItem('Ingresos', totalIngresos, Colors.green, currencyFormat),
                _buildResumenItem('Egresos', totalEgresos, Colors.red, currencyFormat),
                _buildResumenItem('Balance', balance, balance >= 0 ? Colors.blue : Colors.red, currencyFormat),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(String titulo, double valor, Color color, NumberFormat format) {
    return Column(
      children: [
        Text(
          titulo,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          format.format(valor),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildGraficoMensual(Map<String, Map<String, double>> datosMensuales) {
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);

    // Ordenar los meses
    final mesesOrdenados = datosMensuales.keys.toList()..sort();

    final ingresosData = mesesOrdenados.map((mes) => datosMensuales[mes]!['ingresos']!).toList();
    final egresosData = mesesOrdenados.map((mes) => datosMensuales[mes]!['egresos']!).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Ingresos vs Egresos Mensuales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (ingresosData + egresosData).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final mes = mesesOrdenados[group.x.toInt()];
                        final valor = rod.toY;
                        final tipo = rodIndex == 0 ? 'Ingresos' : 'Egresos';
                        return BarTooltipItem(
                          '$tipo: ${currencyFormat.format(valor)}\nMes: ${DateFormat('MMM yyyy').format(DateTime.parse('$mes-01'))}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final mes = mesesOrdenados[value.toInt()];
                          return SideTitleWidget(
                            meta: meta,
                            space: 4,
                            child: Text(DateFormat('MMM yy').format(DateTime.parse('$mes-01'))),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  gridData: FlGridData(show: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 0.5)),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    mesesOrdenados.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: ingresosData[i],
                          color: Colors.green,
                          width: 16,
                        ),
                        BarChartRodData(
                          toY: egresosData[i],
                          color: Colors.red,
                          width: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 450),
                swapAnimationCurve: Curves.easeOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaMovimientos(List<MovimientoCaja> movimientos) {
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimos Movimientos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: movimientos.length > 10 ? 10 : movimientos.length,
                itemBuilder: (context, index) {
                  final movimiento = movimientos[index];
                  final isIngreso = movimiento.tipo == 'ingreso';
                  return ListTile(
                    leading: Icon(
                      isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIngreso ? Colors.green : Colors.red,
                    ),
                    title: Text(movimiento.descripcion),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(movimiento.fecha)),
                    trailing: Text(
                      '${isIngreso ? '+' : '-'}${currencyFormat.format(movimiento.monto)}',
                      style: TextStyle(
                        color: isIngreso ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
