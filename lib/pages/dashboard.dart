import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:my_kanji_app/component/selector.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/kanji_set.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/lesson.dart';
import 'package:my_kanji_app/pages/result_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/pages/wk_review.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/debouncer.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:core';
import 'package:collection/collection.dart';

class Dashboard extends StatefulWidget {
  const Dashboard(
      {super.key, required this.createQuiz, required this.changePageCallback});

  final void Function({
    required List<Kanji> listKanji,
    required List<Vocab> listVocab,
    required bool? kanjiOnFront,
  }) createQuiz;

  final void Function(int) changePageCallback;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  ScrollController _secondScrollController = ScrollController();

  int accumulateReviews = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AppData>(
      builder: (context, appData, child) {
        return dashboardBody();
      },
    );
  }

  Widget dashboardBody() {
    return Stack(
      children: [
        SingleChildScrollView(
          // ignore: sized_box_for_whitespace
          controller: _secondScrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 2.5,
            child: Image.asset(
              "assets/images/blue_bg_3.jpg",
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
                // //////////////////////////////////////////////////
                greeting(),

                schedule(),

                progression(),

                criticalItem(),

                newItem(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ///////////////////////////////////////////////////////////////////////////////
  greeting() {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.black12,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                appData.userData.data?.username != null
                    ? helloAccordingToTime()
                    : '',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              Text(
                appData.userData.data?.username ?? " ",
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
              " ${appData.userData.data?.level ?? ''} ",
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

  // ///////////////////////////////////////////////////////////////////////////////
  Widget schedule() {
    var scheduleTask = scheduleDetails();

    return FutureBuilder<Widget>(
      future: scheduleTask, // a previously-obtained Future
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            snapshot.data!,
          ];
        } else if (snapshot.hasError) {
          children = <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: Cannot load schedule "${snapshot.error}"'),
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
    );
  }

  // ///////////////////////////////////////////////////////////////////////////////
  Widget progression() {
    var progressionTask = progressionDetails();

    return FutureBuilder<Widget>(
      future: progressionTask,
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            snapshot.data!,
          ];
        } else if (snapshot.hasError) {
          children = <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: Cannot load progression "${snapshot.error}"'),
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
    );
  }

  // ///////////////////////////////////////////////////////////////////////////////
  Widget criticalItem() {
    var criticalItemTask = criticalItemWidget();

    return FutureBuilder<Widget>(
      future: criticalItemTask,
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            snapshot.data!,
          ];
        } else if (snapshot.hasError) {
          children = <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child:
                  Text('Error: Cannot load critical item "${snapshot.error}"'),
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
    );
  }

  // ///////////////////////////////////////////////////////////////////////////////
  Widget newItem() {
    var scheduleTask = newItemDetails();

    return FutureBuilder<Widget>(
      future: scheduleTask, // a previously-obtained Future
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = <Widget>[
            snapshot.data!,
          ];
        } else if (snapshot.hasError) {
          children = <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child:
                  Text('Error: Cannot load new items list "${snapshot.error}"'),
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
    );
  }

  Future<Widget> scheduleDetails() async {
    await appData.assertDataIsLoaded();

    var lessonCount = appData.allSrsData!
        .where((element) =>
            element.data != null &&
            element.data!.unlockedAt != null &&
            element.data!.availableAt == null)
        .toList()
        .length;

    var reviewData = appData.allSrsData!.where((element) {
      var nextReview = element.data?.getNextReviewAsDateTime();
      return nextReview == null
          ? false
          : nextReview.toLocal().isBefore(DateTime.now());
    }).toList();

    var reviewCount = reviewData.length;

    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'You have ',
            style: const TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(
                text: '$lessonCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' lesson${lessonCount > 1 ? "s" : ""} and '),
              TextSpan(
                text: '$reviewCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: ' review${reviewCount > 1 ? "s" : ""} available.\n'),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  List<Map<String, Object?>> newItemsList = getLessonReview();

                  if (newItemsList.isEmpty) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("No lesson of current setting")));
                      return;
                    }

                  if (lessonCount > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LessonPage(newItemsList: newItemsList,),
                        settings: const RouteSettings(name: "lessonPage"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      lessonCount > 0 ? Colors.blue : Colors.blue.shade200,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: const Text(
                      'Start lessons',
                      style: TextStyle(fontSize: 22),
                    )),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reviewCount > 0) {
                    List<dynamic> reviewList = getReviewList();

                    if (reviewList.isEmpty) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("No review of current setting")));
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WkReviewPage(
                          reviewItems: reviewList,
                        ),
                        settings: const RouteSettings(name: "reviewPage"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      reviewCount > 0 ? Colors.blue : Colors.blue.shade200,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                    child: const Text(
                      'Start reviews',
                      style: TextStyle(fontSize: 22),
                    )),
              ),
            ],
          ),
        ),
        Container(
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
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    '${DateTime.now().toLocal().formatWeekdayName('EEEE')} (today)',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  children: [
                    getForecastOfDate(0),
                  ],
                ),
                ExpansionTile(
                  title: Text(
                    DateTime.now()
                        .add(const Duration(days: 1))
                        .toLocal()
                        .formatWeekdayName('EEEE'),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  children: [
                    getForecastOfDate(1),
                  ],
                ),
                ExpansionTile(
                  title: Text(
                    DateTime.now()
                        .add(const Duration(days: 2))
                        .toLocal()
                        .formatWeekdayName('EEEE'),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  children: [
                    getForecastOfDate(2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getForecastOfDate(int day) {
    if (day == 0) accumulateReviews = 0;
    var groupedData = getReviewForecast(day);

    List<Map<String, dynamic>> formattedData = groupedData.entries
        .map((entry) => {"Date": entry.key, "count": entry.value})
        .toList();

    for (var item in formattedData) {
      accumulateReviews += item["count"] as int;
      item["accumulate"] = accumulateReviews;
    }

    formattedData = formattedData.reversed.toList();

    return Container(
      height: MediaQuery.of(context).size.height *
          (0.05 + formattedData.length / 2 * 0.09),
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
              showZeroValue: false,
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

  Future<Widget> progressionDetails() async {
    var srsList = await wKStat();

    var totalCount = getSrsCounts(srsList);

    Map<SrsStage, int> srsCounts = totalCount["srsCounts"];

    int learning = totalCount["learning"];

    // JPLT DATA COUNTS
    var totalCountN5 = getSrsCounts(srsList
        .where((element) =>
            element["isKanji"] &&
            element["char"] != null &&
            jlptN5.contains(element["char"][0]))
        .toList());
    Map<SrsStage, int> srsCountsN5 = totalCountN5["srsCounts"];
    var learningN5 = totalCountN5["learning"];
    int learnedN5 = (srsCountsN5[SrsStage.guru] ?? 0) +
        (srsCountsN5[SrsStage.guruII] ?? 0) +
        (srsCountsN5[SrsStage.master] ?? 0) +
        (srsCountsN5[SrsStage.enlighted] ?? 0);

    var totalCountN4 = getSrsCounts(srsList
        .where((element) =>
            element["isKanji"] &&
            element["char"] != null &&
            jlptN4.contains(element["char"][0]))
        .toList());
    Map<SrsStage, int> srsCountsN4 = totalCountN4["srsCounts"];
    var learningN4 = totalCountN4["learning"];
    int learnedN4 = (srsCountsN4[SrsStage.guru] ?? 0) +
        (srsCountsN4[SrsStage.guruII] ?? 0) +
        (srsCountsN4[SrsStage.master] ?? 0) +
        (srsCountsN4[SrsStage.enlighted] ?? 0);

    var totalCountN3 = getSrsCounts(srsList
        .where((element) =>
            element["isKanji"] &&
            element["char"] != null &&
            jlptN3.contains(element["char"][0]))
        .toList());
    Map<SrsStage, int> srsCountsN3 = totalCountN3["srsCounts"];
    var learningN3 = totalCountN3["learning"];
    int learnedN3 = (srsCountsN3[SrsStage.guru] ?? 0) +
        (srsCountsN3[SrsStage.guruII] ?? 0) +
        (srsCountsN3[SrsStage.master] ?? 0) +
        (srsCountsN3[SrsStage.enlighted] ?? 0);

    var totalCountN2 = getSrsCounts(srsList
        .where((element) =>
            element["isKanji"] &&
            element["char"] != null &&
            jlptN2.contains(element["char"][0]))
        .toList());
    Map<SrsStage, int> srsCountsN2 = totalCountN2["srsCounts"];
    var learningN2 = totalCountN2["learning"];
    int learnedN2 = (srsCountsN2[SrsStage.guru] ?? 0) +
        (srsCountsN2[SrsStage.guruII] ?? 0) +
        (srsCountsN2[SrsStage.master] ?? 0) +
        (srsCountsN2[SrsStage.enlighted] ?? 0);

    var totalCountN1 = getSrsCounts(srsList
        .where((element) =>
            element["isKanji"] &&
            element["char"] != null &&
            jlptN1.contains(element["char"][0]))
        .toList());
    Map<SrsStage, int> srsCountsN1 = totalCountN1["srsCounts"];
    var learningN1 = totalCountN1["learning"];
    int learnedN1 = (srsCountsN1[SrsStage.guru] ?? 0) +
        (srsCountsN1[SrsStage.guruII] ?? 0) +
        (srsCountsN1[SrsStage.master] ?? 0) +
        (srsCountsN1[SrsStage.enlighted] ?? 0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: [
          const Text(
            'WK Progression',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const Gap(10),
          GestureDetector(
            onTap: () {
              ResultData learningItems = ResultData(
                data: appData.allKanjiData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.apprenticeI ||
                              srs == SrsStage.apprenticeII ||
                              srs == SrsStage.apprenticeIII ||
                              srs == SrsStage.apprenticeIV;
                        })
                        .map((e) => e as dynamic)
                        .toList() +
                    appData.allVocabData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.apprenticeI ||
                              srs == SrsStage.apprenticeII ||
                              srs == SrsStage.apprenticeIII ||
                              srs == SrsStage.apprenticeIV;
                        })
                        .map((e) => e as dynamic)
                        .toList(),
                dataLabel: 'Learning',
                themeColor: SrsStage.apprenticeIV.color,
              );

              ResultData rememberingItems = ResultData(
                data: appData.allKanjiData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.guru || srs == SrsStage.guruII;
                        })
                        .map((e) => e as dynamic)
                        .toList() +
                    appData.allVocabData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.guru || srs == SrsStage.guruII;
                        })
                        .map((e) => e as dynamic)
                        .map((e) => e as dynamic)
                        .toList(),
                dataLabel: 'Remembering',
                themeColor: SrsStage.guruII.color,
              );

              ResultData memorizedItems = ResultData(
                data: appData.allKanjiData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.master;
                        })
                        .map((e) => e as dynamic)
                        .toList() +
                    appData.allVocabData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.master;
                        })
                        .map((e) => e as dynamic)
                        .toList(),
                dataLabel: 'Memorized',
                themeColor: Colors.green,
              );

              ResultData retainedItems = ResultData(
                data: appData.allKanjiData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.enlighted;
                        })
                        .map((e) => e as dynamic)
                        .toList() +
                    appData.allVocabData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.enlighted;
                        })
                        .map((e) => e as dynamic)
                        .toList(),
                dataLabel: 'Retained',
                themeColor: SrsStage.enlighted.color,
              );

              ResultData burnedItems = ResultData(
                data: appData.allKanjiData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.burned;
                        })
                        .map((e) => e as dynamic)
                        .toList() +
                    appData.allVocabData!
                        .where((element) {
                          var srs = element.srsData?.data?.getSrs();
                          return srs == SrsStage.burned;
                        })
                        .map((e) => e as dynamic)
                        .toList(),
                dataLabel: 'Retained',
                themeColor: const Color.fromARGB(31, 0, 0, 0),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(
                    listData: [
                      learningItems,
                      rememberingItems,
                      memorizedItems,
                      retainedItems,
                      burnedItems
                    ],
                    title: 'Wanikani progression',
                    titleTheme: Colors.indigo,
                  ),
                ),
              );
            },
            child: Wrap(
              alignment: WrapAlignment.start,
              children: [
                progressionCells(
                    "Learning", learning, SrsStage.apprenticeIV.color),
                progressionCells(
                    "Remembering",
                    (srsCounts[SrsStage.guru] ?? 0) +
                        (srsCounts[SrsStage.guruII] ?? 0),
                    SrsStage.guru.color),
                progressionCells("Memorized", srsCounts[SrsStage.master] ?? 0,
                    SrsStage.master.color),
                progressionCells("Retained", srsCounts[SrsStage.enlighted] ?? 0,
                    SrsStage.enlighted.color),
                progressionCells("Burned", srsCounts[SrsStage.burned] ?? 0,
                    SrsStage.burned.color),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              appData.stuffSourceLabel = SourceTypeLabel.JLPT;
              appData.manualNotify();
              widget.changePageCallback(2);
            },
            child: Column(
              children: [
                const Gap(10),
                const Text(
                  'JLPT',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                // -------------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Label
                    const Column(
                      children: [
                        Text(
                          "",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "N5",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "N4",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "N3",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "N2",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "N1",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("Not studied"),
                        Text(
                            "${jlptN5.replaceAll(",", "").length - learnedN5}"),
                        Text(
                            "${jlptN4.replaceAll(",", "").length - learnedN4}"),
                        Text(
                            "${jlptN3.replaceAll(",", "").length - learnedN3}"),
                        Text(
                            "${jlptN2.replaceAll(",", "").length - learnedN2}"),
                        Text(
                            "${jlptN1.replaceAll(",", "").length - learnedN1}"),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("In Progress"),
                        Text("$learningN5"),
                        Text("$learningN4"),
                        Text("$learningN3"),
                        Text("$learningN2"),
                        Text("$learningN1"),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("Learned"),
                        Text("$learnedN5"),
                        Text("$learnedN4"),
                        Text("$learnedN3"),
                        Text("$learnedN2"),
                        Text("$learnedN1"),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("Burned"),
                        Text("${srsCountsN5[SrsStage.burned] ?? 0}"),
                        Text("${srsCountsN4[SrsStage.burned] ?? 0}"),
                        Text("${srsCountsN3[SrsStage.burned] ?? 0}"),
                        Text("${srsCountsN2[SrsStage.burned] ?? 0}"),
                        Text("${srsCountsN1[SrsStage.burned] ?? 0}"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getSrsCounts(List<Map<String, dynamic>> srsList) {
    Map<SrsStage, int> srsCounts = {};
    srsList.forEach((item) {
      srsCounts[item["srs"]] = (srsCounts[item["srs"]] ?? 0) + 1;
    });

    var learning = (srsCounts[SrsStage.apprenticeI] ?? 0) +
        (srsCounts[SrsStage.apprenticeII] ?? 0) +
        (srsCounts[SrsStage.apprenticeIII] ?? 0) +
        (srsCounts[SrsStage.apprenticeIV] ?? 0);

    return {
      "srsCounts": srsCounts,
      "learning": learning,
    };
  }

  Widget progressionCells(String name, int data, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$data",
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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

    if (days == 0 && startTime.day > DateTime.now().day) {
      return dateTimeList;
    }

    int i = 0;
    var d = startTime.add(oneHour * i);
    while (d.day == startTime.day) {
      dateTimeList.add(d);
      i += 1;
      d = startTime.add(oneHour * i);
    }

    return dateTimeList;
  }

  Future<List<Map<String, dynamic>>> wKStat() async {
    await appData.assertDataIsLoaded();
    if (appData.allSrsData == null) {
      return [];
    }

    Map<int, String> kanjiMap = Map.fromEntries(
      appData.allKanjiData!
          .map((e) => {e.id!: e.data!.characters!})
          .toList()
          .expand((pair) => pair.entries),
    );

    Map<int, String> vocabMap = Map.fromEntries(
      appData.allVocabData!
          .map((e) => {e.id!: e.data!.characters!})
          .toList()
          .expand((pair) => pair.entries),
    );

    var combineMap = {...kanjiMap, ...vocabMap};

    var result = appData.allSrsData!
        .where((element) =>
            element.data != null && element.data!.getSrs() != SrsStage.burned)
        .map((e) => {
              "srs": e.data!.getSrs(),
              "id": e.data!.subjectId,
              "isKanji": e.data!.subjectType == "kanji",
              "char": combineMap[e.data!.subjectId] ?? "N/A"
            })
        .toList();

    return result;
  }

  Future<Widget> criticalItemWidget() async {
    await appData.assertDataIsLoaded();

    var recentMistakes = appData.allReviewData!
        .where((element) {
          try {
            var itemSrs = appData.allSrsData!.firstWhereOrNull(
                (e) => e.data!.subjectId == element.data!.subjectId);

            if (itemSrs == null) return false;

            return itemSrs.data!.passedAt != null &&
                (element.data!.meaningCurrentStreak == 1 ||
                    element.data!.readingCurrentStreak == 1 ||
                    (itemSrs.data!.getSrs().id < 6 &&
                        (element.data!.meaningCurrentStreak == 2 ||
                            element.data!.readingCurrentStreak == 2)) ||
                    element.data!.percentageCorrect! < 80);
          } on Exception catch (e) {
            // TODO
            return false;
          }
        })
        .map((e) => e.data?.subjectId)
        .toList();

    recentMistakes.removeWhere((element) => element == null);

    var kanjiMistakeList = appData.allKanjiData!
        .where((element) => recentMistakes.contains(element.id))
        // .map((e) => {"id": e.id, "char": e.data!.characters, "isKanji": true})
        .toList();

    var vocabMistakeList = appData.allVocabData!
        .where((element) => recentMistakes.contains(element.id))
        // .map((e) => {"id": e.id, "char": e.data!.characters, "isKanji": false})
        .toList();

    var recentMistakesData = kanjiMistakeList
            .map((e) => {
                  "id": e.id,
                  "char": e.data!.characters,
                  "isKanji": true,
                  "data": e
                })
            .toList() +
        vocabMistakeList
            .map((e) => {
                  "id": e.id,
                  "char": e.data!.characters,
                  "isKanji": false,
                  "data": e
                })
            .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Center(
            child: Text(
              'Recent mistake${recentMistakesData.length > 1 ? "s" : ""}',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          children: [
            if (recentMistakesData.isNotEmpty)
              Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      for (var item in recentMistakesData)
                        GestureDetector(
                          onTap: () {
                            if (item["isKanji"] as bool) {
                              var kanji = item["data"] as Kanji?;
                              if (kanji != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KanjiPage(
                                      kanji: kanji,
                                    ),
                                  ),
                                );
                              }
                            } else {
                              var vocab = item["data"] as Vocab?;
                              if (vocab != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VocabPage(
                                      vocab: vocab,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 3),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 3),
                            decoration: BoxDecoration(
                              color: item["isKanji"] as bool
                                  ? Colors.pink.shade600
                                  : Colors.purple.shade800,
                            ),
                            child: Text(
                              item["char"]?.toString() ?? "",
                              style: const TextStyle(
                                  fontSize: 28, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Gap(10),
                  GestureDetector(
                    onTap: () {
                      createQuizFromItemDialog(
                          kanjiMistakeList, vocabMistakeList);
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Practice these item${recentMistakesData.length > 1 ? "s" : ""}',
                          ),
                        ],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                ],
              )
            else
              const Text(
                'No mistake! 凄いですよ！',
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }

  Future<Widget> newItemDetails() async {
    await appData.assertDataIsLoaded();

    var lessonItem = appData.allSrsData!
        .where((element) =>
            element.data != null &&
            element.data!.unlockedAt != null &&
            element.data!.availableAt == null)
        .toList();

    var newItemsList = appData.allKanjiData!
        .where((element) =>
            lessonItem.firstWhereOrNull(
              (e) => e.data != null ? element.id == e.data!.subjectId! : false,
            ) !=
            null)
        .map((element) {
      var lessonItemStat = lessonItem.firstWhereOrNull(
        (e) => e.data != null ? element.id == e.data!.subjectId! : false,
      );
      return {
        "id": element.id,
        "char": element.data!.characters,
        "unlockedDate": lessonItemStat!.data!.getUnlockededDateAsDateTime(),
        "isKanji": true,
        "data": element,
      };
    }).toList();
    newItemsList = newItemsList +
        appData.allVocabData!
            .where((element) =>
                lessonItem.firstWhereOrNull(
                  (e) =>
                      e.data != null ? element.id == e.data!.subjectId! : false,
                ) !=
                null)
            .map((element) {
          var lessonItemStat = lessonItem.firstWhereOrNull(
            (e) => e.data != null ? element.id == e.data!.subjectId! : false,
          );
          return {
            "id": element.id,
            "char": element.data!.characters,
            "unlockedDate": lessonItemStat!.data!.getUnlockededDateAsDateTime(),
            "isKanji": false,
            "data": element,
          };
        }).toList();

    newItemsList.sort((a, b) => (b["unlockedDate"] as DateTime)
        .compareTo(a["unlockedDate"] as DateTime));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                listData: [
                  ResultData(
                      data: newItemsList.map((e) => e["data"]).toList(),
                      dataLabel: "Available Items",
                      themeColor: Colors.black)
                ],
                title: 'Lessons',
                titleTheme: Colors.pink,
              ),
            ),
          );
        },
        child: Column(
          children: [
            const Text(
              'Recently unlocked',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            for (var item in newItemsList.sublist(
                0, newItemsList.length < 5 ? newItemsList.length : 5))
              Container(
                decoration: BoxDecoration(
                  color: item["isKanji"] as bool
                      ? Colors.pink.shade600
                      : Colors.purple.shade800,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (item["char"] ?? "ERR") as String,
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    Text(
                      (item["unlockedDate"] != null
                          ? DateFormat('MMM dd')
                              .format(item["unlockedDate"] as DateTime)
                          : "ERR"),
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            newItemsList.length > 10
                ? RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(text: 'and '),
                        TextSpan(
                          text: '${newItemsList.length - 5}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' more...',
                        ),
                      ],
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  createQuizFromItemDialog(List<Kanji> listKanji, List<Vocab> listVocab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create flashcard set'),
        content: const Text(
          "Choose card front",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      widget.createQuiz(
                          listKanji: listKanji,
                          listVocab: listVocab,
                          kanjiOnFront: true);
                      Navigator.pop(context);
                    },
                    child: const Text('Kanji on front'),
                  ),
                  TextButton(
                    onPressed: () async {
                      widget.createQuiz(
                          listKanji: listKanji,
                          listVocab: listVocab,
                          kanjiOnFront: false);
                      Navigator.pop(context);
                    },
                    child: const Text('Kana on front'),
                  ),
                  TextButton(
                    onPressed: () async {
                      widget.createQuiz(
                          listKanji: listKanji,
                          listVocab: listVocab,
                          kanjiOnFront: null);
                      Navigator.pop(context);
                    },
                    child: const Text('Meaning on front'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).then((value) {});
  }

  List<dynamic> getReviewList() {
    var kanjiReviewList = appData.allKanjiData?.where((element) {
          var nextReview = element.srsData?.data?.getNextReviewAsDateTime();
          return nextReview == null
              ? false
              : nextReview.toLocal().isBefore(DateTime.now());
        }).toList() ??
        [];

    var vocabReviewList = appData.allVocabData?.where((element) {
          var nextReview = element.srsData?.data?.getNextReviewAsDateTime();
          return nextReview == null
              ? false
              : nextReview.toLocal().isBefore(DateTime.now());
        }).toList() ??
        [];

    var radicalReviewList = appData.allRadicalData?.where((element) {
          var nextReview = element.srsData?.data?.getNextReviewAsDateTime();
          return nextReview == null
              ? false
              : nextReview.toLocal().isBefore(DateTime.now());
        }).toList() ??
        [];

    List<dynamic> reviewList = [];

    if (appData.reviewSetting["kanji"] ?? false) {
      reviewList =
          reviewList + kanjiReviewList.map((e) => e as dynamic).toList();
    }
    if (appData.reviewSetting["vocab"] ?? false) {
      reviewList =
          reviewList + vocabReviewList.map((e) => e as dynamic).toList();
    }
    if (appData.reviewSetting["radical"] ?? false) {
      reviewList =
          reviewList + radicalReviewList.map((e) => e as dynamic).toList();
    }

    return reviewList;
  }

  List<Map<String, Object?>> getLessonReview() {
    var lessonItem = appData.allSrsData!
        .where((element) =>
            element.data != null &&
            element.data!.unlockedAt != null &&
            element.data!.availableAt == null)
        .toList();

    List<Map<String, Object?>> newItemsList = [];

    if (appData.lessonSetting["kanji"] ?? false) {
      newItemsList = newItemsList +
          appData.allKanjiData!
              .where((element) =>
                  lessonItem.firstWhereOrNull(
                    (e) => e.data != null
                        ? element.id == e.data!.subjectId!
                        : false,
                  ) !=
                  null)
              .map((element) {
            var lessonItemStat = lessonItem.firstWhereOrNull(
              (e) => e.data != null ? element.id == e.data!.subjectId! : false,
            );
            return {
              "id": element.id,
              "char": element.data!.characters,
              "unlockedDate":
                  lessonItemStat!.data!.getUnlockededDateAsDateTime(),
              "isKanji": true,
              "level": element.data?.level,
              "data": element,
            };
          }).toList();
    }

    if (appData.lessonSetting["vocab"] ?? false) {
      newItemsList = newItemsList +
          appData.allVocabData!
              .where((element) =>
                  lessonItem.firstWhereOrNull(
                    (e) => e.data != null
                        ? element.id == e.data!.subjectId!
                        : false,
                  ) !=
                  null)
              .map((element) {
            var lessonItemStat = lessonItem.firstWhereOrNull(
              (e) => e.data != null ? element.id == e.data!.subjectId! : false,
            );
            return {
              "id": element.id,
              "char": element.data!.characters,
              "unlockedDate":
                  lessonItemStat!.data!.getUnlockededDateAsDateTime(),
              "isKanji": false,
              "level": element.data?.level,
              "data": element,
            };
          }).toList();
    }

    if (appData.lessonSetting["radical"] ?? false) {
      newItemsList = newItemsList +
          appData.allRadicalData!
              .where((element) =>
                  lessonItem.firstWhereOrNull(
                    (e) => e.data != null
                        ? element.id == e.data!.subjectId!
                        : false,
                  ) !=
                  null)
              .map((element) {
            var lessonItemStat = lessonItem.firstWhereOrNull(
              (e) => e.data != null ? element.id == e.data!.subjectId! : false,
            );
            return {
              "id": element.id,
              "char": element.data!.characters,
              "unlockedDate":
                  lessonItemStat!.data!.getUnlockededDateAsDateTime(),
              "isKanji": false,
              "level": element.data?.level,
              "data": element,
            };
          }).toList();
    }

    return newItemsList;
  }
}

extension DateTimeFormatting on DateTime {
  String formatWeekdayName(String formatString) {
    return DateFormat(formatString).format(this);
  }
}
