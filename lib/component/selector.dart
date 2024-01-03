import 'package:flutter/material.dart';

enum ModeLabel {
  kanji('Kanji', Colors.pink),
  vocab('Vocab', Colors.blue);

  const ModeLabel(this.label, this.color);
  final String label;
  final Color color;
}

class DropdownMenuExample extends StatefulWidget {
  final int maxLevel;

  const DropdownMenuExample({super.key,  required this.maxLevel});

  @override
  State<DropdownMenuExample> createState() =>
      _DropdownMenuExampleState(maxLevel: maxLevel);
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  final int maxLevel;
  final TextEditingController modeController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  ModeLabel? selectedMode;
  int? selectedLevel;

  _DropdownMenuExampleState({
    required this.maxLevel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownMenu<ModeLabel>(
                  initialSelection: ModeLabel.kanji,
                  controller: modeController,
                  // requestFocusOnTap is enabled/disabled by platforms when it is null.
                  // On mobile platforms, this is false by default. Setting this to true will
                  // trigger focus request on the text field and virtual keyboard will appear
                  // afterward. On desktop platforms however, this defaults to true.
                  requestFocusOnTap: true,
                  label: const Text('Mode'),
                  onSelected: (ModeLabel? mode) {
                    setState(() {
                      selectedMode = mode;
                    });
                  },
                  dropdownMenuEntries: ModeLabel.values
                      .map<DropdownMenuEntry<ModeLabel>>((ModeLabel color) {
                    return DropdownMenuEntry<ModeLabel>(
                      value: color,
                      label: color.label,
                      enabled: color.label != 'Grey',
                      style: MenuItemButton.styleFrom(
                        foregroundColor: color.color,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 24),
                DropdownMenu<int>(
                  controller: levelController,
                  enableFilter: true,
                  requestFocusOnTap: true,
                  leadingIcon: const Icon(Icons.school),
                  label: const Text('Level'),
                  menuHeight: 300,
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  onSelected: (int? level) {
                    setState(() {
                      selectedLevel = level;
                    });
                  },
                  dropdownMenuEntries: positiveIntegers.skip(1).take(maxLevel).toList().map<DropdownMenuEntry<int>>(
                    (int level) {
                      return DropdownMenuEntry<int>(
                        value: level,
                        label: level.toString(),
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
          ),
          if (selectedMode != null && selectedLevel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: selectedMode?.color,
                  child: Text(
                      'You selected ${selectedMode?.label} $selectedLevel'),
                ),
              ],
            )
          else
            const Text('Please select something.')
        ],
      ),
    );
  }
}

Iterable<int> get positiveIntegers sync* {
  int i = 0;
  while (true) {
    yield i++;
  }
}
