import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget{
  final Function() settings;
  const SideMenu({super.key, 
    required this.settings
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
         Container(
        height: kToolbarHeight + MediaQuery.of(context).viewPadding.top,
        width: double.infinity,
        decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).appBarTheme.backgroundColor!, 
                  Theme.of(context).appBarTheme.backgroundColor!.withValues(alpha: 0.8), 
                ],
              ),
            ),
        child: Center(
            child: Text(
              'MENU',
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: settings,
          iconColor: Theme.of(context).colorScheme.primary,
        ),
        ],
      ),
    );
  }
  
}