import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/actividad.dart';
import 'package:myapp/models/gasto.dart';
import 'package:myapp/models/participante.dart';
import 'package:myapp/services/firebase_service.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportesScreen extends StatefulWidget {
  final Actividad actividad;

  const ReportesScreen({super.key, required this.actividad});

  @override
  ReportesScreenState createState() => ReportesScreenState();
}

class ReportesScreenState extends State<ReportesScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte: ${widget.actividad.nombre}'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: StreamBuilder<List<Participante>>(
        stream: _firebaseService.getParticipantes(widget.actividad.id),
        builder: (context, participantesSnapshot) {
          if (participantesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!participantesSnapshot.hasData || participantesSnapshot.data!.isEmpty) {
            return _buildEmptyStateCard(context, 'No hay participantes', Icons.people_outline, 'Añade participantes para ver los reportes.');
          }

          final participantes = participantesSnapshot.data!;

          return StreamBuilder<List<Gasto>>(
            stream: _firebaseService.getGastos(widget.actividad.id),
            builder: (context, gastosSnapshot) {
              if (gastosSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final gastos = gastosSnapshot.hasData ? gastosSnapshot.data! : <Gasto>[];
              
              return _buildReportContent(context, participantes, gastos);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, List<Participante> participantes, List<Gasto> gastos) {
    // Cálculos financieros
    final totalRecaudado = participantes.fold(0.0, (sum, p) => sum + p.pagos);
    final totalInversion = gastos.fold(0.0, (sum, g) => sum + g.monto);
    final gananciaNeta = totalRecaudado - totalInversion;

    // Cálculos para el nuevo gráfico de pie
    final totalEfectivo = participantes.fold(0.0, (sum, p) => sum + p.pagoEfectivo);
    final totalQr = participantes.fold(0.0, (sum, p) => sum + p.pagoQr);

    // Preparación de datos para los rankings
    final participantesConVentas = participantes.where((p) => p.llevo > 0).toList();
    if (participantesConVentas.isNotEmpty) {
      participantesConVentas.sort((a, b) => b.llevo.compareTo(a.llevo));
    }

    final deudores = participantes.where((p) {
      final deuda = (p.llevo * widget.actividad.precioChoripan) - p.pagos;
      return deuda > 0.1;
    }).toList();
    if (deudores.isNotEmpty) {
      deudores.sort((a, b) {
        final deudaA = (a.llevo * widget.actividad.precioChoripan) - a.pagos;
        final deudaB = (b.llevo * widget.actividad.precioChoripan) - b.pagos;
        return deudaB.compareTo(deudaA);
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildResumenFinancieroCard(context, totalRecaudado, totalInversion, gananciaNeta),
          const SizedBox(height: 24),
          if (totalRecaudado > 0) // Solo mostrar el gráfico si hay ingresos
            _buildIncomeDistributionChart(context, totalEfectivo, totalQr, totalRecaudado),
          const SizedBox(height: 24),
          if (participantesConVentas.isNotEmpty)
            _buildVentasCard(context, participantesConVentas)
          else
            _buildEmptyStateCard(context, 'No hay ventas', Icons.bar_chart_rounded, 'Las estadísticas de ventas se mostrarán aquí.'),
          const SizedBox(height: 24),
          if (deudores.isNotEmpty)
            _buildDeudasCard(context, deudores, widget.actividad.precioChoripan)
          else
            _buildEmptyStateCard(context, '¡Sin Deudas!', Icons.check_circle_outline, '¡Excelente! Todos están al día con sus pagos.'),
        ],
      ),
    );
  }

  Widget _buildResumenFinancieroCard(BuildContext context, double ingresos, double inversion, double ganancia) {
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);
    final gananciaColor = ganancia >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Resumen Financiero', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildFinancialRow(context, 'Ingresos Totales:', currencyFormat.format(ingresos), Icons.arrow_upward, Colors.lightGreen),
            const Divider(height: 20),
            _buildFinancialRow(context, 'Inversión Total:', currencyFormat.format(inversion), Icons.arrow_downward, Colors.orange),
            const Divider(height: 25, thickness: 1.5),
            _buildFinancialRow(context, 'Ganancia Neta:', currencyFormat.format(ganancia), Icons.attach_money, gananciaColor, isTotal: true),
            const SizedBox(height: 10),
            Text(
              'Ganancia Neta = Ingresos - Inversión',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(BuildContext context, String label, String value, IconData icon, Color iconColor, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: isTotal ? 24 : 20),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: isTotal ? 20 : 18, fontWeight: FontWeight.bold, color: iconColor)),
      ],
    );
  }

  Widget _buildIncomeDistributionChart(BuildContext context, double efectivo, double qr, double total) {
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);
    final List<PieChartSectionData> sections = [];

    if (efectivo > 0) {
      sections.add(PieChartSectionData(
        color: Colors.teal,
        value: efectivo,
        title: '${(efectivo / total * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }
    if (qr > 0) {
      sections.add(PieChartSectionData(
        color: Colors.blueAccent,
        value: qr,
        title: '${(qr / total * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Distribución de Ingresos', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: PieChart(PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  )),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend(Colors.teal, 'Efectivo', currencyFormat.format(efectivo)),
                      const SizedBox(height: 12),
                      _buildLegend(Colors.blueAccent, 'QR', currencyFormat.format(qr)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text, String amount) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  Widget _buildVentasCard(BuildContext context, List<Participante> participantes) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: [
            Text('Ranking de Ventas (unidades)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (participantes.first.llevo * 1.25).toDouble(),
                  barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => Colors.blueGrey)),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => SideTitleWidget(meta: meta, space: 4.0, child: Text(participantes[value.toInt()].nombre.split(' ').first, style: const TextStyle(fontSize: 10))), reservedSize: 30)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  gridData: FlGridData(show: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 0.5), horizontalInterval: 5),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(participantes.length, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: participantes[i].llevo.toDouble(), gradient: LinearGradient(colors: [colorScheme.primary.withOpacity(0.7), colorScheme.primary]), width: 22, borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)))])),
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

  Widget _buildDeudasCard(BuildContext context, List<Participante> deudores, double precioUnitario) {
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs.', decimalDigits: 2);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personas con Deuda', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...deudores.map((p) {
              final deuda = (p.llevo * precioUnitario) - p.pagos;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text(currencyFormat.format(deuda), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error, fontSize: 16)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context, String title, IconData icon, String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(color: Colors.grey[600]), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
