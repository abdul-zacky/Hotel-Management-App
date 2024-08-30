import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisma1/models/date_flow_model.dart';
import 'package:wisma1/providers/date_flows_provider.dart';

class MyChart extends ConsumerWidget {
  const MyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flows = ref.watch(dateFlowProvider);
    final maxY = flows.map((flow) => flow.amount).reduce(max).toDouble();

    return Padding(
      padding: const EdgeInsets.all(2),
      child: LineChart(
        mainLineData(flows, context, maxY),
      ),
    );
  }

  List<FlSpot> generateSpots(List<DateFlow> flowData) {
    return flowData
        .asMap()
        .entries
        .map((entry) =>
            FlSpot(entry.key.toDouble(), entry.value.amount.toDouble()))
        .toList();
  }

  LineChartData mainLineData(
      List<DateFlow> flowData, BuildContext context, double maxY) {
    return LineChartData(
      maxY: maxY,
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (value, meta) =>
                getBottomTitle(value, flowData, meta),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (value, meta) => leftTitles(value, maxY, meta),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: const FlGridData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: generateSpots(flowData),
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.4),
                const Color.fromARGB(255, 105, 137, 177).withOpacity(0.2),
              ],
              transform: const GradientRotation(pi / 40),
            ),
          ),
        ),
      ],
    );
  }

  Widget getBottomTitle(
      double value, List<DateFlow> flowData, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text;
    int index = value.toInt();
    if (index >= 0 && index < flowData.length) {
      text = flowData[index].date.day.toString();
    } else {
      text = '';
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(text, style: style),
    );
  }

  static Widget leftTitles(double value, double maxY, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text;
    final int step = (maxY / 5).ceil();
    final labelValue = (value * step / 1000000000).toInt()/100;

    if (labelValue > 0) {
      text = '${labelValue}M';
    } else {
      text = '0';
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }
}
