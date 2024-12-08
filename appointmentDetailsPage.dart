import 'package:demopatient/Screen/resch/reSchTimeSlotPage.dart';
import 'package:demopatient/Screen/prescription/prescriptionListByIdPage.dart';
import 'package:demopatient/Screen/resch/walkInReschPage.dart';
import 'package:demopatient/Service/Firebase/updateData.dart';
import 'package:demopatient/Service/Noftification/handleFirebaseNotification.dart';
import 'package:demopatient/Service/Noftification/handleLocalNotification.dart';
import 'package:demopatient/Service/appointmentService.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/Service/notificationService.dart';
import 'package:demopatient/Screen/jitscVideoCall.dart';
import 'package:demopatient/Service/userService.dart';
import 'package:demopatient/model/appointmentModel.dart';
import 'package:demopatient/model/notificationModel.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/dialogBox.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Module/User/Provider/auth_provider.dart';
import '../../Provider/notify_provider.dart';
import '../../helper/helper.dart';
import 'ChatScreen.dart';
class AppointmentDetailsPage extends StatefulWidget {
  final AppointmentModel? appointmentDetails;

  const AppointmentDetailsPage({Key? key, this.appointmentDetails})
      : super(key: key);
  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late final provider;

  String _adminFCMid = "";
  String doctorFcm = "";
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _latsNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _phnController = TextEditingController();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _serviceNameController = TextEditingController();
  TextEditingController _serviceName2 = TextEditingController();

  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _serviceTimeController = TextEditingController();
  final TextEditingController _appointmentIdController = TextEditingController();
  final TextEditingController _uIdController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _createdDateTimeController = TextEditingController();
  final TextEditingController _doctNameController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _hnameController = TextEditingController();
  final TextEditingController _lastUpdatedController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _paymentStatusController = TextEditingController();
  final TextEditingController _amountCont = TextEditingController();
  final TextEditingController _paymentModeCont = TextEditingController();
  final TextEditingController _paymentDateController = TextEditingController();
  final TextEditingController _appointmentStatusCont = TextEditingController();
  final TextEditingController _gmeetLinkCont = TextEditingController();
  final TextEditingController _cityName = TextEditingController();
  final TextEditingController _clinicName = TextEditingController();
  final TextEditingController _mrdController = TextEditingController();
  final TextEditingController _tokenNumberController = TextEditingController();
  String _isBtnDisable = "false";
  bool _isLoading = false;
  String vby = "0";

