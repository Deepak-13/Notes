
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Provider/comman.dart';

class CustomAppbar extends ConsumerWidget implements PreferredSizeWidget{

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
  Widget build(BuildContext context , WidgetRef ref) {
      final view = ref.watch(dataprovider.select((map) => map['view']));
      void changegrid(){
        ref.read(dataprovider.notifier).changeView();
      }
      final colorscheme = Theme.of(context).appBarTheme;
      
      return mode? AppBar(
        automaticallyImplyLeading: false,
          title:
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: (){
                  close("close");
                }, 
                icon:const Icon(Icons.close_rounded),
              ),
              Text(count),
            ],
          ),
           actions:
           [
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () => close("delete"),
              ),
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.push_pin_rounded),
                tooltip: 'Pin',
                onPressed: () => close("pin"),
              ),
            ]
        ) : AppBar(
        leading:IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
        title: Center(
            child: TextField(
                  onChanged: (value) => ref.read(dataprovider.notifier).search(value),
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
                
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700,color:colorscheme.foregroundColor),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0)),borderSide: BorderSide(color: colorscheme.foregroundColor!, width: 1.0),),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    prefixIcon: Icon(Icons.search_rounded,color:colorscheme.foregroundColor,),
                  ),
                ),
          ),
          actions: [
            IconButton(
                iconSize: 30,
                icon: view!=1?Icon(Icons.list_rounded) :Icon(Icons.grid_view),
                tooltip: 'View',
                onPressed:changegrid
              )
            ],
      ) ;
  }
} 