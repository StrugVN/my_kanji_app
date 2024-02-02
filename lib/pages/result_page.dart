import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.listData, required this.title});

  final List<ResultData> listData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            title,
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
                    route.settings.name == 'homePage');
              },
            ),
          ],
          backgroundColor: Colors.blue,
        ),
        backgroundColor: Colors.grey.shade300,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
              ],
            )
          ),
        ));
  }
}

class ResultData {
  List<dynamic> data;
  String dataLabel;
  Color themeColor;

  ResultData(
      {required this.data, required this.dataLabel, required this.themeColor});
}
