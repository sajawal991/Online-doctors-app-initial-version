import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../../CustomUI/picture.dart';

Widget MessageCardImage(context, widget, timestamp){
  return InkWell(
    onTap: (){
      Get.to(Picture(widget.data!.message));

    },
    child: Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Container(
        width: 400.0,
        height: 300.0,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9.0),
            border: Border.all(color: Color(0xffdcf8c6),width: 4),
            image: DecorationImage(
                image: NetworkImage(
                  widget.data!.message,
                ),

                fit: BoxFit.cover)),
      ),
    ),
  );
}
