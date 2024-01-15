import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
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
      front: QuestionCard(
        item: Subject(
            kanji: isKanji! ? item.subjectItem! : null,
            vocab: !isKanji! ? item.subjectItem! : null,
            isKanji: isKanji!),
        isToEN: isToEN!,
        kanjiOnFront: kanjiOnFront!, flipCallback: flip, isAudio: isAudio ?? false,
      ),
      back: isKanji!
          ? KanjiInfoCard(
              item: item.subjectItem!,
              
            )
          : VocabInfoCard(
              item: item.subjectItem!,
            ),
    );
  }

  flip() async {
    cardKey.currentState?.toggleCard();
    item.isRevealed = true;
    flipItemCallback(false);
  }
}
