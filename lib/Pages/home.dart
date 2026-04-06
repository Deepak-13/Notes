import 'package:notes/Components/custom_appbar.dart';
import 'package:notes/Components/custom_card.dart';
import 'package:notes/Components/side_menu.dart';
import 'package:notes/Pages/notes.dart';
import 'package:notes/Pages/lables.dart';
import 'package:notes/Pages/settings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes/Services/global.dart';

import '../Services/comman.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  List card = [];
  List<int> selected = [];
  bool _selectionMode = false;
  int _view = 2;
  List<Map<String, dynamic>> filteredlist = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (launchNotificationId != null && launchNotificationId != -1) {
        final int id = launchNotificationId!;
        await ref.read(noteprovider.notifier).disableReminder(id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Notespage(type: "exist", idx: id),
          ),
        );
        launchNotificationId = null;
      }
    });
  }

  void select(int idx) {
    setState(() {
      if (selected.contains(idx)) {
        selected.removeWhere((item) => item == idx);
      } else {
        selected.add(idx);
      }
      _selectionMode = _selectionMode == false ? selected.isNotEmpty : true;
    });
  }

  void closeselection(String txt) {
    if (txt == "delete") {
      ref.read(noteprovider.notifier).delete(selected);
    }
    if (txt == "pin") {
      ref.read(noteprovider.notifier).pin(selected);
    }
    setState(() {
      selected.clear();
      _selectionMode = selected.isNotEmpty;
    });
  }

  Future<void> openNotes(int idx) async {
    print(idx);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Notespage(type: "exist", idx: idx),
      ),
    );
  }

  Future<void> openSettings() async {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  Future<void> openLables() async {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Lables()));
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(filteredListProvider);
    final misc = ref.watch(dataprovider);
    _view = misc['view'];
    final pinned = list.where((c) => c['Pinned'] == 1).toList();
    final others = list.where((c) => c['Pinned'] == 0).toList();

    return Scaffold(
      drawer: SideMenu(settings: openSettings, lables: openLables),
      appBar: CustomAppbar(
        mode: _selectionMode,
        count: selected.length.toString(),
        close: closeselection,
      ),
      body: list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withAlpha(150),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Notes Available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap + to add a new note",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                if (pinned.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "PINNED",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: _view,
                      mainAxisSpacing: 1,
                      crossAxisSpacing: 1,
                      itemBuilder: (context, index) => CustomCard(
                        cardData: pinned[index],
                        isSelected: selected.contains(pinned[index]["id"]),
                        isSelectionMode: _selectionMode,
                        onSelect: select,
                        tap: openNotes,
                      ),
                      childCount: pinned.length,
                    ),
                  ),
                ],
                if (others.isNotEmpty) ...[
                  if (pinned.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "OTHERS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: _view,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 5,
                      itemBuilder: (context, index) => CustomCard(
                        cardData: others[index],
                        isSelected: selected.contains(others[index]["id"]),
                        isSelectionMode: _selectionMode,
                        onSelect: select,
                        tap: openNotes,
                      ),
                      childCount: others.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        onPressed: () async {
          closeselection("close");
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Notespage(type: "new", idx: 0),
            ),
          );
        },
        tooltip: 'Add notes',
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Note',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
