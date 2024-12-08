import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/Screen/appointment/choosetimeslots.dart';
import 'package:demopatient/Service/Firebase/readData.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/style.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:demopatient/utilities/dialogBox.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Module/User/Provider/auth_provider.dart';

class AppointmentPage extends StatefulWidget {
  final doctId;
  final deptName;
  final doctName;
  final hospitalName;
  final stopBooking;
  final fee;
  final clinicId;
  final cityId;
  final deptId;
  final cityName;
  final clinicName;
  final walkinActive;
  final videoActive;
  final payLaterActive;
  final payNowActive;
  final wspd;
  final vspd;
  final appointmentType;
  const AppointmentPage(
      {Key? key,
      this.doctId,
      this.deptName,
      this.doctName,
      this.hospitalName,
      this.stopBooking,
      this.fee,
      this.cityId,
      this.clinicId,
      this.deptId,
      this.cityName,
      this.clinicName,
      this.vspd,
      this.payLaterActive,
      this.payNowActive,
      this.videoActive,
      this.walkinActive,
      this.wspd,
      this.appointmentType
      })
      : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  List appointmentTypesDetails = [
    {"title": "Online", "text": "Video Consultation", "imageUrl": "assets/icon/video-consultation.png"},
    {"title": "Offline", "text": "Clinic Visit", "imageUrl": "assets/icon/clinic-visit.png"},
    {"title": "EmergencyCall", "text": "Emergency Call", "imageUrl": "assets/icon/emergency.png"}
  ];
  bool _isLoading = false;
  void initState() {
    // TODO: implement initState
    _checkStopBookingStatus();

    appointmentTypesDetails[0]["price"] = widget.vspd;
    appointmentTypesDetails[1]["price"] = widget.wspd;
    appointmentTypesDetails[2]["price"] = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child:CAppBarWidget(title: "Book an appointment".tr)
        ),
        body: Container(
            decoration: IBoxDecoration.upperBoxDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                  child: Column(
                    children: [
                      Spacer(),
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(
                            child: Image.asset(
                              appointmentTypesDetails[widget.appointmentType]['imageUrl'],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Spacer(),
                      Text(appointmentTypesDetails[widget.appointmentType]['text'],
                          style: kPageTitleStyle.copyWith(
                              fontSize: 25
                          )),

                      if(widget.appointmentType == 1)
                        Text('Charges for Clinic Visit ₹' + widget.fee)
                      else if(widget.appointmentType == 0)
                        Text('Charges for Video Consultation ₹' + widget.fee),

                      Spacer(),
                      _cardButton(appointmentTypesDetails[widget.appointmentType]),
                      Spacer(),
                    ],
                  )
              ),
            )
        ),
    );
  }



  Widget _cardButton(
    appointmentTypesDetails,
  ) {
    //  print(appointmentTypesDetails.day);
    return GestureDetector(
      onTap: () {
        if(widget.walkinActive=="1"||widget.videoActive=="1") {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChooseTimeSlotPage(
              serviceName: appointmentTypesDetails["title"],
              doctName: widget.doctName,
              hospitalName: widget.hospitalName,
              deptName: widget.deptName,
              doctId: widget.doctId,
              stopBooking: widget.stopBooking,
              fee: widget.fee,
              clinicId: widget.clinicId,
              cityId: widget.cityId,
              deptId: widget.deptId,
              cityName: widget.cityName,
              clinicName: widget.clinicName,
              wspd: widget.wspd,
              vspd: widget.vspd,
              payNowActive: widget.payNowActive,
              payLaterActive: widget.payLaterActive,
            ),
          ),
        );
        } else{
          ToastMsg.showToastMsg("sorry doctor is not taking appointment".tr);
        }
      },
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(50)),
        child: Center(
          child: Text(
              "Choose an Appointment Time ₹${widget.fee}",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans-Bold',
                fontSize: 16.0,
              )),
        ),
      ),
    );
  }

  void _checkStopBookingStatus() async {
    setState(() {
      _isLoading = true;
    });
    final res = await ReadData.fetchSettings(); //fetch settings details
    if (res != null){
      // print(1);
      // print(res["stopBooking"]);

      if (res["stopBooking"] != false) {
        // print("error 123");
        // DialogBoxes.stopBookingAlertBox(context, "Sorry!".tr,
        //     "We are currently not accepting new appointments. we will start soon"
        //         .tr);
      } else {
        if (widget.stopBooking == "true") {
          DialogBoxes.stopBookingAlertBox(context, "Sorry!".tr,
              "${widget.doctName} " + "is not accepting new appointments".tr);
        }
      }
  }
    setState(() {
      _isLoading = false;
    });
  }
}
