import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:my_kanji_app/service/api.dart';

enum ModeLabel {
  kanji('Kanji', Colors.pink),
  vocab('Vocab', Colors.blue);

  const ModeLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum SourceTypeLabel {
  Wanikani("Wanikani", Colors.blue),
  JLPT("JLPT", Colors.red),
  Joyo("Joyo", Colors.yellow),
  Frequency("Frequency", Colors.pink);

  const SourceTypeLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum TranslationTypeLabel {
  toJp("Translate to JP", Colors.pink),
  toEn("Translate to EN", Colors.blue);

  const TranslationTypeLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum QuestionTypeLabel {
  kanJi("Show Kanji", Colors.pink),
  kana("Show Kana", Colors.blue);

  const QuestionTypeLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum JlptLevelLabel {
  n5("JLPT N5", Colors.blue),
  n4("JLPT N4", Colors.green),
  n3("JLPT N3", Colors.yellow),
  n2("JLPT N2", Colors.red),
  n1("JLPT N1", Colors.black),
  ;

  const JlptLevelLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum JoyoLevelLabel {
  joyo1("Joyo Grade 1", Colors.blue),
  joyo2("Joyo Grade 2", Color.fromARGB(255, 33, 236, 243)),
  joyo3("Joyo Grade 3", Color.fromARGB(255, 33, 243, 156)),
  joyo4("Joyo Grade 4", Color.fromARGB(255, 89, 243, 33)),
  joyo5("Joyo Grade 5", Color.fromARGB(255, 177, 243, 33)),
  joyo6("Joyo Grade 6", Color.fromARGB(255, 243, 215, 33)),
  joyo9("Joyo Grade 9", Colors.red),
  ;

  const JoyoLevelLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum FrequencyLevelLabel {
  m500("Most used 500", Colors.blue),
  m1000("500 - 1000", Colors.green),
  m1500("1000 - 1500", Colors.yellow),
  m2000("1500 - 2000", Colors.red),
  ;

  const FrequencyLevelLabel(this.label, this.color);
  final String label;
  final Color color;
}

class ReviewCreator extends StatefulWidget {
  final int maxLevel;

  const ReviewCreator(
      {super.key, required this.maxLevel, required this.onPressedCallback});

  final void Function(String, int, bool, String?, String?) onPressedCallback;

  @override
  State<ReviewCreator> createState() => _ReviewCreatorState(
        maxLevel: maxLevel,
        onPressedCallback: onPressedCallback,
      );
}

class _ReviewCreatorState extends State<ReviewCreator> {
  final int maxLevel;
  final TextEditingController modeController = TextEditingController();
  final TextEditingController translationController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController nonWaniController = TextEditingController();
  final TextEditingController sourceTypeController = TextEditingController();
  ModeLabel? selectedMode;
  TranslationTypeLabel? selectedType;
  QuestionTypeLabel? questionTypeLabel = QuestionTypeLabel.kanJi;
  SourceTypeLabel? sourceTypeLabel;
  int? selectedLevel;
  String? nonWaniLevel;

  late List<DropdownMenuEntry<int>> levelList;

  final void Function(String, int, bool, String?, String?) onPressedCallback;

  _ReviewCreatorState(
      {required this.maxLevel, required this.onPressedCallback});

  @override
  void initState() {
    super.initState();
    levelList = positiveIntegers
        .skip(1)
        .take(maxLevel)
        .toList()
        .map<DropdownMenuEntry<int>>(
          (int level) {
            return DropdownMenuEntry<int>(
              value: level,
              label: level.toString(),
            );
          },
        )
        .toList()
        .reversed
        .toList();

    selectedMode = ModeLabel.kanji;
    selectedType = TranslationTypeLabel.toEn;
    selectedLevel = maxLevel;
    sourceTypeLabel = SourceTypeLabel.Wanikani;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DropdownMenu<SourceTypeLabel>(
                      width: 150,
                      initialSelection: SourceTypeLabel.Wanikani,
                      controller: sourceTypeController,
                      onSelected: (SourceTypeLabel? type) {
                        setState(() {
                          sourceTypeLabel = type;
                          // if (sourceTypeLabel != SourceTypeLabel.Wanikani) {
                          //   modeController.text = ModeLabel.kanji.label;
                          //   selectedMode = ModeLabel.kanji;
                          // }
                          switch (sourceTypeLabel) {
                            case SourceTypeLabel.JLPT:
                              nonWaniLevel = JlptLevelLabel.n5.label;
                              break;
                            case SourceTypeLabel.Joyo:
                              nonWaniLevel = JoyoLevelLabel.joyo1.label;
                              break;
                            case SourceTypeLabel.Frequency:
                              nonWaniLevel = FrequencyLevelLabel.m500.label;
                              break;
                            default:
                          }
                        });
                      },
                      requestFocusOnTap: true,
                      label: const Text('Source'),
                      dropdownMenuEntries: SourceTypeLabel.values
                          .map<DropdownMenuEntry<SourceTypeLabel>>(
                              (SourceTypeLabel color) {
                        return DropdownMenuEntry<SourceTypeLabel>(
                          value: color,
                          label: color.label,
                          enabled: color.label != 'Grey',
                          style: MenuItemButton.styleFrom(
                            foregroundColor: color.color,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    DropdownMenu<TranslationTypeLabel>(
                      width: 220,
                      initialSelection: TranslationTypeLabel.toEn,
                      controller: translationController,
                      requestFocusOnTap: true,
                      label: const Text('Type'),
                      onSelected: (TranslationTypeLabel? type) {
                        setState(() {
                          selectedType = type;
                        });
                      },
                      dropdownMenuEntries: TranslationTypeLabel.values
                          .map<DropdownMenuEntry<TranslationTypeLabel>>(
                              (TranslationTypeLabel color) {
                        return DropdownMenuEntry<TranslationTypeLabel>(
                          value: color,
                          label: color.label,
                          enabled: color.label != 'Grey',
                          style: MenuItemButton.styleFrom(
                            foregroundColor: color.color,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const Gap(10),
                Row(
                  children: <Widget>[
                    DropdownMenu<ModeLabel>(
                      width: 150,
                      initialSelection: ModeLabel.kanji,
                      controller: modeController,
                      requestFocusOnTap: true,
                      label: const Text('Mode'),
                      onSelected: (ModeLabel? mode) {
                        setState(() {
                          selectedMode = mode;
                        });
                      },
                      dropdownMenuEntries: ModeLabel.values
                          .map<DropdownMenuEntry<ModeLabel>>((ModeLabel item) {
                        return DropdownMenuEntry<ModeLabel>(
                          value: item,
                          label: item.label,
                          style: MenuItemButton.styleFrom(
                            foregroundColor: item.color,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    getLevelSelector(),
                  ],
                ),
                const Gap(10),
                getVocabSetting(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.create),
                        style: ElevatedButton.styleFrom(
                          //backgroundColor: const Color.fromARGB(255, 133, 255, 103),
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => onPressedCallback(
                            selectedMode!.label.toLowerCase(),
                            selectedLevel!,
                            selectedType == TranslationTypeLabel.toEn,
                            nonWaniLevel,
                            questionTypeLabel?.label ?? "Show Kanji"),
                        label: const Text(
                          "Create",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getVocabSetting() {
    if (selectedMode == ModeLabel.vocab) {
      return Column(
        children: [
          const Row(children: <Widget>[
            Text(
              "Vocab card front setting",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            Expanded(child: Divider()),
          ]),
          Row(
            children: [
              Flexible(
                child: RadioListTile(
                  title: Text(
                    QuestionTypeLabel.kanJi.label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  value: QuestionTypeLabel.kanJi,
                  groupValue: questionTypeLabel,
                  onChanged: (QuestionTypeLabel? value) {
                    setState(() {
                      questionTypeLabel = value;
                    });
                  },
                ),
              ),
              Flexible(
                child: RadioListTile(
                  title: Text(
                    QuestionTypeLabel.kana.label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  value: QuestionTypeLabel.kana,
                  groupValue: questionTypeLabel,
                  onChanged: (QuestionTypeLabel? value) {
                    setState(() {
                      questionTypeLabel = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }
    return const Gap(0);
  }

  getLevelSelector() {
    switch (sourceTypeLabel) {
      case SourceTypeLabel.Wanikani:
        return DropdownMenu<int>(
          width: 220,
          initialSelection: selectedLevel,
          controller: levelController,
          requestFocusOnTap: true,
          leadingIcon: const Icon(Icons.school),
          label: const Text('Level'),
          menuHeight: 300,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 2.0),
          ),
          onSelected: (int? level) {
            setState(() {
              selectedLevel = level;
            });
          },
          dropdownMenuEntries: levelList,
        );

      case SourceTypeLabel.JLPT:
        return DropdownMenu<JlptLevelLabel>(
          width: 220,
          initialSelection: JlptLevelLabel.n5,
          controller: nonWaniController,
          requestFocusOnTap: true,
          leadingIcon: const Icon(Icons.school),
          label: const Text('Level'),
          menuHeight: 300,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 2.0),
          ),
          onSelected: (JlptLevelLabel? level) {
            setState(() {
              nonWaniLevel = level?.label;
            });
          },
          dropdownMenuEntries: JlptLevelLabel.values
              .map<DropdownMenuEntry<JlptLevelLabel>>((JlptLevelLabel color) {
            return DropdownMenuEntry<JlptLevelLabel>(
              value: color,
              label: color.label,
              enabled: color.label != 'Grey',
              style: MenuItemButton.styleFrom(
                foregroundColor: color.color,
              ),
            );
          }).toList(),
        );

      case SourceTypeLabel.Joyo:
        return DropdownMenu<JoyoLevelLabel>(
          width: 220,
          initialSelection: JoyoLevelLabel.joyo1,
          controller: nonWaniController,
          requestFocusOnTap: true,
          leadingIcon: const Icon(Icons.school),
          label: const Text('Level'),
          menuHeight: 300,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 2.0),
          ),
          onSelected: (JoyoLevelLabel? level) {
            setState(() {
              nonWaniLevel = level?.label;
            });
          },
          dropdownMenuEntries: JoyoLevelLabel.values
              .map<DropdownMenuEntry<JoyoLevelLabel>>((JoyoLevelLabel color) {
            return DropdownMenuEntry<JoyoLevelLabel>(
              value: color,
              label: color.label,
              enabled: color.label != 'Grey',
              style: MenuItemButton.styleFrom(
                foregroundColor: color.color,
              ),
            );
          }).toList(),
        );

      case SourceTypeLabel.Frequency:
        return DropdownMenu<FrequencyLevelLabel>(
          width: 220,
          initialSelection: FrequencyLevelLabel.m500,
          controller: nonWaniController,
          requestFocusOnTap: true,
          leadingIcon: const Icon(Icons.school),
          label: const Text('Level'),
          menuHeight: 300,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            contentPadding: EdgeInsets.symmetric(vertical: 2.0),
          ),
          onSelected: (FrequencyLevelLabel? level) {
            setState(() {
              nonWaniLevel = level?.label;
            });
          },
          dropdownMenuEntries: FrequencyLevelLabel.values
              .map<DropdownMenuEntry<FrequencyLevelLabel>>(
                  (FrequencyLevelLabel color) {
            return DropdownMenuEntry<FrequencyLevelLabel>(
              value: color,
              label: color.label,
              enabled: color.label != 'Grey',
              style: MenuItemButton.styleFrom(
                foregroundColor: color.color,
              ),
            );
          }).toList(),
        );

      default:
        return const Text("Whooopsie");
    }
  }
}

Iterable<int> get positiveIntegers sync* {
  int i = 0;
  while (true) {
    yield i++;
  }
}