  @override
  void initState() {
    // TODO: implement initState
    getAndSetData();
    super.initState();
    vby = widget.appointmentDetails!.vByUser.toString();
    _firstNameController.text = widget.appointmentDetails!.pFirstName;
    _latsNameController.text = widget.appointmentDetails!.pLastName;
    _ageController.text = widget.appointmentDetails!.age;
    _cityController.text = widget.appointmentDetails!.pCity;
    _emailController.text = widget.appointmentDetails!.pEmail;
    _phnController.text = widget.appointmentDetails!.pPhn;
    _dateController.text = widget.appointmentDetails!.appointmentDate;
    _timeController.text = widget.appointmentDetails!.appointmentTime;
    _serviceNameController.text = widget.appointmentDetails!.serviceName;
    _serviceNameController.text = widget.appointmentDetails!.serviceName;
    _serviceName2.text = widget.appointmentDetails!.serviceName == "Online"
        ? "Video Consultation".tr
        : "Hospital Visit".tr;
    _serviceTimeController.text =
        (widget.appointmentDetails!.serviceTimeMin).toString();
    _appointmentIdController.text = widget.appointmentDetails!.id;
    _uIdController.text = widget.appointmentDetails!.uId; //firebase user id
    _descController.text = widget.appointmentDetails!.description;
    _createdDateTimeController.text =
        widget.appointmentDetails!.createdTimeStamp;
    _lastUpdatedController.text = widget.appointmentDetails!.updatedTimeStamp;
    _statusController.text = widget.appointmentDetails!.appointmentStatus;

    _doctNameController.text = widget.appointmentDetails!.doctName;
    _deptController.text = widget.appointmentDetails!.department;
    _hnameController.text = widget.appointmentDetails!.hName;
    _cityName.text = widget.appointmentDetails!.cityName.toString();
    _clinicName.text = widget.appointmentDetails!.clinicName.toString();;

    if (widget.appointmentDetails!.appointmentStatus == "Rejected" ||
        widget.appointmentDetails!.appointmentStatus == "Canceled") {
      setState(() {
        _isBtnDisable = "";
      });
    }
    _paymentStatusController.text = widget.appointmentDetails!.paymentStatus;
    _paymentDateController.text = widget.appointmentDetails!.paymentDate;
    _orderIdController.text = widget.appointmentDetails!.oderId;
    _amountCont.text = '₹ ' + widget.appointmentDetails!.amount;
    _paymentModeCont.text = capitalizeFirstLetter(widget.appointmentDetails!.paymentMode);
    if (widget.appointmentDetails!.gMeetLink != null &&
        widget.appointmentDetails!.gMeetLink != "")
      _gmeetLinkCont.text = widget.appointmentDetails!.gMeetLink;
    else
      _gmeetLinkCont.text =
          "Please wait, Doctor will update the Google Meet link very soon";
    if (widget.appointmentDetails!.isOnline == "true" &&
        widget.appointmentDetails!.isOnline != null &&
        widget.appointmentDetails!.isOnline != "")
      _appointmentStatusCont.text = "Online";
    else
      _appointmentStatusCont.text = "Offline";

    if (widget.appointmentDetails!.appointmentStatus == "Rejected" ||
        widget.appointmentDetails!.appointmentStatus == "Canceled" ||
        widget.appointmentDetails!.paymentStatus == "SUCCESS") {
      setState(() {
        _isBtnDisable = "";
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    _firstNameController.dispose();
    _latsNameController.dispose();
    _phnController.dispose();
    _emailController.dispose();
    _serviceNameController.dispose();
    _serviceTimeController.dispose();
    _appointmentIdController.dispose();
    _uIdController.dispose();
    _descController.dispose();
    _deptController.dispose();
    _doctNameController.dispose();
    _hnameController.dispose();
    _orderIdController.dispose();
    _paymentDateController.dispose();
    _paymentStatusController.dispose();
    _paymentModeCont.dispose();
    _orderIdController.dispose();
    _amountCont.dispose();
    _appointmentStatusCont.dispose();
    _gmeetLinkCont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: widget.appointmentDetails!.appointmentStatus ==
                "Visited"
            ? BottomNavigationStateWidget(
                title: "Get Prescription".tr,
                onPressed: _handlePrescription,
                clickable: _isBtnDisable)
            : BottomNavigationTwoWidget(
                onTap:
                    widget.appointmentDetails!.appointmentStatus == "Canceled"
                        ? null
                        : () {
                            _takeConfirmation();
                          },
                title: "Cancel".tr,
                title2: "Reschedule".tr,
                onTap2: widget.appointmentDetails!.appointmentStatus ==
                        "Canceled"
                    ? null
                    : () {
                        if (widget.appointmentDetails!.walkin == "1") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalkinReschTimeSlotPage(
                                appDate:
                                    widget.appointmentDetails!.appointmentDate,
                                appId: widget.appointmentDetails!.id,
                                ageController: widget.appointmentDetails!.age,
                                cityController:
                                    widget.appointmentDetails!.pCity,
                                desController:
                                    widget.appointmentDetails!.description,
                                emailController:
                                    widget.appointmentDetails!.pEmail,
                                firstNameController:
                                    widget.appointmentDetails!.pFirstName,
                                lastNameController:
                                    widget.appointmentDetails!.pLastName,
                                phoneNumberController:
                                    widget.appointmentDetails!.pPhn,
                                selectedGender:
                                    widget.appointmentDetails!.gender,
                                serviceName:
                                    widget.appointmentDetails!.serviceName,
                                serviceTimeMin: int.parse(widget
                                    .appointmentDetails!.serviceTimeMin
                                    .toString()),
                                doctName: widget.appointmentDetails!.doctName,
                                hospitalName: widget.appointmentDetails!.hName,
                                deptName: widget.appointmentDetails!.department,
                                doctId: widget.appointmentDetails!.doctId,
                                clinicId: widget.appointmentDetails!.clinicId,
                                cityId: widget.appointmentDetails!.cityId,
                                deptId: widget.appointmentDetails!.deptId,
                                cityName: widget.appointmentDetails!.cityName,
                                clinicName:
                                    widget.appointmentDetails!.clinicName,
                              ),
                            ),
                          );
                        } else {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReschTimeSlotPage(
                                appDate:
                                    widget.appointmentDetails!.appointmentDate,
                                appId: widget.appointmentDetails!.id,
                                ageController: widget.appointmentDetails!.age,
                                cityController:
                                    widget.appointmentDetails!.pCity,
                                desController:
                                    widget.appointmentDetails!.description,
                                emailController:
                                    widget.appointmentDetails!.pEmail,
                                firstNameController:
                                    widget.appointmentDetails!.pFirstName,
                                lastNameController:
                                    widget.appointmentDetails!.pLastName,
                                phoneNumberController:
                                    widget.appointmentDetails!.pPhn,
                                selectedGender:
                                    widget.appointmentDetails!.gender,
                                serviceName:
                                    widget.appointmentDetails!.serviceName,
                                serviceTimeMin: int.parse(widget
                                    .appointmentDetails!.serviceTimeMin
                                    .toString()),
                                doctName: widget.appointmentDetails!.doctName,
                                hospitalName: widget.appointmentDetails!.hName,
                                deptName: widget.appointmentDetails!.department,
                                doctId: widget.appointmentDetails!.doctId,
                                clinicId: widget.appointmentDetails!.clinicId,
                                cityId: widget.appointmentDetails!.cityId,
                                deptId: widget.appointmentDetails!.deptId,
                                cityName: widget.appointmentDetails!.cityName,
                                clinicName:
                                    widget.appointmentDetails!.clinicName,
                              ),
                            ),
                          );
                        }
                      }
                      ),
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CAppBarWidget(
              title: "Appointment Details".tr,
            ),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                // decoration: BoxDecoration(
                //     color: bgColor,
                //     borderRadius: BorderRadius.only(
                //         topLeft: Radius.circular(10),
                //         topRight: Radius.circular(10))),
                child: _isLoading
                    ? LoadingIndicatorWidget()
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 0.0, bottom: 10.0, left: 5, right: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // _appointmentStatusCont.text == "Online"
                              //     ? GestureDetector(
                              //         onTap: () {
                              //           print(widget.appointmentDetails!.uId);
                              //           print(
                              //               widget.appointmentDetails!.doctId);
                              //           print(
                              //               widget.appointmentDetails!.pEmail);
                              //           Navigator.push(
                              //             context,
                              //             MaterialPageRoute(
                              //                 builder: (context) => Meeting(
                              //                       uid: widget
                              //                           .appointmentDetails!
                              //                           .uId,
                              //                       doctid: widget
                              //                           .appointmentDetails!
                              //                           .doctId,
                              //                       email: widget
                              //                           .appointmentDetails!
                              //                           .pEmail,
                              //                     )),
                              //           );
                              //         },
                              //         child: Container(
                              //           decoration: BoxDecoration(
                              //             borderRadius:
                              //                 BorderRadius.circular(10),
                              //             color: Colors.green,
                              //           ),
                              //           child: Padding(
                              //             padding: const EdgeInsets.fromLTRB(
                              //                 40, 10, 40, 10),
                              //             child: Text(
                              //               "Call To Doctor".tr,
                              //               style: TextStyle(
                              //                   fontFamily: "OpenSans-SemiBold",
                              //                   color: Colors.white),
                              //             ),
                              //           ),
                              //         ),
                              //       )
                              //     : Container(),
                              // SizedBox(height: 10),


                              // GestureDetector(
                              //   onTap: () {
                              //     print(widget.appointmentDetails!.uId);
                              //     print(
                              //         widget.appointmentDetails!.doctId);
                              //     print(
                              //         widget.appointmentDetails!.pEmail);
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) => ChatPage(
                              //             uid: widget
                              //                 .appointmentDetails!
                              //                 .uId,
                              //             doctid: widget
                              //                 .appointmentDetails!
                              //                 .doctId,
                              //             email: widget
                              //                 .appointmentDetails!
                              //                 .pEmail,
                              //           )),
                              //     );
                              //   },
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       borderRadius:
                              //       BorderRadius.circular(10),
                              //       color: Colors.green,
                              //     ),
                              //     child: Padding(
                              //       padding: const EdgeInsets.fromLTRB(
                              //           40, 10, 40, 10),
                              //       child: Text(
                              //         "Chat With Doctor".tr,
                              //         style: TextStyle(
                              //             fontFamily: "OpenSans-SemiBold",
                              //             color: Colors.white),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              //
                              // SizedBox(height: 10),
                              //
                              // GestureDetector(
                              //   onTap: () {
                              //     print(widget.appointmentDetails!.uId);
                              //     print(widget.appointmentDetails!.id);
                              //     print(widget.appointmentDetails!.doctId);
                              //     print(widget.appointmentDetails!.pEmail);
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) =>  ChatScreen((widget.appointmentDetails))
                              //     )
                              //     );
                              //   },
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       borderRadius:
                              //       BorderRadius.circular(10),
                              //       color: Colors.green,
                              //     ),
                              //     child: Padding(
                              //       padding: const EdgeInsets.fromLTRB(
                              //           40, 10, 40, 10),
                              //       child: Text(
                              //         "Chat With Doctor new".tr,
                              //         style: TextStyle(
                              //             fontFamily: "OpenSans-SemiBold",
                              //             color: Colors.white),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(height: 10,),

                              if(widget.appointmentDetails!.appointmentStatus != 'Canceled')
                              Padding(
                                padding: const EdgeInsets.only(top:10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>  ChatScreen(
                                                null, //widget.appointmentDetails,
                                                widget.appointmentDetails!.doctId,
                                                widget.appointmentDetails!.doctName,
                                                Provider.of<AuthProvider>(context, listen: false).activeUser.id.toString(),
                                                widget.appointmentDetails!.uId
                                            )
                                        )
                                    ).then((value) async => {
                                      provider = await Provider.of<NotifyProvider>(context, listen: false),
                                      provider.messageEmpty(),
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(50),
                                      color: btnColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          40, 10, 40, 10),
                                      child: Text(
                                        "Contact the Doctor".tr,
                                        style: TextStyle(
                                            fontFamily: "OpenSans-SemiBold",
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // SizedBox(height: 20),

                              _inputTextField("MRD", _mrdController, 1),
                              _inputTextField(
                                  "First Name".tr, _firstNameController, 1),
                              _inputTextField(
                                  "Last Name".tr, _latsNameController, 1),
                              widget.appointmentDetails!.oderId == ""
                                  ? Container()
                                  : _inputTextField("Amount".tr, _amountCont, 1),
                              widget.appointmentDetails!.oderId == ""
                                  ? Container()
                                  : _inputTextField("Payment Mode".tr, _paymentModeCont, 1),
                              widget.appointmentDetails!.oderId == ""
                                  ? Container()
                                  : _inputTextField("Payment Id".tr, _orderIdController, 1),
                              _inputTextField("Payment Status".tr, _paymentStatusController, 1),
                              widget.appointmentDetails!.oderId == ""
                                  ? Container()
                                  : _inputTextField("Payment Date".tr, _paymentDateController, 1),
                              _inputTextField("Age".tr, _ageController, 1),
                              _inputTextField("Appointment Status".tr, _statusController, 1),
                              _inputTextField("Phone Number".tr, _phnController, 1),
                              _inputTextField("City".tr, _cityController, 1),
                              _inputTextField("Email".tr, _emailController, 1),
                              _inputTextField("Appointment Date".tr, _dateController, 1),
                              _inputTextField("Appointment Time".tr, _timeController, 1),
                              // _inputTextField("Appointment Minute",
                              //     _serviceTimeController, 1),
                              _inputTextField("Token".tr, _tokenNumberController, 1),
                              _inputTextField("Doctor Name".tr, _doctNameController, 1),
                              _inputTextField("Service Name".tr, _serviceName2, 1),
                              // _inputTextField("Clinic Name".tr, _clinicName, 1),
                              // _inputTextField("Clinic City".tr, _cityName, 1),
                              _inputTextField("Department".tr, _deptController, 1),
                              // _inputTextField("Hospital".tr, _hnameController, null),
                              _inputTextField("Appointment ID".tr, _appointmentIdController, 1),
                              _inputTextField("User ID".tr, _uIdController, 1),
                              _inputTextField("Created on".tr, _createdDateTimeController, 1),
                              _inputTextField("Last update on".tr, _lastUpdatedController, 1),
                              _inputTextField("Description, About your problem".tr, _descController, null),
                              widget.appointmentDetails!.appointmentStatus ==
                                      "Visited"
                                  ? _markedByUserWidget(vby)
                                  : Container()
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        )
    );
  }

  _handlePrescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PrescriptionListByIDPage(
              appointmentId: widget.appointmentDetails!.id)),
    );
  }

  Widget _inputTextField(String labelText, controller, maxLine) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),// left and right old value is 20 + top old value is 10 + hassan005004
      child: TextFormField(
        maxLines: maxLine,
        readOnly: true,
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            // prefixIcon:Icon(Icons.,),
            labelText: labelText,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
            )),
      ),
    );
  }

  void _handleCancelBtn() async {
    setState(() {
      _isBtnDisable = "";
      _isLoading = true;
    });
    // final res = await DeleteData.deleteBookedAppointment(
    //   widget.appointmentDetails!.id,
    //   widget.appointmentDetails!.appointmentDate,
    //   widget.appointmentDetails!.doctId,
    // );
    // if (res == "success") {
    final appointmentModel = AppointmentModel(
        id: widget.appointmentDetails!.id, appointmentStatus: "Canceled");
    final isUpdated = await AppointmentService.updateStatus(appointmentModel);
    if (isUpdated == "success") {
      final notificationModel = NotificationModel(
          title: "Canceled!",
          body:
              "Appointment has been canceled for date ${widget.appointmentDetails!.appointmentDate}. appointment id: ${widget.appointmentDetails!.id}",
          uId: widget.appointmentDetails!.uId,
          routeTo: "/Appointmentstatus",
          sendBy: "user",
          sendFrom:
              "${widget.appointmentDetails!.pFirstName} ${widget.appointmentDetails!.pLastName}",
          sendTo: "Admin");
      final notificationModelForAdmin = NotificationModel(
          title: "Canceled Appointment!",
          body:
              "${widget.appointmentDetails!.pFirstName} ${widget.appointmentDetails!.pLastName} has canceled appointment for date ${widget.appointmentDetails!.appointmentDate}. appointment id: ${widget.appointmentDetails!.id}", //body
          uId: widget.appointmentDetails!.uId,
          sendBy:
              "${widget.appointmentDetails!.pFirstName} ${widget.appointmentDetails!.pLastName}",
          doctId: widget.appointmentDetails!.doctId);
      await NotificationService.addData(notificationModel);
      await NotificationService.addDataForAdmin(notificationModelForAdmin);
      _handleSendNotification();
    } else {
      ToastMsg.showToastMsg("Something went wrong".tr);
    }
    // } else {
    //   ToastMsg.showToastMsg("Something went wrong");
    // }
    setState(() {
      _isBtnDisable = "false";
      _isLoading = false;
    });
  }

  void _handleSendNotification() async {
    await _setAdminFcmId(widget.appointmentDetails!.doctId);
    //send local notification

    await HandleLocalNotification.showNotification(
      "Canceled",
      "Appointment has been canceled for date ${widget.appointmentDetails!.appointmentDate}", // body
    );
    await UpdateData.updateIsAnyNotification(
        "usersList", widget.appointmentDetails!.uId, true);

    //send notification to admin app for booking confirmation
    await HandleFirebaseNotification.sendPushMessage(
        _adminFCMid, //admin fcm
        "Canceled Appointment", //title
        "${widget.appointmentDetails!.pFirstName} ${widget.appointmentDetails!.pLastName} has canceled appointment for date ${widget.appointmentDetails!.appointmentDate}. appointment id: ${widget.appointmentDetails!.id}" //body
        );
    await HandleFirebaseNotification.sendPushMessage(
        doctorFcm, //admin fcm
        "Canceled Appointment", //title
        "${widget.appointmentDetails!.pFirstName} ${widget.appointmentDetails!.pLastName} has canceled appointment for date ${widget.appointmentDetails!.appointmentDate}. appointment id: ${widget.appointmentDetails!.id}" //body
        );
    print(
        "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&${widget.appointmentDetails!.doctId}");
    await UpdateData.updateIsAnyNotification(
        "doctorsNoti", widget.appointmentDetails!.doctId, true);
    await UpdateData.updateIsAnyNotification("profile", "profile", true);
    ToastMsg.showToastMsg("Successfully Canceled".tr);
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/Appointmentstatus', ModalRoute.withName('/HomePage'));
  }

  Future<String> _setAdminFcmId(doctId) async {
    //loading if data till data fetched
    setState(() {
      _isLoading = true;
    });
    final res = await DrProfileService
        .getData(); //fetch admin fcm id for sending messages to admin
    if (res.isNotEmpty) {
      setState(() {
        _adminFCMid = res[0].fdmId ?? "";
      });
    }
    final res2 = await DrProfileService.getDataByDrId(
        doctId); //fetch admin fcm id for sending messages to admin
    if (res2.isNotEmpty) {
      setState(() {
        doctorFcm = res2[0].fdmId ?? "";
      });
    }
    setState(() {
      _isLoading = false;
    });
    return "";
  }

  _takeConfirmation() {
    DialogBoxes.confirmationBox(context, "Cancel".tr, "Are you sure want to cancel appointment".tr, _handleCancelBtn);
  }

  void getAndSetData() async {
    setState(() {
      _isBtnDisable = "";
      _isLoading = true;
    });
    final res = await UserService.getUserById(widget.appointmentDetails!.uId);
    if (res.length > 0) {
      _mrdController.text = res[0].mrd == null ? "" : res[0].mrd;
    }
    final tokenNumRes = await AppointmentService.getTokenByAppId(
        widget.appointmentDetails!.id.toString());
    if (tokenNumRes.isNotEmpty) {
      final tokentYpe = tokenNumRes[0].tokenType == "0" ? "A-" : "W-";
      _tokenNumberController.text =
          tokentYpe.toString() + tokenNumRes[0].tokenNum.toString();
    } else {
      _tokenNumberController.text = "Token Not Issued";
    }
    setState(() {
      _isBtnDisable = "false";
      _isLoading = false;
    });
  }

  Widget _markedByUserWidget(data) {
    return ListTile(
      title: Text("Doctor Visit".tr),
      subtitle: data == "0"
          ? Text("Mark Visited By Doctor".tr)
          : Text("Visited By Doctor".tr),
      trailing: IconButton(
        icon: data == "1"
            ? const Icon(
                Icons.toggle_on_outlined,
                color: Colors.green,
                size: 35,
              )
            : const Icon(
                Icons.toggle_off_outlined,
                color: Colors.red,
                size: 35,
              ),
        onPressed: _isLoading
            ? null
            : () {
                if (vby == "1") {
                  ToastMsg.showToastMsg("Already visited by doctor".tr);
                } else {
                  handlUpdatedVBU();
                }
              },
      ),
    );
  }

  void handlUpdatedVBU() async {
    setState(() {
      _isLoading = true;
    });
    final res = await AppointmentService.updateDataVBY(
        widget.appointmentDetails!.id.toString(), "1");
    if (res == "success") {
      ToastMsg.showToastMsg("Success".tr);
      setState(() {
        vby = "1";
      });
    } else {
      ToastMsg.showToastMsg("Something went wrong".tr);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
