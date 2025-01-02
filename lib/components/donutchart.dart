import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChartExample extends StatelessWidget {
  final Color color;
  final double value;
  final double rest;
  const DonutChartExample(
      {super.key,
      required this.value,
      required this.rest,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PieChart(
        PieChartData(
          sections: _createSections(value, rest),
          centerSpaceRadius: 20,
          sectionsSpace: 10,
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections(v, r) {
    return [
      PieChartSectionData(
        color: Colors.white,
        value: r,
        title: '',
        radius: 20,
      ),
      PieChartSectionData(
        color: color,
        value: v,
        title: '',
        radius: 20,
      ),
    ];
  }
}
