import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:widget_zoom/widget_zoom.dart';
class Imgdisplay extends StatelessWidget{

  final List<Uint8List> img;
  final Function(int) ondelete;
  final int idx;
  const Imgdisplay({super.key,required this.img,required this.ondelete,required this.idx});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
        itemCount: img.length, 
        options: CarouselOptions(
          height: 250,
          enableInfiniteScroll: false,
          padEnds: false,
          viewportFraction: img.length==1?1:img.length==2?0.5:0.3000,
          scrollPhysics: const BouncingScrollPhysics(),
        ),
        itemBuilder: (context, index, int pageIndex) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: WidgetZoom(
                    heroAnimationTag: 'tag',
                    zoomWidget:Image.memory(
                          img[index],
                          isAntiAlias: true,
                          fit: BoxFit.cover,
                          height: 250,
                          width: double.infinity,
                        ),
                      )
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child:InkWell(
                  onTap: () => ondelete(index),
                  child:
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                  )
              ),
            ],
          );
        }, 
        );
  }

  
}