import 'package:demopatient/Screen/appointment/ChatScreenWidget/picture.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utilities/color.dart';


class LabDetail extends StatelessWidget {
  final prescriptionDetails;
  LabDetail({Key? key, required this.prescriptionDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // centerTitle: true,
        title: Text(prescriptionDetails.labName,
            style: TextStyle(
              fontFamily: 'OpenSans-Bold',
              fontSize: 14.0,
            )),
        backgroundColor: appBarColor,
        automaticallyImplyLeading: true,
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: IconButton(onPressed: (){
          //
          //     Get.back();
          //   }, icon: Icon(Icons.close,color: Colors.white,size: 30,)),
          // )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(prescriptionDetails.labTestAttachments.length == 0)
            // InkWell(
            //   onTap: (){
            //     getImagecamera();
            //   },
            // )
            Container(
                margin: EdgeInsets.all(10),
                child: Text('No Report uploaded by patient',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red
                    )
                )
            ),

          for(int i=0;i<prescriptionDetails.labTestAttachments.length;i++)
            InkWell(
              onTap: (){
                Get.to(Picture(prescriptionDetails.labTestAttachments[i].attachment));
                PinchZoom(
                  child: Image.network(prescriptionDetails.labTestAttachments[i].attachment),
                  resetDuration: const Duration(milliseconds: 100),
                  maxScale: 3,
                  onZoomStart: (){print('Start zooming');},
                  onZoomEnd: (){print('Stop zooming');},
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    child: Container(
                      width: 400.0,
                      height: 300.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9.0),
                          border: Border.all(color: Color(0xffdcf8c6),width: 4),
                          image: DecorationImage(
                              image: NetworkImage(
                                prescriptionDetails.labTestAttachments[i].attachment,
                              ),

                              fit: BoxFit.cover)),
                    ),
                  ),
                ),
              ),
            )
          // PinchZoom(
          //   child: Image.network(prescriptionDetails.labTestAttachments.toList()[1].attachment),
          //   resetDuration: const Duration(milliseconds: 100),
          //   maxScale: 3,
          //   onZoomStart: (){print('Start zooming');},
          //   onZoomEnd: (){print('Stop zooming');},
          // ),
        ],
      ),
    );
  }
}
