import 'package:flutter/material.dart';
import 'package:my_kanji_app/data/kanji.dart';

class KanjiPage extends StatefulWidget {
  const KanjiPage({super.key, required this.kanji, this.navigationList});

  final Kanji kanji;

  final List<Kanji>? navigationList;

  @override
  State<KanjiPage> createState() => _KanjiPageState();
}

class _KanjiPageState extends State<KanjiPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // ...
      ),
      body: Container(),
    );
  }
}
