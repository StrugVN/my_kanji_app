import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_kanji_app/component/kanji_info_card.dart';
import 'package:my_kanji_app/component/question_card.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:gap/gap.dart';
import 'package:my_kanji_app/data/shared.dart';

class SubjectList extends StatefulWidget {
  SubjectList({super.key, this.data, this.isToEN});

  List<SubjectItem<Kanji>>? data;
  bool? isToEN;

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
        height: 500,
        enableInfiniteScroll: false,
      ),
      items: [
        for (SubjectItem<Kanji> item
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
      return KanjiInfoCard(
        item: item.subjectItem!,
      );
    } else {
      return QuestionCard(item: item.subjectItem!, isToEN: widget.isToEN!,);
    }
  }

  buttonControl(SubjectItem item) {
    if (item.isRevealed!) {
      // ------ Item is revealed
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.isCorrect = false;
              });
            },
            child: RichText(
              text: const TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Mark as ',
                  ),
                  TextSpan(
                    text: 'fogotten',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.isCorrect = true;
              });
            },
            child: RichText(
              text: const TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Mark as ',
                  ),
                  TextSpan(
                    text: 'remembered',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
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
              ),
            ],
          ),
        ),
      );
    }
  }
}
