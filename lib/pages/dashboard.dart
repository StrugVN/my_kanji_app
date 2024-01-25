import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/paralax.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:core';
import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';
import 'package:animated_background/animated_background.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  ScrollController _secondScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var scheduleTask = schedule();

    return Stack(
      children: [
        SingleChildScrollView(
          // ignore: sized_box_for_whitespace
          controller: _secondScrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 2,
            child: Image.asset(
              "assets/images/blue_bg.jpg",
              fit: BoxFit.fill,
            ),
          ),
        ),
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final offset = notification.metrics.pixels * 0.5;
            _secondScrollController.jumpTo(offset); // Exact synchronization
            _secondScrollController.animateTo(offset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);
            return true;
          },
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
      ],
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
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: [
            const Text(
              'Review schedule',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            ExpansionTile(
              title: Text(
                  '${DateTime.now().toLocal().formatWeekdayName('EEEE')} (today)'),
              children: [
                getForecastOfDate(0),
              ],
            ),
            ExpansionTile(
              title: Text(DateTime.now()
                  .add(const Duration(days: 1))
                  .toLocal()
                  .formatWeekdayName('EEEE')),
              children: [
                getForecastOfDate(1),
              ],
            ),
            ExpansionTile(
              title: Text(DateTime.now()
                  .add(const Duration(days: 2))
                  .toLocal()
                  .formatWeekdayName('EEEE')),
              children: [
                getForecastOfDate(2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container getForecastOfDate(int day) {
    var groupedData = getReviewForecast(day);

    List<Map<String, dynamic>> formattedData = groupedData.entries
        .map((entry) => {"Date": entry.key, "count": entry.value})
        .toList();

    int accumulate = 0;
    for (var item in formattedData) {
      accumulate += item["count"] as int;
      item["accumulate"] = accumulate;
    }

    formattedData = formattedData.reversed.toList();

    return Container(
      height: (formattedData.length / 3) *
          MediaQuery.of(context).size.height *
          0.19,
      decoration: BoxDecoration(
        color: Colors.white70,
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
        axes: const <ChartAxis>[
          CategoryAxis(
            isVisible: true,
            name: 'secondaryXAxis',
            opposedPosition: true,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            title: AxisTitle(text: 'Accumulate'),
          ),
          NumericAxis(
            name: 'secondaryYAxis',
            opposedPosition: true,
            isVisible: false,
          )
        ],
        series: <BarSeries<Map<String, dynamic>, String>>[
          BarSeries<Map<String, dynamic>, String>(
            dataSource: formattedData,
            xValueMapper: (Map<String, dynamic> data, _) => data["Date"],
            yValueMapper: (Map<String, dynamic> data, _) => data["count"],
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.auto,
            ),
          ),
          BarSeries<Map<String, dynamic>, String>(
            dataSource: formattedData,
            xValueMapper: (Map<String, dynamic> data, _) =>
                data["accumulate"].toString(),
            yValueMapper: (Map<String, dynamic> data, _) => 0,
            xAxisName: 'secondaryXAxis',
            yAxisName: 'secondaryYAxis',
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
          milliseconds: now.millisecond,
          microseconds: now.microsecond),
    );

    String? date;

    for (var item in timeStampList) {
      String key = DateFormat('dd/MM/yyyy hh:mm:ss a')
          .format((item.toLocal()))
          .substring(11)
          .replaceAll(":00:00 ", " ")
          // .replaceAll(":00:00 ", "")
          .toLowerCase();

      // key = "${key.substring(6)} ${key.substring(0, 5)}";

      // "02 pm 23/01"
      date ??= key.substring(0, 5);

      // if (date != key.substring(6)) {
      //   date = key.substring(0, 5);
      //   dateCount += 1;
      // } else {
      //   key = "${" " * dateCount}${key.substring(6)}";
      // }
      if (forecastDays == 0) {
        countByTimeMap["now"] = appData.allSrsData!
            .where((element) {
              var nextReview = element.data?.getNextReviewAsDateTime();
              return nextReview == null
                  ? false
                  : nextReview.toLocal().isBefore(now);
            })
            .toList()
            .length;
      }

      countByTimeMap[key] = appData.allSrsData!
          .where((element) {
            var nextReview = element.data?.getNextReviewAsDateTime();
            return nextReview == null
                ? false
                : nextReview.toLocal() == item.toLocal();
          })
          .toList()
          .length;
    }

    countByTimeMap.removeWhere((key, value) => value == 0 && key != "now");

    return countByTimeMap;
  }

  List<DateTime> getListTimeStamp(int days) {
    DateTime startTime = days == 0
        ? DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, DateTime.now().hour)
            .add(const Duration(hours: 1))
        : DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day + days);

    const oneHour = Duration(hours: 1);

    List<DateTime> dateTimeList = [];

    int i = 0;
    var d = startTime.add(oneHour * i);
    while (d.day == startTime.day) {
      dateTimeList.add(d);
      i += 1;
      d = startTime.add(oneHour * i);
    }

    return dateTimeList;
  }
}

extension DateTimeFormatting on DateTime {
  String formatWeekdayName(String formatString) {
    return DateFormat(formatString).format(this);
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
