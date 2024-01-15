import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_kanji_app/component/kanji_info_card.dart';
import 'package:my_kanji_app/component/question_card.dart';
import 'package:my_kanji_app/component/two_side_card.dart';
import 'package:my_kanji_app/component/vocab_info_card.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:gap/gap.dart';
import 'package:my_kanji_app/data/shared.dart';

class SubjectList extends StatefulWidget {
  SubjectList(
      {super.key,
      required this.data,
      required this.isToEN,
      required this.isKanji,
      required this.kanjiOnFront,
      required this.isAudio,
      required this.dataCheckCallback});

  List<SubjectItem>? data;
  bool? isKanji;
  bool? isToEN;
  bool? kanjiOnFront;
  bool? isAudio;
  final void Function(bool) dataCheckCallback;

  @override
  State<SubjectList> createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  _SubjectListState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: widget.data == null || widget.data!.isEmpty ? 0 : 570,
        enableInfiniteScroll: false,
      ),
      items: [
        for (SubjectItem item
            in widget.data?.where((element) => element.isCorrect == null) ?? [])
          Column(
            children: [
              const Gap(5),
              buttonControl(item),
              const Gap(5),
              TwoSideCard(
                item: item,
                isKanji: widget.isKanji,
                isToEN: widget.isToEN,
                kanjiOnFront: widget.kanjiOnFront,
                flipItemCallback: widget.dataCheckCallback, isAudio: widget.isAudio,
              )
            ],
          )
      ],
    );
  }

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  buttonControl(SubjectItem item) {
    // if (item.isRevealed!) {
      // ------ Item is revealed
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  item.isCorrect = false;
                  widget.dataCheckCallback(true);
                });
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Mark as ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: 'forgot',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          SizedBox(
            width: 130,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  item.isCorrect = true;
                  widget.dataCheckCallback(true);
                });
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Mark as ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: 'remembered',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    // } else {
    //   return const SizedBox(width: 130, height: 48,);
      // ------ Item is NOT revealed
      // return ElevatedButton(
      //   onPressed: () {
      //     setState(() {
      //       item.isRevealed = true;
      //     });
      //   },
      //   child: RichText(
      //     text: const TextSpan(
      //       children: <TextSpan>[
      //         TextSpan(
      //           text: 'Reveal ',
      //           style: TextStyle(color: Colors.blue),
      //         ),
      //         TextSpan(
      //           text: 'item',
      //           style: TextStyle(color: Colors.black),
      //         ),
      //       ],
      //     ),
      //   ),
      // );
    // }
  }
}
