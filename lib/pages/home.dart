import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:my_kanji_app/component/setting.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/constant.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/radical.dart';
import 'package:my_kanji_app/data/sentence_data.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/vocab.dart';
import 'package:my_kanji_app/pages/dashboard.dart';
import 'package:my_kanji_app/pages/kanji_info_page.dart';
import 'package:my_kanji_app/pages/login.dart';
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

  static const platform = MethodChannel('app.channel.home');

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int pageIndex = 0;

  late List<Widget> pageList;

  final AppData appData = AppData();

  bool isSearchOpen = false;

  final searchFocusNode = FocusNode();

  final kanaKit = const KanaKit();

  var searchTextController = TextEditingController();

  var pageController = PreloadPageController(initialPage: 0);

  Timer? _timer;

  String toSearchString = "";

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

    // searchFocusNode.addListener(() {
    //   setState(() {
    //     isSearchOpen = searchFocusNode.hasFocus;
    //     if (!isSearchOpen) {
    //       searchTextController.text = "";
    //       toSearchString = "";
    //     }
    //   });
    // });

    WidgetsBinding.instance.addObserver(this);

    startSyncTimer();

    initHome();
  }

  void initHome() async {
    //
    await appData.loadUserData();
    var apiKey = await appData.loadApiKey();
    if (appData.userData.url != null && apiKey != null && apiKey.isNotEmpty) {
      // Load data
      appData.apiKey = "Bearer $apiKey";
      await appData.getData();
      appData.sentenceReviewFuture = appData.getSentenceReview();
    } else {
      Navigator.pop(context, true);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Login.disableAutoLogin(),
        ),
      );
    }
    //
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
          _putAppInBackground();
          // await showExitDialog(context).then((confirm) async {
          //   if (confirm != null && confirm) {
          //     SystemNavigator.pop();
          //   }
          // });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
              child: Text("頑張って",
                  style: TextStyle(
                    fontFamily: 'KyoukashoICA',
                  ))),
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
            // FocusScope.of(context).requestFocus(FocusNode());
            isSearchOpen = false;
            setState(() {
              searchTextController.text = "";
              toSearchString = "";
            });
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
              if (isSearchOpen && toSearchString.isNotEmpty)
                searchResult(toSearchString),
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
                  toSearchString = "";
                }),
                child: const Icon(Icons.close),
              )
            : const SizedBox.shrink(),
      ),
      onChanged: (value) {
        if (toSearchString != "" && value != toSearchString) {
          setState(() {
            toSearchString = "";
          });
        }
      },
      onSubmitted: (text) {
        FocusScope.of(context).requestFocus(searchFocusNode);
        setState(() {
          toSearchString = text;
        });
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

  Future<bool?> showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit'),
        content: const Text('Close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
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
          value: 2,
          child: const Text('Setting'),
          onTap: () async {
            openSettingPage();
          },
        ),
        PopupMenuItem<int>(
          value: 1,
          child: const Text('Sync data'),
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Syncing data")));
            // Load data
            appData.getData().then((value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(!appData.networkError
                      ? "Data synced"
                      : "Network error")));
              startSyncTimer();
            });
          },
        ),
        PopupMenuItem<int>(
          value: -1,
          child: const Text('Force reload all data'),
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Reloading data")));
            // Load data
            appData.getDataForce().then((value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(!appData.networkError
                      ? "Data synced"
                      : "Network error")));
              startSyncTimer();
            });
          },
        ),
        if (Platform.isWindows)
          PopupMenuItem<int>(
            value: 3,
            child: const Text('Save cache'),
            onTap: () async {
              showLoaderDialog(context, "Saving cache...");
              await appData.saveCache(null);
              Navigator.pop(context);
            },
          ),
        if (Platform.isWindows)
          PopupMenuItem<int>(
            value: 4,
            child: const Text('Dump data'),
            onTap: () async {
              showLoaderDialog(context, "Exporting...");
              await exportDataToFiles();
              Navigator.pop(context);
            },
          ),
        //   PopupMenuItem<int>(
        //   value: 6,
        //   child: const Text('Test'),
        //   onTap: () async {

        //   },
        // ),
        PopupMenuItem<int>(
          value: 0,
          child: const Text('Log out'),
          onTap: () async {
            await showLogOutDialog(context).then((value) async {
              if (value != null && value) {
                await logoutHandle(context);
              }
            });
          },
        ),
      ],
    );
  }

  Future<void> logoutHandle(BuildContext context) async {
    await appData.logout();
    bool isLastPage = ModalRoute.of(context)?.isFirst ?? false;
    Navigator.pop(context, true);
    if (isLastPage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Login.disableAutoLogin(),
        ),
      );
    }
  }

  void showAppBarSearch() {
    setState(() {
      isSearchOpen = true;
      searchFocusNode.requestFocus();
      searchTextController.text = toSearchString;
    });
  }

  void showSearchResult(String searchValue) {}

  Widget searchResult(String searchValue) {
    if (searchValue.isNotEmpty && appData.dataIsLoaded) {
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
        return ((element.data?.characters?.contains(searchJP) ?? false) ||
            (element.data?.characters?.contains(searchValue) ?? false) ||
            element.data!.meanings!
                .where((element) =>
                    element.meaning
                        ?.toLowerCase()
                        .contains(searchValue.toLowerCase()) ??
                    false)
                .isNotEmpty ||
            element.data!.auxiliaryMeanings!
                .where((element) =>
                    element.meaning
                        ?.toLowerCase()
                        .contains(searchValue.toLowerCase()) ??
                    false)
                .isNotEmpty ||
            element.data!.readings!
                .where(
                    (element) => element.reading?.contains(searchJP) ?? false)
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
                .where((element) => (" ${element.meaning}".toLowerCase())
                    .contains(" $searchValue".toLowerCase()))
                .isNotEmpty ||
            (element.data!.readings != null &&
                element.data!.readings!
                    .where((element) =>
                        element.reading == searchJP && element.primary == true)
                    .isNotEmpty);
      });

      var vocabResult = appData.allVocabData!.where((element) {
        return ((element.data?.characters?.contains(searchJP) ?? false) ||
            (element.data?.characters?.contains(searchValue) ?? false) ||
            element.data!.meanings!
                .where((element) =>
                    (" ${element.meaning}").contains(" $searchValue"))
                .isNotEmpty ||
            (element.data!.readings != null &&
                element.data!.readings!
                    .where((element) =>
                        element.reading?.contains(searchJP) ?? false)
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
                if (kanjiExactResult.isEmpty &&
                    vocabExactResult.isEmpty &&
                    kanjiResult.isEmpty &&
                    vocabResult.isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Center(
                            child: Text(
                          "No result",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        )),
                      ],
                    ),
                  ),
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

  void openSettingPage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.70,
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.95, // Adjust width as needed
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const SettingPage(),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void startSyncTimer() {
    const Duration syncInterval = Duration(minutes: 10);
    _timer?.cancel();
    _timer = Timer.periodic(syncInterval, (timer) {
      syncData();
    });
  }

  void syncData() {
    appData.autoDataSync();
  }

  void _putAppInBackground() {
    try {
      Home.platform.invokeMethod('putAppInBackground');
    } catch (e) {
      print("Failed to put app in background: '$e'.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      appData.autoDataSync();
      startSyncTimer();
    } else if (state == AppLifecycleState.paused) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

// Function to generate heatmap data
  Map<String, int> generateHeatMapData(
      List<Map<String, String?>> dataList, String key) {
    Map<String, int> heatMapData = {};

    // Date format to be used (YYYY-MM-DD)
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    // Loop through each item and extract the date
    for (var data in dataList) {
      String? dateString = data[key];
      if (dateString == null) continue; // Skip if the date is null

      DateTime dateTime = DateTime.parse(dateString);
      String formattedDate = dateFormat.format(dateTime);

      // Count occurrences of each date
      if (heatMapData.containsKey(formattedDate)) {
        heatMapData[formattedDate] = heatMapData[formattedDate]! + 1;
      } else {
        heatMapData[formattedDate] = 1;
      }
    }

    // Sort the heatmap data by date (keys) in increasing order
    var sortedKeys = heatMapData.keys.toList()..sort((a, b) => a.compareTo(b));
    Map<String, int> sortedHeatMapData = {
      for (var key in sortedKeys) key: heatMapData[key]!
    };

    return sortedHeatMapData;
  }

  Future<void> writeToFile(
      String directory, String fileName, String jsonData) async {
    final file = File('$directory/$fileName');
    await file.writeAsString(jsonData);
  }

  Future<void> exportDataToFiles() async {
    // Let the user select a directory to export the files
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // User canceled the picker
      print("No folder selected.");
      return;
    }

    // Collect all items into a common structure
    List<Map<String, String?>> combinedDataList = [];

    // Combine Kanji, Vocab, and Radical into one list with both created_at and data_updated_at
    appData.allSrsData?.forEach((srs) {
      combinedDataList.add({
        'started_at': srs.data?.startedAt,
        'data_updated_at': srs.dataUpdatedAt,
      });
    });

    // Generate heatmap data for created_at and data_updated_at
    Map<String, int> createdAtHeatMap =
        generateHeatMapData(combinedDataList, 'started_at');
    Map<String, int> updatedAtHeatMap =
        generateHeatMapData(combinedDataList, 'data_updated_at');

    // Convert each list to JSON
    String kanjiJson = jsonEncode(
        appData.allKanjiData?.map((kanji) => kanji.toJson()).toList());
    String vocabJson = jsonEncode(
        appData.allVocabData?.map((vocab) => vocab.toJson()).toList());
    String radicalJson = jsonEncode(
        appData.allRadicalData?.map((radical) => radical.toJson()).toList());

    // Write the data to separate files
    await writeToFile(selectedDirectory, 'kanji_data.json', kanjiJson);
    await writeToFile(selectedDirectory, 'vocab_data.json', vocabJson);
    await writeToFile(selectedDirectory, 'radical_data.json', radicalJson);

    await writeToFile(selectedDirectory, 'created_at_heatmap.json',
        jsonEncode(createdAtHeatMap));
    await writeToFile(selectedDirectory, 'data_updated_at_heatmap.json',
        jsonEncode(updatedAtHeatMap));

    print("Data exported successfully.");
  }
}
