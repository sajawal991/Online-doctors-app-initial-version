import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Widget MessageCardAttachment(context, widget, timestamp){
  return InkWell(
    onTap: () async {
      var url = widget.data!.message;
      if (await canLaunch(url)) {
      await launch(url);
      } else {
      throw 'Could not launch $url';
      }
    },
    child: Padding(
      padding: const EdgeInsets.only(
        left: 1,
        // right: 30,
        top: 1,
        bottom: 1,
      ),
      child:Container(
        padding: EdgeInsets.only(bottom: 16),
        child: Container(
          width: 200.0,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(9.0),
            border: Border.all(color: Color(0xffdcf8c6),width: 4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.file_copy_outlined,color: Colors.red,),
                SizedBox(width: 10,),
                Text('Download File',style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),),
              ],
            ),
          ) ,
        ),
      ),
    ),
  );
}

