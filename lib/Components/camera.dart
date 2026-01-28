import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Camera extends StatelessWidget{
  final String type;
  final Function(XFile) getimg;
  const Camera({super.key,required this.type,required this.getimg});
  
  void getpic() async {
    final ImagePicker picker = ImagePicker();
    final src=type=="camera"?ImageSource.camera:ImageSource.gallery;
    if(type=="gallery")
    {
      final List<XFile>? imgs= await picker.pickMultiImage();
      if(imgs!=null && imgs.isNotEmpty)
      {
        for(var img in imgs){
          getimg(img);
        }
      }
      return;
    }
    else{
       var img = await picker.pickImage(source: src);
        if(img!=null)
        {
          getimg(img);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
    radius: 28.0, 
    child: IconButton(
      onPressed: ()=>getpic(), 
      icon: Icon(
        type=="camera"?Icons.camera_alt:Icons.image, 
      ),
    ),
  );
  }
  
}