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
import 'package:my_kanji_app/data/vocab.dart';

class SubjectList extends StatefulWidget {
  SubjectList(
      {super.key,
      required this.data,
      required this.isToEN,
      required this.kanjiOnFront,
      required this.isAudio,
      required this.dataCheckCallback});

  List<SubjectItem>? data;
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPanel();
  }

  // widget.isKanji should be remove! Check type!
  Widget _buildPanel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.8,
        enableInfiniteScroll: false,
        viewportFraction: 0.8,
        enlargeCenterPage: true,
      ),
      items: getCards(),
    );
  }

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  List<Widget> getCards() {
    List<Widget> list = [];
    // why  isKanji: item is Kanji,  doesn't work?
    for (SubjectItem item in widget.data?.where((element) =>
            element.isCorrect == null && element.subjectItem is Kanji) ??
        []) {
      list.add(
        TwoSideCard(
          item: item,
          isKanji: true,
          isToEN: widget.isToEN,
          kanjiOnFront: widget.kanjiOnFront,
          flipItemCallback: widget.dataCheckCallback,
          isAudio: widget.isAudio,
          context: context,
        ),
      );
    }

    for (SubjectItem item in widget.data?.where((element) =>
            element.isCorrect == null && element.subjectItem is Vocab) ??
        []) {
      list.add(
        TwoSideCard(
          item: item,
          isKanji: false,
          isToEN: widget.isToEN,
          kanjiOnFront: widget.kanjiOnFront,
          flipItemCallback: widget.dataCheckCallback,
          isAudio: widget.isAudio,
          context: context,
        ),
      );
    }

    list.shuffle();

    return list;
  }
}
