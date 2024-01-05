import 'package:flutter/material.dart';

class Stuff extends StatefulWidget {
  const Stuff({super.key});

  @override
  State<Stuff> createState() => _StuffState();
}

class _StuffState extends State<Stuff> {
  @override
  Widget build(BuildContext context) {
    return const Text("Stuff");
  }
}