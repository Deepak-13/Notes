import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:notes/Services/comman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/Services/global.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  final List<Map<String, dynamic>> menuOptions = [
    {'label': 'System', 'icon': Icons.app_settings_alt_rounded},
    {'label': 'Light', 'icon': Icons.light_mode_rounded},
    {'label': 'Dark', 'icon': Icons.dark_mode_rounded},
  ];
  late Color pickerColor;
  late Map<String, dynamic> colorName;
  String dropdownValue = 'System';

  final colors = [
    // 🟡 Amber (primary / default)
    {'name': 'Amber', 'color': const Color(0xFFFFB300)},

    // 🔵 Blue tones
    {'name': 'Soft Blue', 'color': const Color(0xFF7AA0FF)}, // 122,160,255
    {'name': 'Deep Blue', 'color': const Color(0xFF3F6FE0)},
    {'name': 'Indigo', 'color': const Color(0xFF3949AB)},

    // 🟢 Green tones
    {'name': 'Forest Green', 'color': const Color(0xFF2F650C)}, // 47,101,12
    {'name': 'Dark Green', 'color': const Color(0xFF1B5E20)},
    {'name': 'Olive Green', 'color': const Color(0xFF556B2F)},

    // 🔴 Red tones
    {'name': 'Deep Red', 'color': const Color(0xFF7C1214)}, // 124,18,20
    {'name': 'Crimson', 'color': const Color(0xFFB71C1C)},
    {'name': 'Brick Red', 'color': const Color(0xFF8B0000)},

    // 🟣 Purple tones
    {'name': 'Royal Purple', 'color': const Color(0xFF6D1599)}, // 109,21,153
    {'name': 'Deep Purple', 'color': const Color(0xFF4A148C)},
    {'name': 'Violet', 'color': const Color(0xFF7B1FA2)},

    // 🌊 Extras
    {'name': 'Teal Blue', 'color': const Color(0xFF006D77)},
    {'name': 'Slate', 'color': const Color(0xFF455A64)},
  ];

  @override
  void initState() {
    super.initState();
    pickerColor = Color(ref.read(dataprovider)['color']);
    colorName = colors.firstWhere((color) {
      final c = color['color'] as Color;
      return c.toARGB32() == pickerColor.toARGB32();
    }, orElse: () => colors[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          children: [
            Text(
              "APPEARANCE",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ThemeCard(),
            ColorCard(),
          ],
        ),
      ),
    );
  }

  Card ThemeCard() {
    final settingsData = ref.watch(dataprovider);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(30),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            settingsData['theme'] == 'System'
                ? Icons.phone_android_rounded
                : settingsData['theme'] == 'Light'
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text(
          "App Theme",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: DropdownMenu<String>(
          width: 125,
          menuStyle: MenuStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            elevation: WidgetStateProperty.all(8),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          initialSelection: settingsData['theme'],
          onSelected: (String? value) {
            setState(() {
              dropdownValue = value!;
              ref
                  .read(dataprovider.notifier)
                  .updateSettings(theme: dropdownValue);
            });
          },
          dropdownMenuEntries: menuOptions.map<DropdownMenuEntry<String>>((
            option,
          ) {
            return DropdownMenuEntry<String>(
              value: option['label'],
              label: option['label'],
              leadingIcon: Icon(
                option['icon'],
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }).toList(),
        ),
        dense: null,
      ),
    );
  }

  Widget ColorCard() {
    void changeColor(Color color, Map<String, dynamic> obj) {
      setState(() {
        pickerColor = color;
        colorName = obj;
      });
      ref
          .read(dataprovider.notifier)
          .updateSettings(color: pickerColor.toARGB32());
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(30),
          width: 1,
        ),
      ),
      child: Container(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.palette_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: const Text(
            "App Color",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorName['color'],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
              SizedBox(width: 3),
              Text(colorName['name']),
              IconButton(
                icon: Icon(Icons.arrow_drop_down_rounded),
                onPressed: () {
                  colorpicker(changeColor);
                },
              ),
            ],
          ),
          dense: null,
        ),
      ),
    );
  }

  void colorpicker(void Function(Color, Map<String, dynamic>) changeColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Choose Accent Color',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: colors.map((item) {
              final Color color = item['color'] as Color;
              final String name = item['name'] as String;
              final bool isSelected =
                  pickerColor.toARGB32() == color.toARGB32();

              return Tooltip(
                message: name,
                child: GestureDetector(
                  onTap: () {
                    changeColor(color, item);
                    Navigator.of(context).pop();
                  },
                  child: Hero(
                    tag: 'color_${color.toARGB32()}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withAlpha(80),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}
