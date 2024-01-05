import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:my_kanji_app/component/list.dart';
import 'package:my_kanji_app/component/selector.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/kanji_set.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/user.dart';
import 'package:my_kanji_app/service/api.dart';
import 'dart:convert';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List<SubjectItem<Kanji>>? kanjiList;
  List<SubjectItem<Kanji>>? kanjiListResult;
  bool? isToEN;

  final User user = User();

  late bool reviewInProgress;

  @override
  void initState() {
    super.initState();

    reviewInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            getSelector(),
            SubjectList(data: kanjiList, isToEN: isToEN,),
          ],
        ),
      ),
    );
  }

  getReview(String types, int levels, bool toEn, String? nonWani) async {
    late Response response;

    print("Non arg: $nonWani");

    if (nonWani == null){
      response = await getSubject(
          SubjectQueryParam(types: [types], levels: [levels.toString()]));
    }
    else {
      String? set = kanjiSet[nonWani];
      if (set != null) {
        response = await getSubject(
            SubjectQueryParam(types: ['kanji'], slugs: []));
      }
      else{
        return;
      }
    }

    if (response.statusCode == 200) {
      var body = KanjiResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);

      setState(() {
        kanjiList = body.data
            ?.map((e) => SubjectItem<Kanji>(subjectItem: e, isRevealed: false))
            .toList();
        
        isToEN = toEn;

        kanjiList?.shuffle();

        reviewInProgress = true;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.body)));
      print(response.body);
    }
  }

  getSelector() {
    if (reviewInProgress) {
      return ExpansionTile(
        title: const Center(
          child: Text("Review in progress"),
        ),
        leading: const Icon(Icons.book),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  setState(() {
                    closeSection();
                  });
                },
                child: const Text(
                  "Close review section",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return ExpansionTile(
        title: const Center(
          child: Text("Create review"),
        ),
        leading: const Icon(Icons.book),
        initiallyExpanded: true,
        children: [
          ReviewCreator(
            maxLevel: user.userData.data?.level ?? 60,
            onPressedCallback: getReview,
          ),
        ],
      );
    }
  }

  closeSection(){
    kanjiListResult = kanjiList;
    kanjiList = [];
    reviewInProgress = false;
  }
}
