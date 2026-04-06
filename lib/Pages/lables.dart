import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/Services/comman.dart';

class Lables extends ConsumerStatefulWidget {
  const Lables({super.key});

  @override
  ConsumerState<Lables> createState() => _LablesState();
}

class _LablesState extends ConsumerState<Lables> {
  bool enableAddLable = false;
  int enableEditLable = -1;
  final TextEditingController newLableController = TextEditingController();
  final TextEditingController oldLableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    newLableController.text = "";
  }

  @override
  void dispose() {
    newLableController.dispose();
    super.dispose();
  }

  void toggleAddLable() {
    print("Toggle Add Lable");
    setState(() {
      enableAddLable = !enableAddLable;
      enableEditLable = -1;
    });
  }

  void UpdateLable(txt, id) {
    if (lableExist(txt, id)) {
      var msg = txt.trim().isEmpty
          ? "Lable Cannot be Empty"
          : "Lable already exists";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
      return;
    }
    ref.read(lablesprovider.notifier).update(id, txt);
    setState(() {
      enableEditLable = -1;
    });
  }

  bool lableExist(String lable, int currentID) {
    final normalized = lable.trim().toLowerCase();
    var lableList = ref.watch(lablesprovider);
    return lableList.any((l) {
      final existing = l['Lable'].toString().trim().toLowerCase();
      return (existing == normalized && l['id'] != currentID) ||
          normalized == '';
    });
  }

  void ChangeEdit(Map<String, dynamic> lable, int index) {
    if (enableEditLable != -1) {
      UpdateLable(oldLableController.text, enableEditLable);
    }
    oldLableController.text = lable['Lable'];
    setState(() {
      enableEditLable = lable['id'];
      enableAddLable = false;
    });
  }

  Future<void> _confirmDelete(Map<String, dynamic> lable) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Label"),
        content: Text("Are you sure you want to delete \"${lable['Lable']}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(lablesprovider.notifier).delete(lable['id'] as int);
      setState(() {
        enableEditLable = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fetchLables = ref.watch(fetchLablesProvider);
    var lableList = ref.watch(lablesprovider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Labels", style: theme.textTheme.titleLarge),
      ),
      body: fetchLables.when(
        data: (data) {
          return Column(
            children: [
              addLable(),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withAlpha(30),
              ),
              Expanded(
                child: lableList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.label_off_outlined,
                              size: 72,
                              color: theme.colorScheme.primary.withAlpha(100),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Labels Yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap + to create a new label",
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: lableList.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          indent: 56,
                          color: theme.colorScheme.outline.withAlpha(20),
                        ),
                        itemBuilder: (context, index) {
                          final isEditing =
                              enableEditLable == lableList[index]['id'];
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            switchInCurve: Curves.easeInOut,
                            switchOutCurve: Curves.easeInOut,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  sizeFactor: animation,
                                  axisAlignment: -1.0,
                                  child: child,
                                ),
                              );
                            },
                            child: isEditing
                                ? EditableLable(
                                    key: const ValueKey('editing'),
                                    lable: lableList[index],
                                    index: index,
                                    lableList: lableList,
                                  )
                                : InkWell(
                                    key: const ValueKey('display'),
                                    onTap: () {
                                      ChangeEdit(lableList[index], index);
                                    },
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                      leading: Icon(
                                        Icons.label_outline,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      title: Text(
                                        lableList[index]['Lable'] ?? "",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        onPressed: () {
                                          ChangeEdit(lableList[index], index);
                                        },
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () {
          return Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          return Center(child: Text("Error"));
        },
      ),
    );
  }

  Widget EditableLable({
    Key? key,
    required Map<String, dynamic> lable,
    required int index,
    required List<Map<String, dynamic>> lableList,
  }) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: theme.colorScheme.error,
            ),
            onPressed: () => _confirmDelete(lable),
          ),
          Expanded(
            child: TextField(
              controller: oldLableController,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: "Label",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.check_rounded, color: theme.colorScheme.primary),
            onPressed: () {
              UpdateLable(oldLableController.text, lable['id']);
            },
          ),
        ],
      ),
    );
  }

  Widget addLable() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(30),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween(begin: 0.75, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: !enableAddLable
                ? IconButton(
                    key: const ValueKey('add'),
                    onPressed: () {
                      toggleAddLable();
                    },
                    icon: Icon(
                      Icons.add,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : IconButton(
                    key: const ValueKey('close'),
                    onPressed: () {
                      newLableController.clear();
                      toggleAddLable();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: !enableAddLable
                  ? InkWell(
                      key: const ValueKey('label_text'),
                      onTap: () => toggleAddLable(),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Create New Label",
                              style: TextStyle(
                                fontSize: 15,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : TextField(
                      key: const ValueKey('label_field'),
                      autofocus: true,
                      controller: newLableController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: "Create New Label",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                      ),
                    ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: enableAddLable
                ? IconButton(
                    key: const ValueKey('confirm'),
                    onPressed: () {
                      if (lableExist(newLableController.text, -1)) {
                        var msg = newLableController.text.trim().isEmpty
                            ? "Lable Cannot be Empty"
                            : "Lable already exists";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        );
                        return;
                      }
                      ref
                          .read(lablesprovider.notifier)
                          .add(newLableController.text);
                      setState(() {
                        enableAddLable = false;
                        newLableController.text = "";
                      });
                    },
                    icon: Icon(
                      Icons.check_rounded,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}
