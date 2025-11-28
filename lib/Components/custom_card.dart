import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget{

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
    Widget build(BuildContext context) {
      final VoidCallback onTap = isSelectionMode ? () => onSelect(cardData["id"]) : () => tap(cardData["id"]);
      final VoidCallback? onLongPress = isSelectionMode ? null : () => onSelect(cardData["id"]);
        return InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
             child: Card(
                  color: const Color.fromARGB(255, 234, 248, 218),
                  shape:RoundedRectangleBorder(
                      side: BorderSide(
                        color: isSelected?const Color.fromARGB(255, 206, 206, 206):const Color.fromARGB(255, 255, 255, 255),
                        width: isSelected?3:1
                      )
                  ),
                  elevation:isSelected?20:5,
                  child:Padding(
                    padding: EdgeInsets.all(10),
                    child:Column(
                      spacing: 2.0,
                      children: [
                        if(cardData["title"]!='')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cardData["title"],style: TextStyle(color: Colors.black,fontSize:16.0,fontWeight:FontWeight.w800),textAlign: TextAlign.center,overflow:TextOverflow.fade)
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          if(cardData["content"]!='')
                          Expanded(
                            child:Text(
                                cardData['content'],
                                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),fontSize:14.0),textAlign: TextAlign.left,overflow:TextOverflow.fade
                              )
                          )
                            ]
                    ),
                  )
              )
        );
    }

  
}