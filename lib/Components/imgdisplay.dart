import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Imgdisplay extends StatelessWidget{

  final List<Map<String,dynamic>> img;
  final Function(int) ondelete;
  const Imgdisplay({super.key,required this.img,required this.ondelete});

  @override
  Widget build(BuildContext context) {
    
    return CarouselSlider.builder(
        itemCount: img.length, 
        options: CarouselOptions(
          height: 200,
          enableInfiniteScroll: false,
          padEnds: false,
          enlargeCenterPage: false,
          viewportFraction: img.length==1?1:img.length==2?0.5:0.3333,
        ),
        itemBuilder: (context, index,int pageIndex) {
           return Padding(
            padding: const EdgeInsets.symmetric(horizontal:2), 
            child:Stack(
              alignment: AlignmentGeometry.topRight,
              children: [
                 SizedBox(
                    height: 200, 
                    width: double.infinity,
                    child: Image.memory(
                      img[index]['img'], 
                      fit: BoxFit.cover, 
                    ),
                  ),
                FloatingActionButton.small(
                  shape: CircleBorder(),
                  onPressed: () => ondelete(img[index]['id']),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                  child:Icon(Icons.delete)
                  )
              ],
            )
          );
        }, 
        );
  }

  
}