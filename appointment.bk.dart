// import 'package:demopatient/utilities/decoration.dart';
// import 'package:demopatient/Screen/appointment/choosetimeslots.dart';
// import 'package:demopatient/Service/Firebase/readData.dart';
// import 'package:demopatient/utilities/color.dart';
// import 'package:demopatient/utilities/style.dart';
// import 'package:demopatient/utilities/toastMsg.dart';
// import 'package:demopatient/widgets/appbarsWidget.dart';
// import 'package:demopatient/widgets/loadingIndicator.dart';
// import 'package:flutter/material.dart';
// import 'package:demopatient/utilities/dialogBox.dart';
// import 'package:get/get.dart';
//
// class AppointmentPage extends StatefulWidget {
//   final doctId;
//   final deptName;
//   final doctName;
//   final hospitalName;
//   final stopBooking;
//   final fee;
//   final clinicId;
//   final cityId;
//   final deptId;
//   final cityName;
//   final clinicName;
//   final walkinActive;
//   final videoActive;
//   final payLaterActive;
//   final payNowActive;
//   final wspd;
//   final vspd;
//   final appointmentType;
//   const AppointmentPage(
//       {Key? key,
//       this.doctId,
//       this.deptName,
//       this.doctName,
//       this.hospitalName,
//       this.stopBooking,
//       this.fee,
//       this.cityId,
//       this.clinicId,
//       this.deptId,
//       this.cityName,
//       this.clinicName,
//       this.vspd,
//       this.payLaterActive,
//       this.payNowActive,
//       this.videoActive,
//       this.walkinActive,
//       this.wspd,
//       this.appointmentType
//       })
//       : super(key: key);
//
//   @override
//   _AppointmentPageState createState() => _AppointmentPageState();
// }
//
// class _AppointmentPageState extends State<AppointmentPage> {
//   List appointmentTypesDetails = [
//     {"title": "Online", "text": "Video Consultation", "imageUrl": "assets/images/online.png"},
//     {"title": "Offline", "text": "Clinic Visit", "imageUrl": "assets/images/offline.png"},
//     {"title": "EmergencyCall", "text": "Emergency Call", "imageUrl": "assets/images/offline.png"}
//   ];
//   bool _isLoading = false;
//   void initState() {
//     // TODO: implement initState
//     _checkStopBookingStatus();
//
//     appointmentTypesDetails[0]["price"] = widget.vspd;
//     appointmentTypesDetails[1]["price"] = widget.wspd;
//     appointmentTypesDetails[2]["price"] = "";
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // bottomNavigationBar: BottomNavigationStateWidget(
//         //   title: "Next",
//         //   onPressed: () {
//         //
//         //     // Navigator.pushNamed(context, "/ChooseTimeSlotPage",
//         //     //     arguments: ServiceScrArg(_serviceName, _serviceTimeMin,_openingTime,_closingTime));
//         //   },
//         //   clickable: _serviceName,
//         // ),
//         body: Stack(
//       clipBehavior: Clip.none,
//       children: <Widget>[
//
//         CAppBarWidget(title: "Book an appointment".tr), //common app bar
//         Positioned(
//             top: 80,
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child:
//                 //_stopBooking?showDialogBox():
//                 _isLoading
//                     ? Container(
//                         decoration: IBoxDecoration.upperBoxDecoration(),
//                         height: MediaQuery.of(context).size.height,
//                         child: LoadingIndicatorWidget())
//                     : _buildContent()),
//       ],
//     ));
//   }
//
//   Widget _buildContent() {
//     return Container(
//       height: MediaQuery.of(context).size.height,
//       decoration: IBoxDecoration.upperBoxDecoration(),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Padding(
//                 padding: const EdgeInsets.only(top: 10.0, left: 20, right: 10),
//                 child: Center(
//                     child: Text("What type of appointment".tr, style: kPageTitleStyle))),
//             _buildGridView(appointmentTypesDetails),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGridView(appointmentTypesDetails) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10.0, right: 10.0), // old value is 20 + hassan005004
//       child: MediaQuery.removePadding(
//         context: context,
//         removeTop: true,
//         child: Padding(
//           padding: const EdgeInsets.only(top: 10.0),
//           child: Container(
//             child: Wrap(
//               children: [
//                 _cardImg(appointmentTypesDetails[0], 1),
//                 _cardImg(appointmentTypesDetails[1], 2),
//                 _cardImg(appointmentTypesDetails[2], 3),
//               ],
//             ),
//           ),
//             // GridView.count(
//             //   physics: const ScrollPhysics(),
//             //   shrinkWrap: true,
//             //   childAspectRatio: .9,
//             //   crossAxisCount: 2,
//             //   children: List.generate(appointmentTypesDetails.length, (index) {
//             //     return _cardImg(appointmentTypesDetails[index], index + 1); //send type details and index with increment one
//             //   }),
//             // ),
//         )),
//     );
//   }
//
//   Widget _cardImg(
//     appointmentTypesDetails,
//     num num,
//   ) {
//     //  print(appointmentTypesDetails.day);
//     return GestureDetector(
//       onTap: () {
//         if(widget.walkinActive=="1"||widget.videoActive=="1") {
//           Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ChooseTimeSlotPage(
//               serviceName: appointmentTypesDetails["title"],
//               doctName: widget.doctName,
//               hospitalName: widget.hospitalName,
//               deptName: widget.deptName,
//               doctId: widget.doctId,
//               stopBooking: widget.stopBooking,
//               fee: widget.fee,
//               clinicId: widget.clinicId,
//               cityId: widget.cityId,
//               deptId: widget.deptId,
//               cityName: widget.cityName,
//               clinicName: widget.clinicName,
//                   wspd: widget.wspd,
//                   vspd: widget.vspd,
//                   payNowActive: widget.payNowActive,
//                   payLaterActive: widget.payLaterActive,
//             ),
//           ),
//         );
//         } else{
//           ToastMsg.showToastMsg("sorry doctor is not taking appointment".tr);
//         }
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.5 - 12,
//         height: MediaQuery.of(context).size.width * 0.5 - 12,
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           elevation: 5.0,
//           child: Stack(
//             clipBehavior: Clip.none,
//             // mainAxisAlignment: MainAxisAlignment.start,
//             // crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 bottom: 40,
//                 child: ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         topRight: Radius.circular(10)),
//                     child: Image.asset(
//                       appointmentTypesDetails['imageUrl'],
//                       fit: BoxFit.fill,
//                     ) //get images
//                     ),
//               ),
//               Positioned.fill(
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Container(
//                         width: double.infinity,
//                         height: 40,
//                         decoration: BoxDecoration(
//                             color: btnColor,
//                             borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(10),
//                                 bottomRight: Radius.circular(10))),
//                         child: Center(
//                           child: Text(
//                               "${appointmentTypesDetails['text']} ${appointmentTypesDetails['price']}",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontFamily: 'OpenSans-Bold',
//                                 fontSize: 12.0,
//                               )),
//                         ),
//                       )))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _checkStopBookingStatus() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final res = await ReadData.fetchSettings(); //fetch settings details
//     if (res != null){
//       // print(1);
//       // print(res["stopBooking"]);
//
//       if (res["stopBooking"] != false) {
//         // print("error 123");
//         // DialogBoxes.stopBookingAlertBox(context, "Sorry!".tr,
//         //     "We are currently not accepting new appointments. we will start soon"
//         //         .tr);
//       } else {
//         if (widget.stopBooking == "true") {
//           DialogBoxes.stopBookingAlertBox(context, "Sorry!".tr,
//               "${widget.doctName} " + "is not accepting new appointments".tr);
//         }
//       }
//   }
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }
