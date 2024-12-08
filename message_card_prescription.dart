import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../model/prescriptionModel.dart';
import '../../../prescription/prescriptionDetails.dart';
import '../labtestapi.dart';

Widget MessageCardPrescription(context, widget, timestamp){
  return InkWell(
    onTap: () async {
      // _launchURL();
      // print(widget.widget);
      // AppointmentChatModal.prescriptionModal(context, widget.widget);

      // call api
      PrescriptionModel prescription = await LabTestApi().GetPrescription(widget.data!.foreignKey);


      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PrescriptionDetailsPage(
                title: prescription.appointmentName,
                prescriptionDetails: prescription)),
      );
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
                Text('View Prescription',style: TextStyle(
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