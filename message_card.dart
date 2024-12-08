import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget MessageCard(context, widget, timestamp){
  return Padding(
    padding: const EdgeInsets.only(
      left: 10,
      right: 30,
      top: 5,
      bottom: 20,
    ),
    child: Text(
      widget.data!.message.toString(),
      style: TextStyle(
        fontSize: 16,
      ),
    ),
  );
}
