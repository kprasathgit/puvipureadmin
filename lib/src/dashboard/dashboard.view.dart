import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puvipureadmin/project/routes/app_route_constants.dart';
import 'package:puvipureadmin/src/common/navigationservice.dart';
import 'package:puvipureadmin/src/dashboard/dashboard.controller.dart';
import 'package:puvipureadmin/src/navigation/naviagtion.dart';
import 'package:puvipureadmin/src/notification/notification.service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = NotificationService.pendingData;
      if (data != null && data['orderid'] != null) {
        final orderId = data['orderid']!;
        NotificationService.clearPending();
        NavigationService.pushTo(
          "${AppRouteConstants.orders}?orderId=$orderId",
        );
      }
      if (!_initialized) {
        _initialized = true;
        _refresh();
      }
    });
  }

  Future<void> _refresh() async {
    await context.read<DashboardController>().fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          Consumer<DashboardController>(
            builder: (context, controller, _) {
              if (controller.loading) {
                // 🔄 Show small progress instead of static refresh
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _refresh(),
              );
            },
          ),
        ],
      ),
      drawer: const NavigationDrawerWidget(),
      body: Consumer<DashboardController>(
        builder: (context, controller, _) {
          if (controller.loading && controller.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final dashboard = controller.dashboard;
          if (dashboard == null) {
            return Center(
              child: TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                onPressed: _refresh,
              ),
            );
          }

          final summary = dashboard.summary;
          final recentOrders = dashboard.tables['recentOrders'] ?? [];
          final lowStock = dashboard.tables['lowStock'] ?? [];
          final salesTrends = dashboard.charts['salesTrends'] ?? [];
          final userActivity = dashboard.charts['userActivity'] ?? [];

          return RefreshIndicator(
            onRefresh: _refresh, // 🔄 pull-to-refresh
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // required for pull-to-refresh
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- SUMMARY CARDS ----------------
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildSummaryCard(
                        "Total Orders",
                        summary['totalOrders'].toString(),
                        Colors.blue,
                      ),
                      _buildSummaryCard(
                        "Revenue Today",
                        (summary['revenueToday'] as num).toStringAsFixed(2),
                        Colors.green,
                      ),
                      _buildSummaryCard(
                        "Revenue This Month",
                        (summary['revenueThisMonth'] as num).toStringAsFixed(2),
                        Colors.yellow,
                      ),
                      _buildSummaryCard(
                        "New Users Today",
                        summary['newUsersToday'].toString(),
                        Colors.purple,
                      ),
                      _buildSummaryCard(
                        "Low Stock Products",
                        summary['lowStockProducts'].toString(),
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---------------- SALES TRENDS ----------------
                  Text(
                    "Sales Trends",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildSalesTrendChart(salesTrends),

                  const SizedBox(height: 24),
                  // ---------------- USER ACTIVITY ----------------
                  Text(
                    "User Activity",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildUserActivityChart(userActivity),

                  const SizedBox(height: 24),
                  // ---------------- RECENT ORDERS ----------------
                  Text(
                    "Recent Orders",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildTable(recentOrders, [
                    "orderId",
                    "totalAmount",
                    "status",
                    "createdDate",
                  ]),

                  const SizedBox(height: 24),
                  // ---------------- LOW STOCK PRODUCTS ----------------
                  Text(
                    "Low Stock Products",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildTable(lowStock, ["procode", "proname", "stockQty"]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Summary Card ----------------
  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      child: SizedBox(
        width: 180,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Table ----------------
  Widget _buildTable(List<dynamic> data, List<String> columns) {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
          rows: data.map((row) {
            return DataRow(
              cells: columns.map((col) {
                final value = row[col]?.toString() ?? '';
                return DataCell(Text(value));
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------- Sales Trends Chart ----------------
  Widget _buildSalesTrendChart(List<dynamic> salesTrends) {
    if (salesTrends.isEmpty) return const Text("No data");

    List<FlSpot> spots = [];
    for (int i = 0; i < salesTrends.length; i++) {
      final total =
          double.tryParse(salesTrends[i]['totalAmount'].toString()) ?? 0;
      spots.add(FlSpot(i.toDouble(), total));
    }

    return Card(
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      final index = val.toInt();
                      if (index < 0 || index >= salesTrends.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        salesTrends[index]['date'].toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- User Activity Chart ----------------
  Widget _buildUserActivityChart(List<dynamic> userActivity) {
    if (userActivity.isEmpty) return const Text("No data");

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < userActivity.length; i++) {
      final newUsers =
          int.tryParse(userActivity[i]['newUsers'].toString()) ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: newUsers.toDouble(), color: Colors.blue),
          ],
        ),
      );
    }

    return Card(
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      final index = val.toInt();
                      if (index < 0 || index >= userActivity.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        userActivity[index]['date'].toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }
}
