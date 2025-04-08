import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/lesson.dart';
import 'package:my_kanji_app/pages/radical_info_page.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:collection/collection.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';

class ResultPage extends StatefulWidget {
  const ResultPage(
      {super.key,
      required this.listData,
      required this.title,
      required this.titleTheme,
      this.selectable = false});

  final List<ResultData> listData;
  final String title;
  final Color titleTheme;
  final bool selectable;

  @override
  State<ResultPage> createState() => _ResultPageState(
        listData: listData,
        title: title,
        titleTheme: titleTheme,
        selectable: selectable,
      );
}

class _ResultPageState extends State<ResultPage> {
  final List<ResultData> listData;
  final String title;
  final Color titleTheme;
  final bool selectable;

  List<int> selectedIds = [];

  _ResultPageState(
      {required this.listData,
      required this.title,
      required this.titleTheme,
      required this.selectable});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) =>
                    route.isFirst ||
                    route.settings.name == '/homePage' ||
                    route.settings.name == 'homePage' ||
                    route.settings.name == 'lessonPage' ||
                    route.settings.name == 'reviewPage');
              },
            ),
          ],
          backgroundColor: titleTheme,
        ),
        backgroundColor: Colors.blueGrey.shade100,
        body: Stack(children: [
          SingleChildScrollView(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                // margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    // color: Colors.blueGrey.shade200,
                    // image: DecorationImage(
                    //   image: AssetImage('assets/images/white_with_border.jpg'),
                    //   fit: BoxFit.fill,
                    // ),
                    ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: titleTheme,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: SizedBox(
                          child: RichText(
                            text: const TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' Close ',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    for (var group in widget.listData) groupContainer(group),
                  ],
                )),
          ),
          if (widget.selectable)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.titleTheme,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                    ),
                    onPressed: () {
                      openLessons();
                    },
                    child: SizedBox(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  ' Start lesson${selectedIds.length > 1 ? 's' : ''} (${selectedIds.length}) ',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            )
        ]));
  }

  Widget groupContainer(ResultData data) {
    if (data.data.isEmpty) {
      return const SizedBox.shrink();
    }

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
          title: Text(
            data.dataLabel,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: data.themeColor),
          ),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                for (var item in data.data) itemContainer(item),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget itemContainer(dynamic item) {
    Kanji? kanji;
    Vocab? vocab;
    Radical? radical;

    if (item is Kanji) {
      kanji = item;
    }
    if (item is Vocab) {
      vocab = item;
    }
    if (item is Radical) {
      radical = item;
    }

    var svg = radical?.data!.characterImages
        ?.firstWhereOrNull((element) => element.contentType == "image/svg+xml");

    Future<String?>? svgString;
    if (svg?.url != null) {
      svgString = getSvgString(svg!.url!);
    }

    return GestureDetector(
      onTap: () {
        if (selectable) {
          if (selectedIds.contains(item?.id)) {
            selectedIds.remove(item?.id);
          } else {
            selectedIds.add(item?.id);
          }
          setState(() {});

          return;
        }
        // -----------------------------------------------------------
        if (kanji != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KanjiPage(
                kanji: kanji!,
              ),
            ),
          );
        } else if (vocab != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VocabPage(
                vocab: vocab!,
              ),
            ),
          );
        } else if (radical != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RadicalPage(
                radical: radical!,
              ),
            ),
          );
        }
      },
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          decoration: BoxDecoration(
            // color: kanji != null ? Colors.pink.shade600 : Colors.purple.shade800,
            color: (kanji != null
                ? Colors.pink.shade600
                : (vocab != null
                    ? Colors.purple.shade800
                    : radical != null
                        ? Colors.lightBlue
                        : Colors.grey)),
          ),
          child: Column(
            children: [
              if (kanji != null ||
                  vocab != null ||
                  radical?.data?.characters != null ||
                  (radical != null && svgString == null))
                Text(
                  ((kanji != null
                          ? kanji.data?.characters
                          : (vocab != null
                              ? vocab.data?.characters
                              : radical != null
                                  ? (radical.data?.characters ??
                                      radical.data?.slug)
                                  : "N/A")) ??
                      "N/A"),
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontFamily: 'KyoukashoICA',
                  ),
                )
              else
                futureSingleWidget(getSvg(svgString), true, true),
            ],
          ),
        ),
        if (isSelected(item?.id))
          Positioned(
            top: -8,
            right: -8,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(50),
              child: Text(
                " ✓ ",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Future<Widget> getSvg(Future<String?>? svgString) async {
    if (svgString == null) {
      return const SizedBox.shrink();
    }
    var svg = await svgString;

    if (svg != null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.045,
        width: MediaQuery.of(context).size.width * 0.07,
        child: SvgPicture.string(
          svg,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isSelected(int? id) {
    return selectable && id != null && selectedIds.contains(id);
  }

  void openLessons() {
    List<Map<String, Object?>> newItemsList = getLessonReview();

    Navigator.pop(context, true);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonPage(
          newItemsList: newItemsList,
          ignoreLimit: true,
        ),
        settings: const RouteSettings(name: "lessonPage"),
      ),
    );
  }

  List<Map<String, Object?>> getLessonReview() {
    var lessonItem = appData.allSrsData!
        .where((element) =>
            element.data != null &&
            element.data!.unlockedAt != null &&
            element.data!.availableAt == null &&
            (element.data!.srsStage ?? 0) < 1 &&
            isSelected(element.data?.subjectId))
        .toList();

    List<Map<String, Object?>> newItemsList = [];

    newItemsList = newItemsList +
        appData.allKanjiData!
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
            "isKanji": true,
            "level": element.data?.level,
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
            "level": element.data?.level,
            "data": element,
          };
        }).toList();

    newItemsList = newItemsList +
        appData.allRadicalData!
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
            "level": element.data?.level,
            "data": element,
          };
        }).toList();

    return newItemsList;
  }
}

class ResultData {
  List<dynamic> data;
  String dataLabel;
  Color themeColor;

  ResultData(
      {required this.data, required this.dataLabel, required this.themeColor});
}
