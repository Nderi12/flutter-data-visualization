import 'dart:async';

import 'package:data_charts/api_service.dart';
import 'package:data_charts/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ValueFlaggedChart extends StatefulWidget {
  const ValueFlaggedChart({super.key});

  @override
  State<StatefulWidget> createState() => ValueFlaggedChartState();
}

class ValueFlaggedChartState extends State {
  int touchedIndex = -1;
  late StreamController _pieChartController;

  _fetchChartData() async {
    var response = await ApiService().getChartData();

    setState(() {
      _pieChartController.add(response);
    });
  }

  @override
  void initState() {
    _fetchChartData();
    _pieChartController = StreamController();
    super.initState();
  }

  Future<void> closeStream() => _pieChartController.close();

  @override
  void dispose() {
    closeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _pieChartController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.done:
              if (!snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Fetching data . . .'),
                      ],
                    ),
                  ),
                );
              }
              var chartData = snapshot.data[7];
              return Card(
                color: const Color(0xff2c4260),
                elevation: 0,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                        child: Text(
                      chartData["items"]['title'],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection ==
                                              null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: showingSections(
                                    chartData["items"]["series"]),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            Indicator(
                              color: Color(0xff0293ee),
                              text: 'Flagged',
                              isSquare: false,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Indicator(
                              color: Color(0xfff8b250),
                              text: 'Alert',
                              isSquare: false,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Indicator(
                              color: Color(0xff845bef),
                              text: 'Satisfactory',
                              isSquare: false,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              );
          }
        });
  }

  List<PieChartSectionData> showingSections(dataPoints) {
    return List.generate((dataPoints.length - 1), (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: double.parse(dataPoints["Flagged"][0]["percent"]),
            title: dataPoints["Flagged"][0]["percent"] + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: double.parse(dataPoints["Alert"][0]["percent"]),
            title: dataPoints["Alert"][0]["percent"] + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: double.parse(dataPoints["Satisfactory"][0]["percent"]),
            title: dataPoints["Satisfactory"][0]["percent"] + '%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
