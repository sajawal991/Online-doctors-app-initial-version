import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../jitscVideoCall.dart';


Widget MessageCardCall(context, widget, timestamp, appointmentDetails, {
  required uId,
  required doctId,
  required pEmail,
}){
  return Center(
    child: InkWell(
      onTap: (){
        // if(widget.appointmentDetails != null)
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Meeting(
                  uid: uId,
                  doctid: doctId,
                  email: pEmail,
                )),
          );
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.phone, color: Colors.red, size: 16,),
            SizedBox(width: 5,),
            Text(widget.data!.message + ' at ' + DateFormat('hh:mm a').format(timestamp!),style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),),
          ],
        ),

      ),
    ),
  );
}
