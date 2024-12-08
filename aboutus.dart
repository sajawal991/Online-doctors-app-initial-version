import 'package:demopatient/Screen/appointment/appointment.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/curverdpath.dart';
import 'package:demopatient/utilities/style.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:demopatient/widgets/callMsgWidget.dart';
import 'package:get/get.dart';

class AboutUs extends StatefulWidget {
  final doctId;
  final cityId;
  final cityName;
  final clinicId;

  AboutUs({Key? key, this.doctId, this.cityName, this.cityId, this.clinicId})
      : super(key: key);
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: DrProfileService.getDataByDrId(widget
                .doctId), //fetch doctors profile details like name, profileImage, description etc
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return snapshot.data.length == 0
                    ? NoDataWidget()
                    : _buildContent(snapshot.data[0]);
              } else if (snapshot.hasError) {
                return IErrorWidget();
              } else {
                return LoadingIndicatorWidget();
              } //loading page
            }));
  }

  Widget _buildContent(profile) {
    // print(profile.vspd.toString());
    return SingleChildScrollView(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      SizedBox(
        height: 200, // old value is 240 + hassan005004
        // color: Colors.yellowAccent,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            SizedBox(
              height: 150,
              width: MediaQuery.of(context).size.width,
              // color: Colors.red,
              child: CustomPaint(
                painter: CurvePainter(),
              ),
            ),
            Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: appBarIconColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      "Dr Profile".tr,
                      style: kAppbarTitleStyle,
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.home,
                          color: appBarIconColor,
                        ),
                        onPressed: () {
                          Navigator.popUntil(
                              context, ModalRoute.withName('/HomePage'));
                        })
                  ],
                )),
            Positioned(
              top: 80,
              left: 25,
              right: 25,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 100, // old value is 150 + hassan00504
                    width: 100,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: profile.profileImageUrl == ""
                            ? Image.asset("assets/icon/dprofile.png")
                            : ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                              child: ImageBoxFillWidget(
                                  imageUrl: profile
                                      .profileImageUrl),
                            ) //recommended image 200*200 pixel
                        ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 35),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          // child: Text("Contact us".tr,
                          //     //   "Dr ${profile.firstName} ${profile.lastName}",
                          //     //doctors first name and last name
                          //     style: const TextStyle(
                          //       color: Colors.black,
                          //       //change colors form here
                          //       fontFamily: 'OpenSans-Bold',
                          //       // change font style from here
                          //       fontSize: 15.0,
                          //     )),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.only(left: 15.0),
                        //   child: Text("",
                        //       //"jhdsvdsh",
                        //      // profile.subTitle,
                        //       //doctor subtitle
                        //       style: TextStyle(
                        //         color: Colors.black,
                        //         //change colors form here
                        //         fontFamily: 'OpenSans-Bold',
                        //         // change font style from here
                        //         fontSize: 15.0,
                        //       )),
                        // ),
                        FutureBuilder(
                            future: DrProfileService.checkInfoReveal(widget
                                .clinicId), //fetch images form database
                            builder: (context, AsyncSnapshot snapshot) {
                              // print(snapshot.data);
                              if (snapshot.hasData) {
                                if (snapshot.data == "error") {
                                  return const Text("");
                                } else if (snapshot.data['number_reveal'] ==
                                    "0") {
                                  return const Text("");
                                } else {
                                  // return CallMsgWidget(
                                  //   primaryNo: profile.pNo1,
                                  //   whatsAppNo: profile.whatsAppNo,
                                  //   email: profile.email,
                                  // );
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                            backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.zero,
                                                ))),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AppointmentPage(
                                                  doctId: profile.id,
                                                  deptName: profile.deptName,
                                                  hospitalName: profile.hName,
                                                  doctName: "Dr. ".tr +
                                                      profile.firstName +
                                                      " " +
                                                      profile.lastName,
                                                  stopBooking: profile.stopBooking,
                                                  fee: profile.fee,
                                                  clinicId: profile.clinicId,
                                                  cityId: widget.cityId,
                                                  deptId: profile.deptId,
                                                  cityName: widget.cityName,
                                                  clinicName: profile.clinicName,
                                                  payLaterActive: profile.payLater,
                                                  payNowActive: profile.payNow,
                                                  videoActive: profile.video_active,
                                                  walkinActive: profile.walkin_active,
                                                  vspd: profile.vspd,
                                                  wspd: profile.wspdp

                                              ),
                                            ),
                                          );
                                        },
                                        child: Text("Book Appointment".tr,
                                            style: const TextStyle(fontSize: 14))),
                                  );
                                }
                              } else if (snapshot.hasError) {
                                return const Text(
                                    "");
                              } else {
                                return LoadingIndicatorWidget();
                              }
                            }),

                        /*Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ))),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentPage(
                                      doctId: profile.id,
                                      deptName: profile.deptName,
                                      hospitalName: profile.hName,
                                      doctName: "Dr. ".tr +
                                          profile.firstName +
                                          " " +
                                          profile.lastName,
                                      stopBooking: profile.stopBooking,
                                      fee: profile.fee,
                                      clinicId: profile.clinicId,
                                      cityId: widget.cityId,
                                      deptId: profile.deptId,
                                      cityName: widget.cityName,
                                      clinicName: profile.clinicName,
                                        payLaterActive: profile.payLater,
                                        payNowActive: profile.payNow,
                                        videoActive: profile.video_active,
                                        walkinActive: profile.walkin_active,
                                        vspd: profile.vspd,
                                        wspd: profile.wspdp

                                    ),
                                  ),
                                );
                              },
                              child: Text("Book Appointment".tr,
                                  style: const TextStyle(fontSize: 14))),
                        )*/
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 25.0, right: 25, top: 10),
        child: Text(profile.description,
            //description of doctor profile
            style: kParaStyle),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8, left: 25.0, right: 25),
        child: Text("About".tr, style: kPageTitleStyle),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25, top: 8.0),
          child: Text(
            profile.aboutUs,
            style: kParaStyle,
          ))
    ],
      ),
    );
  }
}
