import 'package:app_v1/Provider/comman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings>{
  final List<Map<String,dynamic>> menuOptions = [
      {'label':'Default','icon':Icons.app_settings_alt},
      {'label':'Light','icon':Icons.light_mode},
      {'label':'Dark','icon':Icons.dark_mode}
  ];

  String dropdownValue = 'Default';
  @override
  Widget build(BuildContext context) {
      final settingsData = ref.watch(dataprovider);
      final selected = settingsData['theme'] ?? 'Default';
      return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Center(
          child: Padding(padding: EdgeInsets.all(10),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Text('Theme'),
                      DropdownMenu<String>(

                        menuStyle:MenuStyle(
                          shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        ),
                        inputDecorationTheme: const InputDecorationTheme(
                          border: InputBorder.none, 
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        initialSelection: selected,
                          onSelected: (String? value) {
                            setState(() {
                              dropdownValue = value!;
                              ref.read(dataprovider.notifier).changetheme(dropdownValue);
                            });
                          },
                          dropdownMenuEntries: menuOptions.map<DropdownMenuEntry<String>>((option) {
                              return DropdownMenuEntry<String>(
                                value: option['label'], 
                                label: option['label'],
                                leadingIcon: Icon(
                                  option['icon'], 
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }).toList(),
                      )
                  ],
                ),
            ],
          ),
          )
        )
      );
  }
  
}