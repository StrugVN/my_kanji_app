import 'package:flutter/material.dart';
import 'package:my_kanji_app/component/selector.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji_set.dart';
import 'package:my_kanji_app/data/wk_srs_stat.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:collection/collection.dart';

class Stuff extends StatefulWidget {
  const Stuff({super.key});

  @override
  State<Stuff> createState() => _StuffState();
}

class _StuffState extends State<Stuff> with AutomaticKeepAliveClientMixin   {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _secondScrollController = ScrollController();

  final TextEditingController sourceTypeController = TextEditingController();

  var dropDownItem = SourceTypeLabel.values
      .map<DropdownMenuEntry<SourceTypeLabel>>((SourceTypeLabel color) {
    return DropdownMenuEntry<SourceTypeLabel>(
      value: color,
      label: color.label,
      enabled: color.label != 'Grey',
      style: MenuItemButton.styleFrom(
        foregroundColor: color.color,
      ),
    );
  }).toList();

  int maxWkItems = 5;
  final ScrollController scrollController = ScrollController();

  bool showBackToTopButton = false;

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent) {
      if (maxWkItems < 60) {
        setState(() {
          maxWkItems += 5; // Increase by 5 items each time
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);

    createFormatMap();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          // ignore: sized_box_for_whitespace
          controller: _secondScrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 8,
            child: Image.asset(
              "assets/images/data_bg.jpg",
              // fit: BoxFit.fill,
              repeat: ImageRepeat.repeatY,
            ),
          ),
        ),
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final offset = notification.metrics.pixels * 0.4;
            _secondScrollController.jumpTo(offset); // Exact synchronization
            _secondScrollController.animateTo(offset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease);

            if (notification.metrics.pixels >
                MediaQuery.of(context).size.height * 0.5) {
              setState(() {
                showBackToTopButton = true;
              });
            } else {
              setState(() {
                showBackToTopButton = false;
              });
            }

            return true;
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // //////////////////////////////////////////////////
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: DropdownMenu<SourceTypeLabel>(
                            width: MediaQuery.of(context).size.width * 0.75,
                            controller: sourceTypeController..text = appData.stuffSourceLabel.label,
                            onSelected: (SourceTypeLabel? type) {
                              if (type != null) {
                                setState(() {
                                  appData.stuffSourceLabel = type;
                                });
                              }
                            },
                            // requestFocusOnTap: true,
                            // label: const Text('Source'),
                            dropdownMenuEntries: dropDownItem,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                getListItem(),
              ],
            ),
          ),
        ),
        showBackToTopButton
            ? Positioned(
                top: 10,
                right: MediaQuery.of(context).size.width / 2 - 20,
                child: Material(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50),
                  child: InkWell(
                    onTap: () {
                      // Scroll to top animation
                      scrollController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                      _secondScrollController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_upward, color: Colors.white),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  getListItem() {
    switch (appData.stuffSourceLabel) {
      case SourceTypeLabel.Wanikani:
        return getWkItems();
      case SourceTypeLabel.JLPT:
        return getOtherSourceItem([
          jlptN5,
          jlptN4,
          jlptN3,
          jlptN2,
          jlptN1
        ], [
          "N5",
          "N4",
          "N3",
          "N2",
          "N1",
        ]);
      case SourceTypeLabel.Joyo:
        return getOtherSourceItem([
          joyoG1,
          joyoG2,
          joyoG3,
          joyoG4,
          joyoG5,
          joyoG6,
          joyoG9,
        ], [
          "Grade 1",
          "Grade 2",
          "Grade 3",
          "Grade 4",
          "Grade 5",
          "Grade 6",
          "Grade 9",
        ]);
      case SourceTypeLabel.Frequency:
        return getOtherSourceItem([
          mostCommon500,
          mostCommon500_1000,
          mostCommon1000_1500,
          mostCommon1500_2000,
        ], [
          "Most used 1-500",
          "Most used 500-1000",
          "Most used 1000-1500",
          "Most used 1500-2000",
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  getWkItems() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: maxWkItems,
      itemBuilder: (context, index) {
        var subLevelKanji = appData.allKanjiData
            ?.where((element) => element.data?.level == index + 1)
            .toList();
        if (subLevelKanji != null) {
          return itemGroupCell(
            subLevelKanji.map((e) => e.data?.characters ?? "?").toList(),
            "WK ${index + 1}",
          );
        }
        return Container(); // Return empty container if subLevelKanji is null
      },
    );
  }

  getOtherSourceItem(
      List<String> sourceListOfItem, List<String> sourceListName) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sourceListOfItem.length,
      itemBuilder: (context, index) {
        return itemGroupCell(
          sourceListOfItem[index].split(","),
          sourceListName[index],
        );
      },
    );
  }

  itemGroupCell(List<String> itemList, String groupName) {
    // Sort
    itemList.sort((a, b) => getFormat(b).id - getFormat(a).id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(187, 224, 224, 224),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(color: Colors.grey.shade500),
            width: double.infinity,
            child: Text(
              groupName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            childAspectRatio: 3 / 3.5,
            crossAxisCount: 9,
            children: [
              for (var item in itemList)
                appData.characterCells[item] ?? SizedBox.fromSize(),
            ],
          ),
        ],
      ),
    );
  }

  itemCell(String s) {
    var format = getFormat(s);

    return GestureDetector(
      onTap: () {
        var kanji = appData.allKanjiData!
            .firstWhereOrNull((element) => element.data?.characters == s);

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
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(color: format.color),
        child: Text(
          s,
          style: TextStyle(
            color: format.textColor,
            fontSize: 21,
          ),
        ),
      ),
    );
  }

  SrsStage getFormat(String s) {
    if (appData.formatMap[s] == null) {
      return SrsStage.notExist;
    } else {
      return appData.formatMap[s]!;
    }
  }

  void createFormatMap() async {
    await AppData().assertDataIsLoaded();

    if( appData.characterCells.isNotEmpty) {
      return;
    }

    for (var s in appData.allKanjiData!) {
      if (s.data?.characters == null) {
        appData.characterCells[s.data!.characters!] = itemCell(s.data!.characters!);
        continue;
      }

      var format = s.srsData?.data?.getSrs();

      if (format == null) {
        appData.formatMap[s.data!.characters!] = SrsStage.unDiscovered;
      } else {
        appData.formatMap[s.data!.characters!] = format;
      }

      appData.characterCells[s.data!.characters!] = itemCell(s.data!.characters!);
    }

    setState(() {});
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }
}
