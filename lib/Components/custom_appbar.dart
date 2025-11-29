import 'package:app_v1/Provider/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final misc=ref.watch(data);
      var view = misc['view'];
      void changegrid(){
        ref.read(data.notifier).changeView();
      }
      return  AppBar(
          backgroundColor: mode? const Color.fromARGB(54, 53, 235, 43):Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false,
          title: mode?
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: (){
                  close("close");
                }, 
                icon:const Icon(Icons.close_rounded)
              ),
              Text(count),
            ],
          ):Center(
            child: TextField(
                  onChanged: (value) => ref.read(searchQueryProvider.notifier).search(value),
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    prefixIcon: Icon(Icons.search_rounded),
                    prefixIconColor: Colors.black87,
                  ),
                ),
          ),
           actions:mode?
           [
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.delete),
                color: Colors.red,
                tooltip: 'Delete',
                onPressed: () => close("delete"),
              )
            ]
          : [
            IconButton(
                iconSize: 30,
                icon: view!=1?Icon(Icons.list_rounded) :Icon(Icons.grid_view),
                color: Colors.black,
                tooltip: 'View',
                onPressed:changegrid
              )
            ],
        );
  }
} 