import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:collection/collection.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';

class RadicalPage extends StatefulWidget {
  RadicalPage({super.key, required this.radical}) : hideAppBar = false;
  RadicalPage.hideAppBar({super.key, required this.radical})
      : hideAppBar = true;

  final Radical radical;

  bool hideAppBar;

  @override
  State<RadicalPage> createState() => _RadicalPageState();
}

class _RadicalPageState extends State<RadicalPage> {
  late final Radical radical;

  CharacterImages? svg;
  Future<String?>? svgString;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    radical = widget.radical;

    svg = radical.data!.characterImages
        ?.firstWhereOrNull((element) => element.contentType == "image/svg+xml");
    if (svg?.url != null) {
      svgString = getSvgString(svg!.url!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.hideAppBar
          ? AppBar(
              title: Text(
                radical.data!.characters ?? radical.data!.slug ?? "",
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
              backgroundColor: Colors.blue,
            )
          : null,
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (radical.data?.characters != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    radical.data?.characters ?? "N/A",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 96,
                    ),
                  ),
                )
              else if (radical.data?.characters == null && svg?.url != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: futureSingleWidget(getSvg(), true, true),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    radical.data?.slug ?? "N/A",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 96,
                    ),
                  ),
                ),
              Text(
                'Wanikani lv.${radical.data!.level}',
              ),
              const Divider(),
              Text(
                radical.data?.meanings!.map((e) => e.meaning).join(", ") ?? "",
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.left,
              ),
              getUsedInKanji(),
              const Divider(),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: " - Meaning mnemonic: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // TextSpan(text: radical.data?.meaningMnemonic ?? ""),
                    for (var textSpan
                        in buildWakiText(radical.data?.meaningMnemonic ?? ""))
                      textSpan,
                  ],
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Widget> getSvg() async {
    if (svgString == null) {
      return const SizedBox.shrink();
    }
    var svg = await svgString;

    if (svg != null) {
      return SvgPicture.string(
        svg,
        height: MediaQuery.of(context).size.width * 0.3,
        width: MediaQuery.of(context).size.width * 0.3,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget getUsedInKanji() {
    var usedKanjiIds = radical.data?.amalgamationSubjectIds;

    if (usedKanjiIds == null || usedKanjiIds.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Kanji>? similarKanji = AppData()
        .allKanjiData
        ?.where((element) => usedKanjiIds.contains(element.id))
        .toList();

    if (similarKanji == null || similarKanji.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> widgets = [];

    widgets.add(
      const Divider(color: Colors.black),
    );
    widgets.add(
      const Text(
        "Used kanji:",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    var gridList = <Widget>[];

    for (var kanji in similarKanji) {
      gridList.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KanjiPage(
                  kanji: kanji,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(5.0),
            // padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: Colors.red.shade500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kanji.data?.characters ?? "N/A",
                  style: const TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                  ),
                ),
                Text(
                  kanji.data?.readings
                          ?.firstWhereOrNull((item) => item.primary == true)!
                          .reading ??
                      "N/A",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  kanji.data?.meanings
                          ?.firstWhereOrNull((item) => item.primary == true)
                          ?.meaning ??
                      "N/A",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    widgets.add(
      GridView(
        padding: const EdgeInsets.only(left: 10.0),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: 3,
        ),
        physics: const NeverScrollableScrollPhysics(),
        children: gridList,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
