import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_kanji_app/component/kanji_info_card.dart';
import 'package:my_kanji_app/component/question_card.dart';
import 'package:my_kanji_app/component/vocab_info_card.dart';
import 'package:my_kanji_app/data/shared.dart';

class TwoSideCard extends StatelessWidget {
  TwoSideCard(
      {super.key,
      required this.item,
      required this.isKanji,
      required this.isToEN,
      required this.kanjiOnFront,
      required this.flipItemCallback, required this.isAudio,
      });

  final SubjectItem item;
  final bool? isKanji;
  final bool? isToEN;
  final bool? kanjiOnFront;
  final bool? isAudio;
  void Function(bool) flipItemCallback;

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      key: cardKey,
      flipOnTouch: false,
      side: !item.isRevealed! ? CardSide.FRONT : CardSide.BACK,
      front: Column(
        children: [
          const Gap(10),
          buttonControl(item, false),
          const Gap(10),
          QuestionCard(
            item: Subject(
                kanji: isKanji! ? item.subjectItem! : null,
                vocab: !isKanji! ? item.subjectItem! : null,
                isKanji: isKanji!),
            isToEN: isToEN!,
            kanjiOnFront: kanjiOnFront!, flipCallback: flip, isAudio: isAudio ?? false,
          ),
        ],
      ),
      back: Column(
        children: [
          const Gap(10),
          buttonControl(item, true),
          const Gap(10),
          isKanji!
              ? KanjiInfoCard(
                  item: item.subjectItem!,
                  
                )
              : VocabInfoCard(
                  item: item.subjectItem!,
                ),
        ],
      ),
    );
  }

  flip() async {
    cardKey.currentState?.toggleCard();
    item.isRevealed = true;
    flipItemCallback(false);
  }

  buttonControl(SubjectItem item, bool reveal) {
    if (reveal) {
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
                item.isCorrect = false;
                flipItemCallback(true);
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
                item.isCorrect = true;
                flipItemCallback(true);
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
    } else {
      return const SizedBox(width: 130, height: 48,);
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
    }
  }
}
