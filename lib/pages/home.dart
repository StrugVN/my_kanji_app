import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/dashboard.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/review.dart';
import 'package:my_kanji_app/pages/archive.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:my_kanji_app/pages/vocab_info_page.dart';
import 'package:my_kanji_app/utility/debouncer.dart';
import 'package:collection/collection.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:preload_page_view/preload_page_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex = 0;

  late List<Widget> pageList;

  final AppData appData = AppData();

  bool isSearchOpen = false;

  final searchFocusNode = FocusNode();

  final kanaKit = const KanaKit();

  final _debouncer = Debouncer(duration: const Duration(milliseconds: 500));

  var searchTextController = TextEditingController();

  var pageController = PreloadPageController(initialPage: 0);
  // var pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    pageList = <Widget>[
      Dashboard(
        createQuiz: createStudySet,
        changePageCallback: changePage,
      ),
      Review(),
      Archive(),
    ];

    searchFocusNode.addListener(() {
      setState(() {
        isSearchOpen = searchFocusNode.hasFocus;
        if (!isSearchOpen) {
          searchTextController.text = "";
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (pageIndex > 0) {
          pageIndex = 0;
          setState(() {
            pageController.animateToPage(
              pageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          });
        } else {
          await showLogOutDialog(context).then((confirm) {
            if (confirm != null && confirm) {
              Navigator.pop(context, true);
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Home")),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () => showAppBarSearch(),
            ),
            if (isSearchOpen)
              SizedBox(
                width: 200,
                child: searchTextField(),
              ),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              onPressed: () => showAppBarMenu(context),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            children: [
              // PageView(
              //   controller: pageController,
              //   onPageChanged: (index) {
              //     setState(() {
              //       pageIndex = index;
              //     });
              //   },
              //   children: pageList,
              // ),
              PreloadPageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    pageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return pageList[index];
                },
                itemCount: pageList.length,
                preloadPagesCount: 3,
              ),
              if (isSearchOpen && searchTextController.text.isNotEmpty)
                searchResult(searchTextController.text),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: (index) {
            setState(
              () {
                pageIndex = index;
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
            );
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
            BottomNavigationBarItem(
                icon: Icon(Icons.book), label: "Self-study"),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: "Archive"),
          ],
        ),
      ),
    );
  }

  TextField searchTextField() {
    return TextField(
      controller: searchTextController,
      focusNode: searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search...',
        border: InputBorder.none,
        suffixIcon: searchTextController.text.isNotEmpty
            ? GestureDetector(
                onTap: () => setState(() {
                  searchTextController.text = "";
                }),
                child: const Icon(Icons.close),
              )
            : const SizedBox.shrink(),
      ),
      onChanged: (value) {
        _debouncer.run(() => setState(() {
              searchTextController.text = value;
            }));
      },
    );
  }

  Future<bool?> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Return to login screen'),
        content: const Text('Log out and return to login screen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void showAppBarMenu(BuildContext context) {
    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(MediaQuery.of(context).size.width * 0.8,
          MediaQuery.of(context).size.height * 0.05, 0, 0),
      items: <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 1,
          child: const Text('Sync data'),
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Syncing data")));
            // Load data
            appData.loadData().then((value) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Data synced")));
            });
          },
        ),
        PopupMenuItem<int>(
          value: 0,
          child: const Text('Log out'),
          onTap: () async {
            await showLogOutDialog(context).then((value) {
              if (value != null && value) {
                Navigator.pop(context, true);
              }
            });
          },
        ),
      ],
    );
  }

  void showAppBarSearch() {
    setState(() {
      isSearchOpen = !isSearchOpen;
      searchFocusNode.requestFocus();
    });
  }

  void showSearchResult(String searchValue) {}

  Widget searchResult(String searchValue) {
    if (searchValue.isNotEmpty) {
      String searchJP = kanaKit.toHiragana(searchValue);

      print(searchJP);

      var kanjiExactResult = appData.allKanjiData!.where((element) {
        return element.data?.characters == searchJP ||
            element.data?.characters?.toLowerCase() ==
                searchValue.toLowerCase() ||
            element.data!.meanings!
                .where((element) =>
                    element.meaning?.toLowerCase() == searchValue.toLowerCase())
                .isNotEmpty ||
            element.data!.auxiliaryMeanings!
                .where((element) =>
                    element.meaning?.toLowerCase() == searchValue.toLowerCase())
                .isNotEmpty ||
            element.data!.readings!
                .where((element) =>
                    element.primary == true && element.reading == searchJP)
                .isNotEmpty;
      });

      var kanjiResult = appData.allKanjiData!.where((element) {
        return ((element.data?.characters?.startsWith(searchJP) ?? false) ||
            (element.data?.characters?.startsWith(searchValue) ?? false) ||
            element.data!.meanings!
                .where((element) =>
                    element.meaning
                        ?.toLowerCase()
                        .startsWith(searchValue.toLowerCase()) ??
                    false)
                .isNotEmpty ||
            element.data!.auxiliaryMeanings!
                .where((element) =>
                    element.meaning
                        ?.toLowerCase()
                        .startsWith(searchValue.toLowerCase()) ??
                    false)
                .isNotEmpty ||
            element.data!.readings!
                .where(
                    (element) => element.reading?.startsWith(searchJP) ?? false)
                .isNotEmpty);
      });

      kanjiResult = kanjiResult
          .where((element) => !kanjiExactResult.contains(element))
          .toList();

      var vocabExactResult = appData.allVocabData!.where((element) {
        return element.data?.characters == searchJP ||
            element.data?.characters?.toLowerCase() ==
                searchValue.toLowerCase() ||
            element.data!.meanings!
                .where((element) =>
                    element.meaning?.toLowerCase() == searchValue.toLowerCase())
                .isNotEmpty ||
            (element.data!.readings != null &&
                element.data!.readings!
                    .where((element) =>
                        element.reading == searchJP && element.primary == true)
                    .isNotEmpty);
      });

      var vocabResult = appData.allVocabData!.where((element) {
        return ((element.data?.characters?.startsWith(searchJP) ?? false) ||
            (element.data?.characters?.startsWith(searchValue) ?? false) ||
            element.data!.meanings!
                .where((element) =>
                    element.meaning?.startsWith(searchValue) ?? false)
                .isNotEmpty ||
            (element.data!.readings != null &&
                element.data!.readings!
                    .where((element) =>
                        element.reading?.startsWith(searchJP) ?? false)
                    .isNotEmpty));
      });

      vocabResult = vocabResult
          .where((element) => !vocabExactResult.contains(element))
          .toList();

      return Positioned(
        top: 0, // Adjust positions based on appBar and TextField heights
        left: MediaQuery.of(context).size.width * 0.25,
        right: 0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var item in kanjiExactResult) kanjiBar(item, context),
                for (var item in vocabExactResult) vocabBar(item, context),
                for (var item in kanjiResult) kanjiBar(item, context),
                for (var item in vocabResult) vocabBar(item, context),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }

  createStudySet(
      {required List<Kanji> listKanji,
      required List<Vocab> listVocab,
      required bool? kanjiOnFront}) {
    pageList = <Widget>[
      Dashboard(
        createQuiz: createStudySet,
        changePageCallback: changePage,
      ),
      Review(
          key: UniqueKey(),
          listKanji: listKanji,
          listVocab: listVocab,
          kanjiOnFront: kanjiOnFront),
      Archive(),
    ];
    print("Page removed and reinserted");

    setState(
      () {
        pageIndex = 1;
        pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      },
    );
  }

  changePage(int i) {
    if (i >= 0 && i < pageList.length) {
      setState(() {
        pageIndex = i;
        pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      });
    }
  }
}
