import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Services/comman.dart';

class CustomAppbar extends ConsumerWidget implements PreferredSizeWidget {
  final bool mode;
  final String count;
  final Function(String) close;

  const CustomAppbar({
    super.key,
    required this.mode,
    required this.count,
    required this.close,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(dataprovider.select((map) => map['view']));
    final colorScheme = Theme.of(context).colorScheme;

    void changegrid() {
      ref.read(dataprovider.notifier).updateSettings(view: view == 1 ? 2 : 1);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: mode
          ? _buildSelectionBar(context, colorScheme)
          : _buildNormalBar(context, ref, view, colorScheme, changegrid),
    );
  }

  Widget _buildSelectionBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      key: const ValueKey('selection'),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            onPressed: () => close("close"),
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(width: 4),
          Text(
            'selected',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          iconSize: 26,
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: 'Delete',
          onPressed: () => close("delete"),
        ),
        IconButton(
          iconSize: 26,
          icon: const Icon(Icons.push_pin_outlined),
          tooltip: 'Pin',
          onPressed: () => close("pin"),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildNormalBar(
    BuildContext context,
    WidgetRef ref,
    int view,
    ColorScheme colorScheme,
    VoidCallback changegrid,
  ) {
    return AppBar(
      key: const ValueKey('normal'),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Container(
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withAlpha(15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          onChanged: (value) => ref.read(dataprovider.notifier).search(value),
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: "Search notes...",
            hintStyle: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withAlpha(100),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 4.0,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withAlpha(100),
              size: 22,
            ),
          ),
        ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: IconButton(
            key: ValueKey(view),
            iconSize: 26,
            icon: Icon(
              view != 1 ? Icons.list_rounded : Icons.grid_view_rounded,
            ),
            tooltip: view != 1 ? 'List view' : 'Grid view',
            onPressed: changegrid,
          ),
        ),
      ],
    );
  }
}
