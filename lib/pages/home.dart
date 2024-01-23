import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/app_data.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/pages/dashboard.dart';
import 'package:my_kanji_app/pages/review.dart';
import 'package:my_kanji_app/pages/stuff.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int pageIndex;

  List<Widget> pageList = <Widget>[
    const Dashboard(),
    const Review(),
    const Stuff(),
  ];

  final AppData appData = AppData();

  @override
  void initState() {
    super.initState();

    pageIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("📚上手に出来る様になる📖")),
            backgroundColor: Colors.blue,
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: IndexedStack(
              index: pageIndex,
              children: pageList,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: pageIndex,
            onTap: (value) {
              setState(() {
                pageIndex = value;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: "Dashboard"),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: "Review"),
              BottomNavigationBarItem(icon: Icon(Icons.info), label: "Stuff"),
            ],
          ),
        ),
      ),
    );
  }

  void initData() async {
    showLoaderDialog(context, "Loading data");

    try {
      await appData.loadDataFromAsset();

      // TEST
      
    } on Exception catch (e) {
      print(e);
    }

    Navigator.of(context, rootNavigator: true).pop(true);
  }
}
