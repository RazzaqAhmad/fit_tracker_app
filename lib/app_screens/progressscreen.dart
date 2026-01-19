import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String selectedTimeFrame = 'Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8E54E9), Color(0xFF6B38FB)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTimeTab('Week'),
                        _buildTimeTab('Month'),
                        _buildTimeTab('Year'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _buildChartCard(
              title: "Weight Progress",
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWeightStat(
                    "Current",
                    selectedTimeFrame == 'Year' ? "68.5 kg" : "68.5 kg",
                  ),
                  _buildWeightStat("Goal", "65.0 kg"),
                ],
              ),
              chart: SizedBox(height: 200, child: LineChart(_weightData())),
            ),

            _buildChartCard(
              title: "Calories Burned",
              chart: SizedBox(height: 200, child: BarChart(_caloriesData())),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildSummaryBox("24", "Workouts", "+12%", Colors.orange),
                  const SizedBox(width: 15),
                  _buildSummaryBox("18h", "Active Time", "+8%", Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildTimeTab(String label) {
    bool isSelected = selectedTimeFrame == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimeFrame = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF8E54E9) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    Widget? subtitle,
    required Widget chart,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) ...[const SizedBox(height: 15), subtitle],
          const SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }

  Widget _buildWeightStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSummaryBox(
    String value,
    String label,
    String trend,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.bolt, color: color.withOpacity(0.5)),
                Text(
                  trend,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _weightData() {
    List<FlSpot> spots;
    List<String> xLabels;

    switch (selectedTimeFrame) {
      case 'Month':
        spots = [
          const FlSpot(0, 72),
          const FlSpot(1, 71),
          const FlSpot(2, 70),
          const FlSpot(3, 68.5),
        ];
        xLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        break;
      case 'Year':
        spots = [
          const FlSpot(0, 75),
          const FlSpot(2, 73),
          const FlSpot(4, 72),
          const FlSpot(6, 68.5),
        ];
        xLabels = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
        break;
      default: // Week
        spots = [
          const FlSpot(0, 70.5),
          const FlSpot(1, 70.2),
          const FlSpot(2, 69.8),
          const FlSpot(3, 69.5),
          const FlSpot(4, 69.2),
          const FlSpot(5, 68.8),
          const FlSpot(6, 68.5),
        ];
        xLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < xLabels.length) {
                return Text(
                  xLabels[value.toInt()],
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: const Color(0xFF8E54E9),
          barWidth: 4,
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF8E54E9).withOpacity(0.1),
          ),
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }

  BarChartData _caloriesData() {
    List<BarChartGroupData> groups;
    List<String> xLabels;

    if (selectedTimeFrame == 'Month') {
      groups = [
        _makeGroup(0, 15000),
        _makeGroup(1, 17000),
        _makeGroup(2, 16000),
        _makeGroup(3, 18500),
      ];
      xLabels = ['W1', 'W2', 'W3', 'W4'];
    } else if (selectedTimeFrame == 'Year') {
      groups = [
        _makeGroup(0, 45000),
        _makeGroup(1, 52000),
        _makeGroup(2, 48000),
        _makeGroup(3, 60000),
      ];
      xLabels = ['Q1', 'Q2', 'Q3', 'Q4'];
    } else {
      groups = [
        _makeGroup(0, 1600),
        _makeGroup(1, 1800),
        _makeGroup(2, 1700),
        _makeGroup(3, 1900),
        _makeGroup(4, 1650),
        _makeGroup(5, 2100),
        _makeGroup(6, 1850),
      ];
      xLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }

    return BarChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < xLabels.length) {
                return Text(
                  xLabels[value.toInt()],
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      barGroups: groups,
    );
  }

  BarChartGroupData _makeGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.orange.withOpacity(0.8),
          width: selectedTimeFrame == 'Week' ? 15 : 30,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
