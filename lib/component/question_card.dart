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
      required this.kanjiOnFront});

  final bool isToEN;

  final bool kanjiOnFront;

  final Subject item;

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final meaningInput = TextEditingController();

  final readingInput = TextEditingController();

  bool isMeaningCorrect = true;
  bool isReadingCorrect = true;

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
        children: [
          getFrontBaseOnTranslation(),
          getAnswerField(),
        ],
      ),
    );
  }

  getFrontBaseOnTranslation() {
    var reading = widget.item.getData().data.readings;
    String characters;

    if (widget.kanjiOnFront || reading == null) {
      characters = widget.item.getData()?.data.slug;
    } else {
      characters = reading.map((e) => e.reading).toList().join("\n");
    }

    if (widget.isToEN) {
      return FittedBox(
        child: Text(
          characters ?? "N/A",
          style: TextStyle(
            fontSize: widget.item.isKanji ? 108 : 56,
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
    return Column(
      children: [
        SizedBox(
          width: 270,
          height: 50,
          child: TextField(
            controller: meaningInput,
            onSubmitted: (String value) {
              meaningInput.text = value;

              if (meaningInput.text.trim() == "") {
                setState(() {
                  isMeaningCorrect = true;
                });

                meaningInput.text = meaningInput.text.trim();
              } else {
                var meaning = widget.item.getData().data.meanings;
                var auxMeaning = widget.item.getData().data.auxiliaryMeanings;

                if (meaning == null) {
                  return;
                }
                if (auxMeaning != null) {
                  meaning = meaning + auxMeaning;
                }

                setState(() {
                  isMeaningCorrect = meaning
                      ?.where((e) =>
                          (e.meaning.toLowerCase() as String)
                              .similarityTo(meaningInput.text.toLowerCase()) >=
                          0.75)
                      .toList()
                      .isNotEmpty as bool;
                });
                // print("${readingInput.text} - ${meaning.map((e) => e.meaning)}");
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lightbulb_outline),
              suffixIcon: meaningInput.text.trim() == ""
                  ? const SizedBox.shrink()
                  : (isMeaningCorrect
                      ? const Icon(
                          Icons.check,
                          color: Colors.green,
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
        const Gap(10),
        SizedBox(
          width: 270,
          height: 50,
          child: TextField(
            controller: readingInput,
            onChanged: (String value) {
              if (value.length > 0 && value[value.length - 1] == "n") {
                if (value.length > 1 && value[value.length - 2] == "n") {
                  readingInput.text =
                      kanaKit.toHiragana(value.substring(0, value.length - 1));
                } else {
                  readingInput.text =
                      "${kanaKit.toHiragana(value.substring(0, value.length - 1))}n";
                }
              } else {
                readingInput.text = kanaKit.toHiragana(value);
              }

            },
            onSubmitted: (value){
              if (value.length > 0 && value[value.length - 1] == "n") {
                if (value.length > 1 && value[value.length - 2] == "n") {
                  readingInput.text =
                      kanaKit.toHiragana(value.substring(0, value.length - 1));
                } else {
                  readingInput.text =
                      "${kanaKit.toHiragana(value.substring(0, value.length - 1))}n";
                }
              } else {
                readingInput.text = kanaKit.toHiragana(value);
              }
              
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
            decoration: InputDecoration(
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
        const Gap(10),
        ElevatedButton(
          onPressed: () {
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

            //
            if (meaningInput.text.trim() == "") {
              setState(() {
                isMeaningCorrect = true;
              });

              meaningInput.text = meaningInput.text.trim();
            } else {
              var meaning = widget.item.getData().data.meanings;
              var auxMeaning = widget.item.getData().data.auxiliaryMeanings;

              if (meaning == null) {
                return;
              }
              if (auxMeaning != null) {
                meaning = meaning + auxMeaning;
              }

              setState(() {
                isMeaningCorrect = meaning
                    ?.where((e) =>
                        (e.meaning.toLowerCase() as String)
                            .similarityTo(meaningInput.text.toLowerCase()) >=
                        0.75)
                    .toList()
                    .isNotEmpty as bool;
              });
              // print("${readingInput.text} - ${meaning.map((e) => e.meaning)}");
            }
          },
          child: RichText(
            text: const TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Check ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
