import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/shared.dart';
import 'package:my_kanji_app/data/vocab.dart';

class VocabInfoCard extends StatelessWidget {
  const VocabInfoCard({super.key, required this.item});

  final Vocab item;

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
          color: const Color.fromARGB(255, 197, 217, 255),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(255, 181, 181, 181),
                blurRadius: 20,
                spreadRadius: 5)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: getTextOfVocab(),
            ),

            const Divider(color: Colors.black),

            const Text(
              "Meaning:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                item.data?.meanings!.map((e) => e.meaning).join(", ") ?? "",
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            const Divider(color: Colors.black),
          ],
        ));
  }

  getTextOfVocab() {
    String slug = item.data!.slug ?? "N/A";
    var readings = item.data!.readings;

    if (readings != null) {
      return Center(
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: slug,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
                style: const TextStyle(
                  fontSize: 48,
                ),
              ),
            ),
            Column(
              children: readings.map<RichText>((reading) {
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: reading.reading,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      )
                    ],
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: slug,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
          style: const TextStyle(
            fontSize: 48,
          ),
        ),
      );
    }
  }

  // Map<String, List<Map<String, String>>> splitCharacters(
  //     String slugs, String reading) {
  //   List<Map<String, String>> separatedSlugs = [];
  //   List<Map<String, String>> separatedReading = [];

  //   List<String?> kanaPart =
  //       kanaRegEx.allMatches(slugs).map((z) => z.group(0)).toList();

  //   if (kanaPart.isEmpty) {
  //     return {
  //       slugs: [
  //         {
  //           "str": slugs,
  //           "part": "kanji",
  //         }
  //       ],
  //       reading: [
  //         {
  //           "str": reading,
  //           "part": "kanji",
  //         }
  //       ],
  //     };
  //   }

  //   String slugsCopy = slugs;
  //   String readingCopy = reading;
  //   for (String? s in kanaPart) {
  //     if (s == null) continue;

  //     String substr = slugsCopy.substring(0, slugsCopy.indexOf(s));

  //     separatedSlugs.add({
  //       "str": substr,
  //       "part": "kanji",
  //     });
  //     separatedSlugs.add({
  //       "str": s,
  //       "part": "kana",
  //     });

  //     slugsCopy =
  //         slugsCopy.replaceRange(0, slugsCopy.indexOf(s) + s.length, "");

  //     String substrReading = readingCopy.substring(0, readingCopy.indexOf(s));

  //     separatedReading.add({
  //       "str": substrReading,
  //       "part": "kanji",
  //     });
  //     separatedReading.add({
  //       "str": s,
  //       "part": "kana",
  //     });

  //     readingCopy =
  //         readingCopy.replaceRange(0, readingCopy.indexOf(s) + s.length, "");
  //   }

  //   return {
  //     slugs: separatedSlugs,
  //     reading: separatedReading,
  //   };
  // }
}
