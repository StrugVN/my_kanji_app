import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:my_kanji_app/data/kanji.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:string_similarity/string_similarity.dart';

class QuestionCard extends StatefulWidget {
  QuestionCard(
      {super.key,
      required this.item,
      required this.isToEN,
      required this.kanjiOnFront,
      required this.flipCallback});

  final bool isToEN;

  final bool kanjiOnFront;

  final Subject item;

  final void Function() flipCallback;

  @override
  State<QuestionCard> createState() =>
      _QuestionCardState(flipCallback: flipCallback);
}

class _QuestionCardState extends State<QuestionCard> {
  _QuestionCardState({required this.flipCallback});

  final meaningInput = TextEditingController();

  final readingInput = TextEditingController();

  bool isMeaningCorrect = true;
  bool isMeaningSlightlyWrong = false;
  bool isReadingCorrect = true;

  final void Function() flipCallback;

  final kanaKit = const KanaKit();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),
      margin: const EdgeInsets.only(
        right: 12,
        top: 5,
      ),
      decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/card.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(255, 181, 181, 181),
                blurRadius: 20,
                spreadRadius: 5)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          getFrontBaseOnTranslation(),
          getAnswerField(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () {
              setState(() {
                flipCallback();
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: RichText(
                text: const TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Reveal ',
                      style: TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                    TextSpan(
                      text: 'item',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  getFrontBaseOnTranslation() {
    var reading = widget.item.getData().data.readings;
    String characters;

    if (widget.kanjiOnFront || reading == null) {
      characters = widget.item.getData()?.data.characters;
    } else {
      characters = reading.map((e) => e.reading).toList().join("\n");
    }

    if (widget.isToEN) {
      return FittedBox(
        child: Text(
          characters,
          style: const TextStyle(
            fontSize: 108,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Text(
        widget.item
                .getData()
                ?.data
                .meanings!
                .map((e) => e.meaning)
                .join(", ") ??
            "N/A",
        style: const TextStyle(
          fontSize: 21,
        ),
        textAlign: TextAlign.center,
      );
    }
  }

  getAnswerField() {
    List<Widget> widgets = [];
    if (widget.isToEN) {
      widgets = widgets +
          [
            SizedBox(
              width: 270,
              height: 50,
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (meaningInput.text.trim() == "") {
                    setState(() {
                      isMeaningCorrect = true;
                    });

                    meaningInput.text = meaningInput.text.trim();
                  } else {
                    var meaning = widget.item.getData().data.meanings;
                    var auxMeaning =
                        widget.item.getData().data.auxiliaryMeanings;

                    if (meaning == null) {
                      return;
                    }
                    if (auxMeaning != null) {
                      meaning = meaning + auxMeaning;
                    }

                    setState(() {
                      isMeaningCorrect = meaning
                          ?.where((e) =>
                              (e.meaning.toLowerCase() as String).similarityTo(
                                  meaningInput.text.toLowerCase()) >=
                              0.75)
                          .toList()
                          .isNotEmpty as bool;

                      isMeaningSlightlyWrong = isMeaningCorrect &&
                          meaning
                              ?.where((e) =>
                                  e.meaning.toLowerCase() ==
                                  meaningInput.text.toLowerCase())
                              .toList()
                              .isEmpty as bool;
                    });
                    // print("${readingInput.text} - ${meaning.map((e) => e.meaning)}");
                  }
                },
                child: TextField(
                  controller: meaningInput,
                  onSubmitted: (String value) {
                    meaningInput.text = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue[300]!),
                    ),
                    prefixIcon: const Icon(Icons.lightbulb_outline),
                    suffixIcon: meaningInput.text.trim() == ""
                        ? const SizedBox.shrink()
                        : (isMeaningCorrect
                            ? Icon(
                                Icons.check,
                                color: isMeaningSlightlyWrong
                                    ? Colors.yellow
                                    : Colors.green,
                              )
                            : const Icon(
                                Icons.close,
                                color: Colors.red,
                              )),
                    hintText: "Meaning",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            isMeaningSlightlyWrong
                ? const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "Typo detected",
                      style:
                          TextStyle(color: Color.fromARGB(255, 199, 184, 46)),
                      textAlign: TextAlign.left,
                    ),
                  )
                : const SizedBox.shrink(),
            const Gap(10),
          ];
    }

    if (widget.kanjiOnFront && widget.item.getData().data.readings != null) {
      widgets = widgets +
          [
            SizedBox(
              width: 270,
              height: 50,
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (readingInput.text.trim() == "") {
                    setState(() {
                      isReadingCorrect = true;
                    });

                    readingInput.text = readingInput.text.trim();
                  } else {
                    var reading = widget.item.getData().data.readings;

                    if (reading == null) {
                      return;
                    }

                    setState(() {
                      isReadingCorrect = reading
                          ?.where((e) =>
                              e.reading.toLowerCase() ==
                              readingInput.text.toLowerCase())
                          .toList()
                          .isNotEmpty as bool;
                    });
                    // print("${readingInput.text} - ${reading.map((e) => e.reading)}");
                  }
                },
                child: TextField(
                  controller: readingInput,
                  onChanged: (String value) {
                    if (value.length > 0 && value[value.length - 1] == "n") {
                      if (value.length > 1 && value[value.length - 2] == "n") {
                        readingInput.text = kanaKit
                            .toHiragana(value.substring(0, value.length - 1));
                      } else {
                        readingInput.text =
                            "${kanaKit.toHiragana(value.substring(0, value.length - 1))}n";
                      }
                    } else {
                      readingInput.text = kanaKit.toHiragana(value);
                    }
                  },
                  onSubmitted: (value) {},
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue[300]!),
                    ),
                    prefixIcon: const Icon(Icons.volume_up),
                    suffixIcon: readingInput.text.trim() == ""
                        ? const SizedBox.shrink()
                        : (isReadingCorrect
                            ? const Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.close,
                                color: Colors.red,
                              )),
                    hintText: "Reading",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(10),
          ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
