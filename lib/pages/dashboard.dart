import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:core';
import 'package:collection/collection.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scheduleTask = schedule();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/blue_bg.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //
              greeting(),

              FutureBuilder<Widget>(
                future: scheduleTask, // a previously-obtained Future
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData) {
                    children = <Widget>[
                      snapshot.data!,
                    ];
                  } else if (snapshot.hasError) {
                    children = <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                            'Error: Cannot load schedule "${snapshot.error}"'),
                      ),
                    ];
                  } else {
                    children = const <Widget>[
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text('Fetching data...'),
                      ),
                    ];
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  greeting() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                helloAccordingToTime(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              Text(
                appData.userData.data?.username ?? " お客さん",
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              " ${appData.userData.data?.level} ",
              style: const TextStyle(
                fontSize: 48,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> schedule() async {
    await appData.assertDataIsLoaded();

    var groupedData = getReviewForecast(1);

    List<Map<String, dynamic>> formattedData = groupedData.entries
        .map((entry) => {"Date": entry.key, "count": entry.value})
        .toList();

    print(formattedData);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: SfCartesianChart(
        primaryXAxis: const CategoryAxis(
          borderWidth: 0,
          axisLine: AxisLine(
            width: 0,
          ),
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          majorGridLines: MajorGridLines(
            width: 0,
          ),
        ),
        primaryYAxis: const NumericAxis(
          borderWidth: 0,
          isVisible: true,
        ),
        series: <CartesianSeries>[
          // Renders line chart
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: formattedData,
            xValueMapper: (Map<String, dynamic> data, _) => data["Date"],
            yValueMapper: (Map<String, dynamic> data, _) => data["count"],
            // pointColorMapper: (Map<String, dynamic> data, _) => data.color,
            // markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  Map<String, int> getReviewForecast(int forecastDays) {
    var timeStampList = getListTimeStamp(forecastDays);

    Map<String, int> countByTimeMap = {};

    // There should be a better way to do this えへっ

    final now = DateTime.now();
    now.subtract(
      Duration(
          minutes: now.minute,
          seconds: now.second,
          milliseconds: now.millisecond),
    );

    countByTimeMap["now"] = appData.allSrsData!
        .where(
            (element) => element.data!.getNextReviewAsDateTime()!.isBefore(now))
        .toList()
        .length;

    String? date;
    int dateCount = 0;
    for (var item in timeStampList) {
      String key = DateFormat('dd/MM/yyyy hh:mm:ss a')
          .format((item.toLocal()))
          .replaceAll("/2024 ", "\n")
          .replaceAll(":00:00 ", "\n")
          .toLowerCase();

      key = "${key.substring(6)}\n${key.substring(0, 5)}";

      // "02\npm\n23/01"
      date ??= key.substring(6);

      if (date != key.substring(6)) {
        date = key.substring(6);
        dateCount += 1;
      } else {
        key = "${" " * dateCount}${key.substring(0, 5)}";
      }

      countByTimeMap[key] = appData.allSrsData!
        .where(
            (element) => element.data!.getNextReviewAsDateTime()! == item.toLocal())
        .toList()
        .length;
    }
    
    return countByTimeMap;
  }

  List<DateTime> getListTimeStamp(int days) {
    final now = DateTime.now().add(const Duration(hours: 1));
    now.subtract(
      Duration(
          minutes: now.minute,
          seconds: now.second,
          milliseconds: now.millisecond),
    );
    const oneHour = Duration(hours: 1);

    List<DateTime> dateTimeList = [];

    for (int i = 0; i < 24 * days; i++) {
      dateTimeList.add(now.add(oneHour * i));
    }

    return dateTimeList;
  }
}

/* Note
  - Greeting:
    + Name
    + WK info
    
  - Schedule:
    + Up comming 2 days. available_at <= now + 
  - Highlight:
    + Recent incorrect: streak = 1 | srs > 4
    + Low s: top 10 lowerest mem_score | srs > 4 + top 10 lowest percentage | %<80%
  - Progress: 
    + WK
    + JLPT
  - Recently 
*/
