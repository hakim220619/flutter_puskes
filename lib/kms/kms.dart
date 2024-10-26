import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:http/http.dart' as http;

class ChartPageKms extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  ChartPageKms({Key? key}) : super(key: key);

  @override
  ChartPageKmsState createState() => ChartPageKmsState();
}

List<_SalesData> data = [];
List _listsData = [];

class ChartPageKmsState extends State<ChartPageKms> {
  Future<dynamic> ListUsers() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var url = Uri.parse('${dotenv.env['url']}/listUsers');
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      // print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data);
        setState(() {
          _listsData = data['data'];
          print(_listsData);
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  Future<dynamic> GrafikAllUsers(tahun) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var token = preferences.getString('token');
      var id_user = preferences.getString('id');
      var url = Uri.parse('${dotenv.env['url']}/getGravikSiswa');
      final response = await http.post(url, body: {
        'id': id_user.toString(),
        'tahun': tahun.toString()
      }, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      if (response.statusCode == 200) {
        final dataAll = jsonDecode(response.body);
        setState(() {
          for (var da in dataAll['data']) {
            data.add(_SalesData(
                '${da['nama_bulan']}', double.parse('${(da['bb_lahir'])}')));
          }
        });
      }
    } catch (e) {
      // print(e);
    }
  }

  // Sample data for three lists
  @override
  void initState() {
    super.initState();
    ListUsers();
  }

  @override
  void dispose() {
    data = [];
    // ignore: avoid_print
    super.dispose();
  }

  String? users;
  String? TahunContr;
  //  List<_SalesData> data = [ _SalesData('asd', 40)];

  @override
  Widget build(BuildContext context) {
    final List<String> tahun = <String>[
      "2023",
      "2024",
      "2025",
      "2026",
    ];
    return Scaffold(
        appBar: AppBar(
          title: const Text('Kms'),
        ),
        body: Column(children: [
          DropdownButtonFormField(
            padding: EdgeInsets.all(10),
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.date_range),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: 'Tahun'),
            isExpanded: true,
            items: tahun.map(
              (item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              },
            ).toList(),
            validator: (value) {
              if (value == null) return 'Silahkan Masukan Data';
              return null;
            },
            value: TahunContr,
            onChanged: (vale) {
              setState(() {
                data = [];
                GrafikAllUsers(vale);
                TahunContr = vale;
              });
            },
          ),

          
          //Initialize the chart widget
          SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Kms analysis'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries<_SalesData, String>>[
                LineSeries<_SalesData, String>(
                    dataSource: data,
                    xValueMapper: (_SalesData sales, _) => sales.year,
                    yValueMapper: (_SalesData sales, _) => sales.sales,
                    name: 'Berat Badan',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true))
              ]),
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     //Initialize the spark charts widget
          //     child: SfSparkLineChart.custom(
          //       //Enable the trackball
          //       trackball: SparkChartTrackball(
          //           activationMode: SparkChartActivationMode.tap),
          //       //Enable marker
          //       marker: SparkChartMarker(
          //           displayMode: SparkChartMarkerDisplayMode.all),
          //       //Enable data label
          //       labelDisplayMode: SparkChartLabelDisplayMode.all,
          //       xValueMapper: (int index) => data[index].year,
          //       yValueMapper: (int index) => data[index].sales,
          //       dataCount: 5,
          //     ),
          //   ),
          // )
        ]));
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
