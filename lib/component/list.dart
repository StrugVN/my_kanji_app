import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_kanji_app/component/kanji_info_card.dart';
import 'package:my_kanji_app/component/question_card.dart';
import 'package:my_kanji_app/component/vocab_info_card.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:gap/gap.dart';
import 'package:my_kanji_app/data/shared.dart';

class SubjectList extends StatefulWidget {
  SubjectList(
      {super.key,
      this.data,
      this.isToEN,
      this.isKanji,
      this.kanjiOnFront,
      required this.dataCheckCallback});

  List<SubjectItem>? data;
  bool? isKanji;
  bool? isToEN;
  bool? kanjiOnFront;
  final void Function() dataCheckCallback;

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
        height: 600,
        enableInfiniteScroll: false,
      ),
      items: [
        for (SubjectItem item
            in widget.data?.where((element) => element.isCorrect == null) ?? [])
          Column(
            children: [
              const Gap(10),
              buttonControl(item),
              const Gap(10),
              getCard(item),
            ],
          )
      ],
    );
  }

  getCard(SubjectItem item) {
    if (item.isRevealed!) {
      if (widget.isKanji!) {
        return KanjiInfoCard(
          item: item.subjectItem!,
        );
      } else {
        return VocabInfoCard(
          item: item.subjectItem!,
        );
      }
    } else {
      return QuestionCard(
        item: Subject(
            kanji: widget.isKanji! ? item.subjectItem! : null,
            vocab: !widget.isKanji! ? item.subjectItem! : null,
            isKanji: widget.isKanji!),
        isToEN: widget.isToEN!, kanjiOnFront: widget.kanjiOnFront!,
      );
    }
  }

  buttonControl(SubjectItem item) {
    if (item.isRevealed!) {
      // ------ Item is revealed
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  item.isCorrect = false;
                  widget.dataCheckCallback();
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
                      text: 'fogotten',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  item.isCorrect = true;
                  widget.dataCheckCallback();
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
    } else {
      // ------ Item is NOT revealed
      return ElevatedButton(
        onPressed: () {
          setState(() {
            item.isRevealed = true;
          });
        },
        child: RichText(
          text: const TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Reveal ',
                style: TextStyle(color: Colors.blue),
              ),
              TextSpan(
                text: 'item',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      );
    }
  }
}
