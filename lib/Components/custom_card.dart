import 'package:notes/Services/comman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> cardData;
  final bool isSelected;
  final bool isSelectionMode;
  final Function(int) onSelect;
  final Function tap;
  const CustomCard({
    super.key,
    required this.cardData,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onSelect,
    required this.tap,
  });

  @override
  ConsumerState<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends ConsumerState<CustomCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cardData = widget.cardData;
    final isSelected = widget.isSelected;
    final isSelectionMode = widget.isSelectionMode;

    final VoidCallback onTap = isSelectionMode
        ? () => widget.onSelect(cardData["id"])
        : () => widget.tap(cardData["id"]);
    final VoidCallback? onLongPress = isSelectionMode
        ? null
        : () => widget.onSelect(cardData["id"]);
    final images = ref.watch(
      noteImagesProvider((noteId: cardData["id"], limit: 3)),
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : (isSelected ? 0.98 : 1.0),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withAlpha(80),
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: colorScheme.primary.withAlpha(50),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  images.when(
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (err, stack) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ),
                    data: (imageList) {
                      if (imageList.isEmpty) return const SizedBox.shrink();
                      return SizedBox(
                        height: imageList.length == 1 ? 180 : 140,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: imageList.map<Widget>((img) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(1),
                                child: Image.memory(
                                  img,
                                  fit: BoxFit.cover,
                                  isAntiAlias: true,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cardData["Title"]?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              cardData["Title"],
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (cardData["Description"]?.isNotEmpty ?? false)
                          Text(
                            cardData['Description'],
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withAlpha(180),
                              height: 1.4,
                              fontSize: 14,
                            ),
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (cardData['Pinned'] == 1 || cardData['Reminder'] == 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cardData['Pinned'] == 1)
                        _buildStatusIcon(Icons.push_pin_rounded, colorScheme),
                      if (cardData['Pinned'] == 1 && cardData['Reminder'] == 1)
                        const SizedBox(width: 4),
                      if (cardData['Reminder'] == 1)
                        _buildStatusIcon(
                          Icons.access_time_filled_rounded,
                          colorScheme,
                        ),
                    ],
                  ),
                ),
              // Selection checkbox overlay
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface.withAlpha(180),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4),
        ],
      ),
      child: Icon(icon, size: 14, color: colorScheme.primary),
    );
  }
}
