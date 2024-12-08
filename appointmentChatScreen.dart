import 'package:demopatient/Screen/rebook/rebookChooseTimeSlot.dart';
import 'package:demopatient/Service/Apiservice/chatapi.dart';
import 'package:demopatient/Service/Firebase/readData.dart';
import 'package:demopatient/Service/appointmentService.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/style.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';

import 'package:flutter/material.dart';
import 'package:demopatient/Screen/appointment/appointmentDetailsPage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Module/User/Provider/auth_provider.dart';
import '../../Provider/notify_provider.dart';
import '../../config.dart';
import '../../utilities/decoration.dart';
import 'ChatScreen.dart';

import 'package:provider/provider.dart';

class AppointmentChatScreen extends StatefulWidget {
  AppointmentChatScreen({Key? key}) : super(key: key);

  @override
  _AppointmentChatScreenState createState() => _AppointmentChatScreenState();
}

class _AppointmentChatScreenState extends State<AppointmentChatScreen> {
  late final provider;

  bool isLoading = false;
  String uid = "";
  @override
  void initState() {
    getAndSetData();
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: isLoading
          ? LoadingIndicatorWidget()
          : Scaffold(
           appBar: AppBar(
            title: Text("Appointments".tr, style: kAppbarTitleStyle),
            centerTitle: true,
            backgroundColor: appBarColor,
            actions: [_appBarActionWidget()],
          ),
          body: AllAppointmentsList()
      ),
    );
  }

  Widget AllAppointmentsList() {
    // <1> Use FutureBuilder
    return FutureBuilder(
      // <2> Pass `Future<QuerySnapshot>` to future
        future: AppointmentService.getDataAll(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {

            return snapshot.data!.length == 0
                ? NoBookingWidget()
                : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return _card(snapshot.data, index, true);
                    }));
          } else if (snapshot.hasError) {
            return IErrorWidget();
          } else {
            return LoadingIndicatorWidget();
          }
        });
  }

  Widget _card(appointmentDetails, int index, bool isForUpcoming) {

    if(appointmentDetails[index].appointmentStatus == 'Canceled')
      return SizedBox.shrink();

    return GestureDetector(
      onTap: () async{
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => AppointmentDetailsPage(
        //         appointmentDetails: appointmentDetails[index]),
        //   ),
        // );

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>  ChatScreen(
                    null,//appointmentDetails[index],
                    appointmentDetails[index].doctId,
                    appointmentDetails[index].doctName,
                    Provider.of<AuthProvider>(context, listen: false).activeUser.id.toString(),
                    appointmentDetails[index].uId)
            )
        ).then((value) async => {
          provider = await Provider.of<NotifyProvider>(context, listen: false),
          provider.messageEmpty(),
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0,
        child: Container(
          // color: Colors.white,
          decoration: IBoxDecoration.newBoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _appointmentDate(
                  appointmentDetails[index].appointmentDate,
                ),
                // VerticalDivider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            Text("Time: ".tr,
                                style: TextStyle(
                                  fontFamily: 'OpenSans-Regular',
                                  fontSize: 12,
                                )),
                            Text(appointmentDetails[index].appointmentTime,
                                style: TextStyle(
                                  fontFamily: 'OpenSans-SemiBold',
                                  fontSize: 15,
                                )),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: Colors.grey[300])),
                            Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: appointmentDetails[index].appointmentStatus == "Pending"
                                    ? _statusIndicator(Colors.yellowAccent)
                                    : appointmentDetails[index].appointmentStatus ==
                                    "Rescheduled"
                                    ? _statusIndicator(Colors.orangeAccent)
                                    : appointmentDetails[index].appointmentStatus ==
                                    "Rejected"
                                    ? _statusIndicator(Colors.red)
                                    : appointmentDetails[index].appointmentStatus ==
                                    "Confirmed"
                                    ? _statusIndicator(Colors.green)
                                    : null),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                              child: Text(
                                appointmentDetails[index].appointmentStatus,
                                style: TextStyle(
                                  fontFamily: 'OpenSans-Regular',
                                  fontSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*Text(appointmentDetails[index].clinicName.toString() + "  " + appointmentDetails[index].cityName.toString(),
                                    style: TextStyle(
                                      fontFamily: 'OpenSans-Regular',
                                      fontSize: 12,
                                    )),*/
                                Text(appointmentDetails[index].doctName,
                                    style: TextStyle(
                                      fontFamily: 'OpenSans-Regular',
                                      fontSize: 12,
                                    )),
                                Text(
                                    appointmentDetails[index].serviceName ==
                                        "Online"
                                        ? "Video Consultation".tr
                                        : "Hospital Visit".tr,
                                    style: TextStyle(
                                      fontFamily: 'OpenSans-SemiBold',
                                      fontSize: 15,
                                    )),
                              ],
                            ),
                            // appointmentDetails[index].AppointmentChatScreen=="Visited"?
                            isForUpcoming
                                ? Container()
                                : appointmentDetails[index].walkin == "1"
                                ? Container()
                                : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: btnColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(5.0)),
                                ),
                                child: Center(
                                    child: Text("Rebook".tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ))),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RebookChooseTimeSlotPage(
                                            serviceName:
                                            appointmentDetails[index]
                                                .serviceName,
                                            serviceTimeMin:
                                            appointmentDetails[index]
                                                .serviceTimeMin
                                                .toString(),
                                            doctName:
                                            appointmentDetails[index]
                                                .doctName,
                                            hospitalName:
                                            appointmentDetails[index]
                                                .hName,
                                            deptName:
                                            appointmentDetails[index]
                                                .department,
                                            doctId: appointmentDetails[index]
                                                .doctId,
                                            clinicId:
                                            appointmentDetails[index]
                                                .clinicId,
                                            cityId: appointmentDetails[index]
                                                .cityId,
                                            deptId: appointmentDetails[index]
                                                .deptId,
                                            cityName:
                                            appointmentDetails[index]
                                                .cityName,
                                            clinicName:
                                            appointmentDetails[index]
                                                .clinicName,
                                          ),
                                    ),
                                  );
                                })
                            //:Container(),
                          ],
                        ),
                        FutureBuilder(
                            future: AppointmentService.getTokenByAppId(
                                appointmentDetails[index].id.toString()),
                            builder: (context, AsyncSnapshot snapshot) {
                              return !snapshot.hasData
                                  ? Container()
                                  : Padding(
                                padding: const EdgeInsets.only(top:8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /*InkWell(
                                      onTap:(){
                                        // print(appointmentDetails[index].id.toString());

                                        ChatApi().download('$apiUrlLaravel/patient/appointment/invoice?appointment_id=${appointmentDetails[index]
                                            .id.toString()}','MyDoctorjo_voice.pdf');

                                        Get.snackbar('Download PDF', 'Invoice has been downloaded',duration: Duration(seconds: 10));

                                      },
                                      child: Text(
                                        "Download PDF".tr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: appBarColor),
                                      ),
                                    ),*/
                                    /*Text(
                                      snapshot.data.length == 0
                                          ? "Token Not Issued".tr
                                          : snapshot.data[0].tokenType == "0"
                                          ? "Token A - ${snapshot.data[0].tokenNum}"
                                          : "Token W - ${snapshot.data[0].tokenNum}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: appBarColor),
                                    ),*/
                                  ],
                                ),
                              );
                            })
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appointmentDate(date) {
    var appointmentDate = date.split("-");
    var appointmentMonth;
    switch (appointmentDate[0]) {
      case "1":
        appointmentMonth = "JAN";
        break;
      case "2":
        appointmentMonth = "FEB";
        break;
      case "3":
        appointmentMonth = "MARCH";
        break;
      case "4":
        appointmentMonth = "APRIL";
        break;
      case "5":
        appointmentMonth = "MAY";
        break;
      case "6":
        appointmentMonth = "JUN";
        break;
      case "7":
        appointmentMonth = "JULY";
        break;
      case "8":
        appointmentMonth = "AUG";
        break;
      case "9":
        appointmentMonth = "SEP";
        break;
      case "10":
        appointmentMonth = "OCT";
        break;
      case "11":
        appointmentMonth = "NOV";
        break;
      case "12":
        appointmentMonth = "DEC";
        break;
    }

    return Column(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(appointmentMonth,
            style: const TextStyle(
              fontFamily: 'OpenSans-SemiBold',
              fontSize: 15,
            )),
        Text(appointmentDate[1],
            style: TextStyle(
              fontFamily: 'OpenSans-SemiBold',
              color: btnColor,
              fontSize: 35,
            )),
        Text(appointmentDate[2],
            style: const TextStyle(
              fontFamily: 'OpenSans-SemiBold',
              fontSize: 15,
            )),
      ],
    );
  }

  Widget _statusIndicator(color) {
    return CircleAvatar(radius: 4, backgroundColor: color);
  }

  Widget _appBarActionWidget() {
    return StreamBuilder(
        stream: ReadData.fetchNotificationDotStatus(uid),
        builder: (context, AsyncSnapshot snapshot) {
          return !snapshot.hasData
              ? Container()
              : IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.notifications, color: appBarIconColor),
                  snapshot.data["isAnyNotification"]
                      ? const Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 5,
                    ),
                  )
                      : Positioned(top: 0, right: 0, child: Container())
                ],
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/NotificationPage",
                );
              }
            //

          );
        });
  }

  void getAndSetData() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    uid = preferences.getString("uid") ?? "";
    setState(() {
      isLoading = false;
    });
  }
}
