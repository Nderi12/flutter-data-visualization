import 'package:data_charts/bar_chart.dart';
import 'package:data_charts/number_flagged_chart.dart';
import 'package:data_charts/value_flagged_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var fullHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Charts',
          style: TextStyle(fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(height: fullHeight / 3, child: BarChartSample2()),
              SizedBox(height: 20),
              Container(child: ValueFlaggedChart()),
              SizedBox(height: 20),
              Container(child: NumberFlaggedChart())
            ],
          ),
        ),
      ),
    );
  }
}
