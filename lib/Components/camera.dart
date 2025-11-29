import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Camera extends StatelessWidget{
  final String type;
  final Function(XFile) getimg;
  const Camera({super.key,required this.type,required this.getimg});
  
  void getpic() async {
    final ImagePicker picker = ImagePicker();
    final src=type=="camera"?ImageSource.camera:ImageSource.gallery;
    var img = await picker.pickImage(source: src);
    if(img!=null)
    {
      getimg(img);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton.filled(
        onPressed: ()=>getpic(), 
        icon: Icon(type=="camera"?Icons.camera_alt:Icons.image),
        color: Theme.of(context).colorScheme.inversePrimary,
        ),
    );
  }
  
}