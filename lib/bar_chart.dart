import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BarChartSample2 extends StatefulWidget {
  const BarChartSample2({Key? key});

  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color middleBarColor = const Color.fromARGB(255, 100, 83, 253);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;
  List? chartData;

  int touchedGroupIndex = -1;

  Future _getChartData() async {
    http.Response response = await http
        .get(Uri.parse("https://619e-41-220-231-175.ngrok.io/payload"));

    var data = json.decode(response.body);

    setState(() {
      chartData = data["Charts"];
    });

    return data["Charts"];
  }

  @override
  void initState() {
    _getChartData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final barGroup1 = makeGroupData(
      0,
      (chartData?[0]["items"]['sections'][0]['kpi_1'][0]['value']['figure']
              .toDouble() ??
          1.0 / 25000000),
      chartData?[0]["items"]['sections'][0]['kpi_1'][0]['projects']['figure']
              .toDouble() ??
          1.0,
      chartData?[0]["items"]['sections'][0]['kpi_1'][0]['projects']['figure']
              .toDouble() ??
          1.0,
    );

    // final barGroup2 = makeGroupData(1, 16, 12, 8);
    final barGroup2 = makeGroupData(
      0,
      (chartData?[0]["items"]['sections'][0]['kpi_2'][0]['value']['figure']
              .toDouble() ??
          1.0 / 25000000),
      chartData?[0]["items"]['sections'][0]['kpi_2'][0]['projects']['figure']
              .toDouble() ??
          1.0,
      chartData?[0]["items"]['sections'][0]['kpi_2'][0]['loans_and_grants']
                  ['figure']
              .toDouble() ??
          1.0,
    );

    final items = [barGroup1, barGroup2];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;

    return Scaffold(
      body: SafeArea(
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          color: const Color(0xff2c4260),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    makeTransactionsIcon(),
                    const SizedBox(
                      width: 38,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          chartData?[0]["items"]['title'] ?? 'Title',
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          chartData?[0]["chart_type"] ?? "Type",
                          style: const TextStyle(
                              color: Color(0xff77839a), fontSize: 16),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 38,
                ),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: 220,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.grey,
                          getTooltipItem: (a, b, c, d) => null,
                        ),
                        touchCallback: (FlTouchEvent event, response) {
                          if (response == null || response.spot == null) {
                            setState(() {
                              touchedGroupIndex = -1;
                              showingBarGroups = List.of(rawBarGroups);
                            });
                            return;
                          }

                          touchedGroupIndex =
                              response.spot!.touchedBarGroupIndex;

                          setState(() {
                            if (!event.isInterestedForInteractions) {
                              touchedGroupIndex = -1;
                              showingBarGroups = List.of(rawBarGroups);
                              return;
                            }
                            showingBarGroups = List.of(rawBarGroups);
                            if (touchedGroupIndex != -1) {
                              var sum = 0.0;
                              for (final rod
                                  in showingBarGroups[touchedGroupIndex]
                                      .barRods) {
                                sum += rod.toY;
                              }
                              final avg = sum /
                                  showingBarGroups[touchedGroupIndex]
                                      .barRods
                                      .length;

                              showingBarGroups[touchedGroupIndex] =
                                  showingBarGroups[touchedGroupIndex].copyWith(
                                barRods: showingBarGroups[touchedGroupIndex]
                                    .barRods
                                    .map((rod) {
                                  return rod.copyWith(toY: avg);
                                }).toList(),
                              );
                            }
                          });
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: bottomTitles,
                            reservedSize: 42,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: leftTitles,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: showingBarGroups,
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '1K';
    } else if (value == 10) {
      text = '5K';
    } else if (value == 19) {
      text = '10K';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>[
      chartData?[0]["items"]['sections'][0]['kpi_1'][0]['label'] ?? 'N/A',
      chartData?[0]["items"]['sections'][0]['kpi_2'][0]['label'] ?? 'N/A'
    ];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2, double y3) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: middleBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y3,
          color: rightBarColor,
          width: width,
        ),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
