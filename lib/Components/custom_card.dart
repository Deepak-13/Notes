import 'dart:typed_data';

import 'package:app_v1/Provider/comman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomCard extends ConsumerWidget{

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
    Widget build(BuildContext context,WidgetRef ref) {
      final colorScheme = Theme.of(context).colorScheme;
      final VoidCallback onTap = isSelectionMode ? () => onSelect(cardData["id"]) : () => tap(cardData["id"]);
      final VoidCallback? onLongPress = isSelectionMode ? null : () => onSelect(cardData["id"]);
      final images = ref.watch(noteImagesProvider((noteId: cardData["id"], limit: 3)));
      return Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child :Stack(
              alignment: AlignmentGeometry.topRight,
              children: [
                  Card(
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: isSelected?colorScheme.primary : colorScheme.outline,
                        width: isSelected?2:0.5
                      )
                  ),
                  elevation:isSelected?3:6,
                  child:Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 4.0),
                    child: 
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 50,
                        ),
                        child :
                        ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 2.0),
                          physics: NeverScrollableScrollPhysics(),
                          children:[
                              images.when(
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (err, stack) => Text('Error loading images: $err', style: TextStyle(color: Colors.red)),
                                data: (images) {
                                  if (images.isEmpty) {
                                    return const SizedBox.shrink(); 
                                  }
                                  return Padding(
                                  padding: EdgeInsets.all(0),
                                  child: SizedBox(
                                    height: 200,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: images.map<Widget>((imgItem){
                                          return Expanded(
                                          child: 
                                          Padding(
                                          padding: const EdgeInsets.all(1),
                                          child: ClipRRect( 
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.memory(
                                              imgItem, 
                                              isAntiAlias: true,
                                              fit: BoxFit.cover,
                                              cacheHeight: 200, 
                                              cacheWidth: 300,
                                            ),
                                          ),
                                        )
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  );
                                  }
                              ),
                              if(cardData["Title"]!='')
                                Padding(
                                  padding: EdgeInsets.only(bottom: cardData["Description"]!=''?5.0:2,top: 2,right: 1,left: 1),
                                  child: Text(
                                    cardData["Title"],
                                    textAlign: TextAlign.left,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis, 
                                  ),
                                ),
                                if(cardData["Description"]!='')
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text(
                                    cardData['Description'],
                                    textAlign: TextAlign.left,
                                    maxLines: 8,
                                    overflow: TextOverflow.clip, 
                                  ),
                                  ),
                                  ]     
                          ),
                        )
                      )
                  ),
                if(cardData['Pinned'] == 1) 
                 Positioned(
                    top: 8,
                    right: 8,
                    child: 
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5), 
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.push_pin_rounded, color: Colors.white, size: 16),
                      ) 
                  )
              ],
            )
          )
      );
    }

  
}