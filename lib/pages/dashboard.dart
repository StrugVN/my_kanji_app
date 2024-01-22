import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
