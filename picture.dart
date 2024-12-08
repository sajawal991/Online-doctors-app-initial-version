import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
class Picture extends StatefulWidget {
  String? message;
   Picture(this.message, {Key? key}) : super(key: key);

  @override
  State<Picture> createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
      backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(onPressed: (){

              Get.back();
            }, icon: Icon(Icons.close,color: Colors.white,size: 30,)),
          )
        ],
      ),
      body: PinchZoom(
        child: Image.network(widget!.message.toString()),
        resetDuration: const Duration(milliseconds: 100),
        maxScale: 3,
        onZoomStart: (){print('Start zooming');},
        onZoomEnd: (){print('Stop zooming');},
      ),
    );
  }
}
