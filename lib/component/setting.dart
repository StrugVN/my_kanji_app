import 'package:flutter/material.dart';
import 'package:my_kanji_app/service/api.dart';
import 'package:my_kanji_app/utility/ult_func.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late Map<String, bool> lessonSetting;
  late int lessonBatchSize;
  late Map<String, bool> reviewSetting;
  late int reviewDraftSize;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    lessonSetting = {...appData.lessonSetting};
    reviewSetting = {...appData.reviewSetting};
    lessonBatchSize = appData.lessonBatchSize;
    reviewDraftSize = appData.reviewDraftSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 15, 5),
      margin: const EdgeInsets.fromLTRB(10, 5, 15, 5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('Lesson Settings',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 8.0),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Learning filter',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Column(
                children: [
                  for (final entry in lessonSetting.entries)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(toCamelCase(entry.key),
                            style: const TextStyle(fontSize: 17)),
                        Switch(
                            value: entry.value,
                            onChanged: (value) {
                              var temp = {...lessonSetting};
                              temp.removeWhere(
                                  (key, v) => key == entry.key || v == false);
                              if (!value && temp.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "At least one type must be selected"),
                                  ),
                                );
                              } else {
                                setState(() {
                                  lessonSetting[entry.key] = value;
                                });
                              }
                            }),
                      ],
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Learning batch size',
                    style: TextStyle(fontSize: 20)),
                DropdownButton<int>(
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.3,
                  value: lessonBatchSize,
                  items: List<int>.generate(15, (index) => index + 1)
                      .map((value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => lessonBatchSize = value!),
                ),
              ],
            ),

            ///
            const Icon(Icons.menu_book),

            ///
            Text('Review Settings',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 8.0),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Review filter',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Column(
                children: [
                  for (final entry in reviewSetting.entries)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(toCamelCase(entry.key),
                            style: const TextStyle(fontSize: 17)),
                        Switch(
                            value: entry.value,
                            onChanged: (value) {
                              var temp = {...reviewSetting};
                              temp.removeWhere(
                                  (key, v) => key == entry.key || v == false);
                              if (!value && temp.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "At least one type must be selected"),
                                  ),
                                );
                              } else {
                                setState(() {
                                  reviewSetting[entry.key] = value;
                                });
                              }
                            }),
                      ],
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Review draft size', style: TextStyle(fontSize: 20)),
                DropdownButton<int>(
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.3,
                  value: reviewDraftSize,
                  items: List<int>.generate(15, (index) => index + 1)
                      .map((value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value'),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => reviewDraftSize = value!),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade100,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // padding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    appData.lessonSetting = lessonSetting;
                    appData.reviewSetting = reviewSetting;
                    appData.lessonBatchSize = lessonBatchSize;
                    appData.reviewDraftSize = reviewDraftSize;

                    appData.saveSetting();
                    
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // padding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
