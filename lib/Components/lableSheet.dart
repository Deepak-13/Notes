import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/Services/comman.dart';

class LableSheet extends ConsumerStatefulWidget {
  const LableSheet({super.key, required this.notesId});
  final int notesId;
  @override
  ConsumerState<LableSheet> createState() => _LableSheetState();
}

class _LableSheetState extends ConsumerState<LableSheet> {
  List<Map<String, dynamic>> selectedLable = [];
  @override
  void initState() {
    super.initState();
  }

  Future<void> getLablesforNotes() async {
    if (widget.notesId > 0) {
      selectedLable = [
        ...await ref
            .read(lablesprovider.notifier)
            .getLablesforNotes(widget.notesId),
      ];
      print("selectedLable....$selectedLable");
    }
  }

  @override
  Widget build(BuildContext context) {
    final fetchLables = ref.watch(fetchLablesProvider);
    List lables = ref.watch(lablesprovider);
    print("lables....$lables");

    getLablesforNotes();
    return AlertDialog(
      title: Text("Lables"),
      content: fetchLables.when(
        data: (data) {
          return ListView.builder(
            itemCount: lables.length,
            itemBuilder: (context, index) {
              return CheckboxListTile(
                title: Text(lables[index]['Lable']),
                value: selectedLable.contains(lables[index]),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedLable.add(lables[index]);
                    } else {
                      selectedLable.remove(lables[index]);
                    }
                  });
                },
              );
            },
          );
        },
        error: (error, stack) => Text("Error: $error"),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () => {Navigator.pop(context, selectedLable)},
          child: Text("Done"),
        ),
      ],
    );
  }
}
