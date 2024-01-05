import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/kanji.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.item, required this.isToEN});

  final bool isToEN;

  final Kanji item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
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
        ],
      ),
    );
  }

  getFrontBaseOnTranslation() {
    if (isToEN) {
      return Text(
        item.data?.slug ?? "N/A",
        style: const TextStyle(
          fontSize: 108,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        item.data?.meanings!.map((e) => e.meaning).join(", ") ?? "",
        style: const TextStyle(
          fontSize: 21,
        ),
        textAlign: TextAlign.center,
      );
    }
  }
}
