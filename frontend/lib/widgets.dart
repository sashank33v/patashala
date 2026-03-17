import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> xValues;
  final List<double> yValues;
  final String title;

  const LineChartWidget({
    super.key,
    required this.xValues,
    required this.yValues,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      xValues.length,
      (i) => FlSpot(xValues[i], yValues[i]),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.indigo,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
              titlesData: const FlTitlesData(show: false),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ],
    );
  }
}
