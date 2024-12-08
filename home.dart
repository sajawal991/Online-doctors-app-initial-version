import 'package:az_ui/helper/config.dart';
import 'package:az_ui/helper/extensions.dart';
import 'package:demopatient/Module/User/Provider/auth_provider.dart';
import 'package:demopatient/Screen/wallet_page.dart';
import 'package:demopatient/Service/Firebase/readData.dart';
import 'package:demopatient/Service/Noftification/handleFirebaseNotification.dart';
import 'package:demopatient/Service/Noftification/handleLocalNotification.dart';
import 'package:demopatient/controller/get_user_controller.dart';
import 'package:demopatient/helper/notify.dart';
import 'package:demopatient/utilities/dialogBox.dart';
import 'package:demopatient/utilities/style.dart';
import 'package:demopatient/Service/bannerService.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:flutter/material.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demopatient/widgets/drwaerWidgte.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Module/Doctor/Provider/DoctorProvider.dart';
import '../Module/Doctor/Screen/AppointmentConfirmationScreen.dart';
import '../Provider/doctor_provider.dart';
import '../Service/Apiservice/notification_services.dart';
import '../helper/widget.dart';
import '../utilities/color.dart';
import 'Invoice_list_screen.dart';
import 'appointment/ChatScreen.dart';
import 'appointment/appointment.dart';
import 'appointment/appointmentChatScreen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GetUserController _getUserController=Get.put(GetUserController(),tag: "wallet");

  String _uPhn = "";
  String _uId = "";
  bool _isLoading = false;
  NotificationServices services = NotificationServices();

  @override
  void initState() {
    services.notificationSettings();
    services.GetDeviceToken().then((value) => {

      // print('device token'),
      // print(value),
      // Utils().toastmessage(value.toString()),
    }).onError((error, stackTrace) => {
      // Utils().toastmessage(error.toString()),

    });
    services.IsDeviceTokenRefresh();
    services.Firebaseinit(context);
    services.SetUpInteractMessage(context);
    // TODO: implement initState
    // initialize local and firebase notification
    HandleLocalNotification.initializeFlutterNotification(context); //local notification
    HandleFirebaseNotification.handleNotifications(context); //firebase notification
    _getAndSetUserData(); //get users details from database
  //  _checkTechnicalIssueStatus(); //check show technical issue dialog box
    super.initState();


  }

  _getAndSetUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uPhn = prefs.getString("phone")!; // phn
    _uId = prefs.getString("uid")!;
    setState(() {

    });

    //start loading indicator
    // setState(() {
    //   _isLoading = true;
    // });
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // final phone = preferences.getString("phone") ?? "";
    // // final user = FirebaseAuth.instance.currentUser;
    // //  print("=======================${user.uid}===============");
    // final user = await UserService.getDataByPhn(phone);
    // // get all user details from database
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // //set all data
    // setState(() {
    //   _uId = user[0].uId!;
    //   _uPhn = user[0].pNo!;
    // });
    // // prefs.setString("firstName", user[0].firstName!);
    // // prefs.setString("lastName", user[0].lastName!);
    // prefs.setString("uid", user[0].uId!);
    // // prefs.setString("iuid", user[0].id??"");
    // // prefs.setString("uidp", user[0].id!);
    // // prefs.setString("imageUrl", user[0].imageUrl!);
    // prefs.setString("email", user[0].email!);
    // // prefs.setString("age", user[0].age!);
    // // prefs.setString("gender", user[0].gender!);
    // prefs.setString("city", user[0].city!);
    // prefs.setString("createdDate", user[0].createdDate!);
    // String fcm = "";
    // try {
    //   fcm = await FirebaseMessaging.instance.getToken() ?? "";
    //   await UserService.updateFcmId(user[0].uId!, fcm);
    // } catch (e) {
    //   debugPrint(e.toString());
    // }
    //
    // setState(() {
    //   _isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: IDrawer(phoneNum: _uPhn),
      bottomNavigationBar: bookAnAppointment(context),
      // BottomNavigationWidget(title: "Book an appointment".tr, route: "/CityListPage"),
      body: _isLoading
          ? LoadingIndicatorWidget()
          : Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                HAppBarWidget(
                  title: "Dr. Jyothi Kocherla",
                  uId: _uId,
                  getUserController: _getUserController,
                ),
                // AppBars()
                //     .homePageAppBar("My Clinic", _uPhn, _uName, _uId, context),
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: IBoxDecoration.upperBoxDecoration(),
                    child: FutureBuilder(
                        future: BannerImageService.getData(), //fetch banner image urls
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData)
                            return snapshot.data.length == 0
                                ? NoDataWidget()
                                : _buildContent(snapshot.data[0]);
                          else if (snapshot.hasError)
                            return IErrorWidget(); //if any error then you can also use any other widget here
                          else
                            return LoadingIndicatorWidget();
                        }),
                  ),
                ),

              ],
            ),
    );
  }

  Widget _table() {
    return Consumer<DoctorProvider>(
      builder: (context, provider, _) {
        return Table(
          children: [

            TableRow(
              children: [
                cardImgNew(context, "assets/icon/clinic-visit.png", "Book a Clinic Visit".tr, onTap: (){
                  Get.to(AppointmentPage(
                      doctId: provider.doctor!.id,
                      deptName: provider.doctor!.deptName,
                      hospitalName: provider.doctor!.hName,
                      doctName: provider.doctor!.firstName.toString() + " " + provider.doctor!.lastName.toString(),
                      stopBooking: provider.doctor!.stopBooking,
                      fee: provider.doctor!.fee,
                      clinicId: provider.doctor!.clinicId,
                      cityId: 1,
                      deptId: provider.doctor!.deptId,
                      cityName: 'city',
                      clinicName: provider.doctor!.clinicName,
                      payLaterActive: provider.doctor!.payLater,
                      payNowActive: provider.doctor!.payNow,
                      videoActive: provider.doctor!.video_active,
                      walkinActive: provider.doctor!.walkin_active,
                      vspd: provider.doctor!.vspd,
                      wspd: provider.doctor!.wspdp,
                      appointmentType: 1
                  ));
                }),
                cardImgNew(context, "assets/icon/video-consultation.png", "Video Consultation".tr, onTap: (){
                  Get.to(AppointmentPage(
                      doctId: provider.doctor!.id,
                      deptName: provider.doctor!.deptName,
                      hospitalName: provider.doctor!.hName,
                      doctName: provider.doctor!.firstName.toString() + " " + provider.doctor!.lastName.toString(),
                      stopBooking: provider.doctor!.stopBooking,
                      fee: provider.doctor!.videoConsultationFee,
                      clinicId: provider.doctor!.clinicId,
                      cityId: 1,
                      deptId: provider.doctor!.deptId,
                      cityName: 'city',
                      clinicName: provider.doctor!.clinicName,
                      payLaterActive: provider.doctor!.payLater,
                      payNowActive: provider.doctor!.payNow,
                      videoActive: provider.doctor!.video_active,
                      walkinActive: provider.doctor!.walkin_active,
                      vspd: provider.doctor!.vspd,
                      wspd: provider.doctor!.wspdp,
                      appointmentType: 0
                  ));
                }),

                cardImgNew(context, "assets/icon/emergency.png", "Emergency Call".tr, onTap: (){

                  if(provider.doctor?.emergencyCallEnable.toString() == "0"){
                    errorNotify("Emergence call not available at the moment");
                    return;
                  }

                  print(provider.doctor!.subTitle);
                  dynamic amount = provider.doctor!.emergencyCallCharges;
                  if(amount == null || amount == 'null'){
                    amount = '0';
                  }
                  Get.to(AppointmentConfirmationScreen(type: 3, serviceName: "Emergency Call", amount: double.parse(amount)));

                  return;


                  Get.to(AppointmentPage(
                      doctId: provider.doctor!.id,
                      deptName: provider.doctor!.deptName,
                      hospitalName: provider.doctor!.hName,
                      doctName: provider.doctor!.firstName.toString() + " " + provider.doctor!.lastName.toString(),
                      stopBooking: provider.doctor!.stopBooking,
                      fee: provider.doctor!.fee,
                      clinicId: provider.doctor!.clinicId,
                      cityId: 1,
                      deptId: provider.doctor!.deptId,
                      cityName: 'city',
                      clinicName: provider.doctor!.clinicName,
                      payLaterActive: provider.doctor!.payLater,
                      payNowActive: provider.doctor!.payNow,
                      videoActive: provider.doctor!.video_active,
                      walkinActive: provider.doctor!.walkin_active,
                      vspd: provider.doctor!.vspd,
                      wspd: provider.doctor!.wspdp,
                      appointmentType: 2
                  ));
                }),
              ]),

            TableRow(
              children: [
                _cardImg("assets/icon/appointments.png", "Appointment".tr, '/Appointmentstatus'),
                _cardImg('assets/icon/pill.png', 'Medicine Reminder'.tr, "/MedicineReminderPage"),
                _cardImg('assets/icon/reports.png', 'Reports'.tr, "/ReportListPage"),//CityListReachUsPage
              ]),

            TableRow(children: [
              cardImgNew(context, 'assets/icon/bills.png', 'Bills'.tr, onTap:(){
                Get.to(InvoiceListPage());
              }),
              _cardImg("assets/icon/prescription.png", "Prescription".tr, "/PrescriptionListPage"),
              cardImgNew(context, "assets/icon/chat.png", "Chat".tr, onTap: (){
                Get.to(ChatScreen(null,
                    provider.doctor!.id.toString(),
                    '${provider.doctor!.firstName} ${provider.doctor!.lastName}',
                    Provider.of<AuthProvider>(context, listen: false).activeUser.id.toString(),
                    _uId
                ));
              }),
              // _cardImg('assets/icon/bills.png', 'Bills'.tr, '/LabTestAppListPage'),
            ]),



            TableRow(children: [
              _cardImg('assets/icon/videos.png', 'Videos'.tr, "/VideoListPage"),
              // _cardImg("assets/icon/reachus.png", "Reach Us".tr, "/CityListReachUsPage"),
              GestureDetector(
                onTap: () async {
                  //provider.doctor!.firstName.toString()
                  try {
                    await launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${provider.doctor!.latLng.toString()}'));
                  } catch (e) {
                    print(e);
                  }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * .15,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0.0, // elevation old vale is 5 + hassan005004
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: Image.asset("assets/icon/reachus.png"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Reach Us".tr,
                            textAlign: TextAlign.center,
                            style: kTitleStyle,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              _cardImg("assets/icon/eye.png", "Eye Reminder".tr, "/EyeSafeReminderPage")
            ]),
            //

          ],
        );
      }
    );
  }


  Widget _cardImg(String path, String title, String routeName) {
    return GestureDetector(
      onTap: () async {
        //  Check.addData();
        // try{
        //   String fcm="";
        //   fcm=await FirebaseMessaging.instance.getToken();
        //   print(fcm);
        // }catch(e){}
        if (routeName != "null") {
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * .15,
        //width: MediaQuery.of(context).size.width * .1,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0, // elevation old vale is 5 + hassan005004
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 45,
                width: 45,
                child: Image.asset(path),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: kTitleStyle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _image(String imageUrl) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0, // old value is 5.0 + hsan 005004
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: ImageBoxFillWidget(imageUrl: imageUrl)),
    );
  }

  Widget _buildContent(bannerImages) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .3,
                width: MediaQuery.of(context).size.width,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0),
                    child: Container(
                        color: Colors.grey,
                        child: ImageBoxFillWidget(
                          imageUrl: bannerImages.banner1,
                        ) //recommended 200*300 pixel
                        )),
              ),
              Positioned(
                bottom:10,
                left:10,
                right:10,
                child: Consumer<AuthProvider>(
                  builder: (context, provider, _) {
                    if(provider.activeUser.latestNotification == null)
                      return SizedBox();
                    return Container(
                      child: Center(
                        child: Text(provider.activeUser.latestNotification!.body.toString())
                            .azText()
                            .color(Colors.white)
                            .textAlign(TextAlign.center)
                      ),
                    ).azContainer()
                        .radius(10)
                        .p(10)
                        .bg(appBarColor)
                        // .borderWidth(2)
                        // .borderColor(appBarColor)
                        // .borderFromLTRB(true, true, true, true)
                       ;
                  }
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10, top: 8.0), // left right old value is 20 + hassan005004
            child: Container(
              child: buildBalanceCard(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10, top: 8.0), // left right old value is 20 + hassan005004
            child: Container(
              child: _table(),
            ),
          ),
          /*Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10, top: 8.0), // left right old value is 20 + hassan005004
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * .2,
                    width: MediaQuery.of(context).size.width * .45,
                    child: _image(
                        bannerImages.banner2) //recommended size 200*200 pixel
                    //_image('assets/images/offer2.jpg'),
                    ),
                Expanded(
                  child: Container(
                      height: MediaQuery.of(context).size.height * .2,
                      width: MediaQuery.of(context).size.width * .45,
                      child: _image(
                          bannerImages.banner3) //recommended size 200*200 pixel
                      //_image('assets/images/offer3.jpeg'),
                      ),
                ),
              ],
            ),
          ),*/
          /*Padding(
            padding: const EdgeInsets.only(
                right: 10.0, left: 10, top: 8.0, bottom: 10.0),  // left right bottom old value is 20 + hassan005004
            child: Container(
                height: MediaQuery.of(context).size.height * .2,
                width: MediaQuery.of(context).size.width,
                child: _image(bannerImages.banner4) //recommended size 200*400 pixel
                ),
          ),*/
        ],
      ),
    );
  }

  void _checkTechnicalIssueStatus() async {
    final res = await ReadData.fetchSettings(); //fetch settings details
    if (res != null) {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        // String appName = packageInfo.appName;
        // String packageName = packageInfo.packageName;
        String version = packageInfo.version;
        // String buildNumber = packageInfo.buildNumber;
        // print(version);
        if (res["currentVersion"] != version) {
          if (!res["forceUpdate"]) {
            DialogBoxes.versionUpdateBox(context, "Update".tr, "update".tr,
                "New version is available, please update the app.".tr, () async {
              final _url =
                  "https://play.google.com/store/apps/details?id=";
              await canLaunchUrl(Uri.parse(_url))
                  ? await launchUrl(Uri.parse(_url))
                  : throw 'Could not launch $_url';
            });
          } else if (res["forceUpdate"]) {
            DialogBoxes.forceUpdateBox(context, "Update".tr, "update".tr,
                "Sorry we are currently not supporting the old version of the app please update with new version".tr,
                () async {
              final _url =
                  "https://play.google.com/store/apps/details?id=";
              await canLaunchUrl(Uri.parse(_url))
                  ? await launchUrl(Uri.parse(_url))
                  : throw 'Could not launch $_url';
            });
          }
        } else if (res["technicalIssue"]) {
          DialogBoxes.technicalIssueAlertBox(context, "Sorry!",
              "we are facing some technical issues. our team trying to solve problems. hope we will come back very soon.".tr);
        }
      });
    }
  }

  buildBalanceCard() {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WalletPage(getUserController: _getUserController)),
        );
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Color(0xFF414370),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20,10,20,5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded,color: Color(0xFF00CAFC),),
                      SizedBox(width: 5),
                      Text(
                          "Wallet Balance".tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "OpenSans-SemiBold"
                            // "OpenSans-SemiBold"
                          )),
                    ],
                  ),
                  Obx(() {
                    if (!_getUserController.isError.value) { // if no any error
                      if (_getUserController.isLoading.value) {
                        return const Text("\u{20B9}",style: TextStyle(
                            fontSize: 17,
                            color: Colors.white
                        ));
                      } else if (_getUserController.dataList.isEmpty) {
                        return  Text("\u{20B9}0",style: TextStyle(
                            fontSize: 17,
                            color: Colors.white
                        ));
                      } else {
                        return  Text("\u{20B9}${_getUserController.dataList[0].amount.toString()=="null"?
                        "0":_getUserController.dataList[0].amount.toString()
                        }",style: TextStyle(
                            fontSize: 17,
                            color: Colors.white
                        ));
                      }
                    }else {
                      return  Text("\u{20B9}",style: TextStyle(
                          fontSize: 17,
                          color: Colors.white
                      ));
                    } //Error svg
                  }),

                  // Container(
                  //   height: 2,
                  //   width: 100,
                  //   color: Color(0xFF00CAFC),
                  // ),

                  // Text("Health Check-Up: ${membershipModel[index].h}"),
                  // Text("Unit: ${membershipModel[index].packageUnit}",
                  //     style: TextStyle(
                  //         color: Color(0xFFACAAD3),
                  //         fontSize: 14,
                  //         fontFamily: "OpenSans-SemiBold"
                  //       // "OpenSans-SemiBold"
                  //     )),
                  //Text("Remark: ${membershipModel[index].remark}"),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
