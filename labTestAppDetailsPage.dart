import 'package:demopatient/Service/Firebase/updateData.dart';
import 'package:demopatient/Service/Noftification/handleFirebaseNotification.dart';
import 'package:demopatient/Service/Noftification/handleLocalNotification.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/Service/lab_test_app_service.dart';
import 'package:demopatient/Service/notificationService.dart';
import 'package:demopatient/model/lab_test_app_model.dart';
import 'package:demopatient/model/notificationModel.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/dialogBox.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class LabTestAppDetailsPage extends StatefulWidget {
  final LabTestAppModel? appointmentDetails;

  const LabTestAppDetailsPage({Key? key, this.appointmentDetails})
      : super(key: key);
  @override
  _LabTestAppDetailsPageState createState() => _LabTestAppDetailsPageState();
}

class _LabTestAppDetailsPageState extends State<LabTestAppDetailsPage> {
  String _adminFCMid = "";
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _phnController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _serviceNameController = TextEditingController();
  TextEditingController _statusController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _createdDateTimeController = TextEditingController();
  TextEditingController _paymentStatusController = TextEditingController();
  TextEditingController _amountCont = TextEditingController();
  TextEditingController _appointmentStatusCont = TextEditingController();
  TextEditingController _cityName = TextEditingController();
  TextEditingController _clinicName = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firstNameController.text = widget.appointmentDetails!.pName;
    _ageController.text = widget.appointmentDetails!.pAge;
    _cityController.text = widget.appointmentDetails!.pCity;
    _emailController.text = widget.appointmentDetails!.pEmail;
    _phnController.text = widget.appointmentDetails!.pPhn;
    _serviceNameController.text = widget.appointmentDetails!.serviceName;
    _descController.text = widget.appointmentDetails!.pDesc;
    _createdDateTimeController.text =
        widget.appointmentDetails!.createdTimeStamp;
    if (widget.appointmentDetails!.status == "0")
      _statusController.text = "Pending".tr;
    else if (widget.appointmentDetails!.status == "1")
      _statusController.text = "Confirmed";
    else if (widget.appointmentDetails!.status == "2")
      _statusController.text = "Visited".tr;
    else if (widget.appointmentDetails!.status == "3")
      _statusController.text = "Canceled".tr;
    _cityName.text = widget.appointmentDetails!.pCity;
    _clinicName.text = widget.appointmentDetails!.clinicName;

    _paymentStatusController.text = widget.appointmentDetails!.pymentStatus;
    _amountCont.text = widget.appointmentDetails!.paymentAmount + '\u{20B9}';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _cityController.dispose();
    _ageController.dispose();
    _firstNameController.dispose();
    _phnController.dispose();
    _emailController.dispose();
    _serviceNameController.dispose();
    _descController.dispose();
    _paymentStatusController.dispose();
    _amountCont.dispose();
    _appointmentStatusCont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: widget.appointmentDetails!.status == "0" ||
                widget.appointmentDetails!.status == "1"
            ? BottomNavigationStateWidget(
                title: "Cancel".tr,
                onPressed: _takeConfirmation,
                clickable: !_isLoading ? "true" : "")
            : null,
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CAppBarWidget(
              title: "Appointment Details".tr,
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: _isLoading
                    ? LoadingIndicatorWidget()
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 0.0, bottom: 8.0, left: 0, right: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              // SizedBox(height: 20),
                              _inputTextField(
                                  "Name".tr, _firstNameController, 1),
                              _inputTextField("Amount".tr, _amountCont, 1),
                              _inputTextField("Payment Status".tr,
                                  _paymentStatusController, 1),
                              _inputTextField("Age".tr, _ageController, 1),
                              _inputTextField("Appointment Status".tr,
                                  _statusController, 1),
                              _inputTextField(
                                  "Phone Number".tr, _phnController, 1),
                              _inputTextField("City".tr, _cityController, 1),
                              //   _inputTextField("Email", _emailController, 1),
                              _inputTextField("Clinic Name".tr, _clinicName, 1),
                              // _inputTextField("Clinic City", _cityName, 1),
                              _inputTextField("Created on".tr,
                                  _createdDateTimeController, 1),
                              _inputTextField(
                                  "Description, About your problem".tr,
                                  _descController,
                                  null),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ));
  }

  Widget _inputTextField(String labelText, controller, maxLine) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),// left and right old value is 20 + top old value is 10 + hassan005004
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
      _isLoading = true;
    });
    final res = await LabTestAppService.updateStatusData(
      widget.appointmentDetails!.id.toString(),
      "3",
    );
    if (res == "success") {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final uid = preferences.getString("uid");
      final notificationModel = NotificationModel(
          title: "Canceled!",
          body: "Test Appointment has been canceled",
          uId: uid,
          routeTo: "/LabTestAppListPage",
          sendBy: "user",
          sendFrom: "${widget.appointmentDetails!.pName}",
          sendTo: "Admin");
      final notificationModelForAdmin = NotificationModel(
          title: "Canceled Appointment!",
          body:
              "${widget.appointmentDetails!.pName} has canceled test appointment appointment id: ${widget.appointmentDetails!.id}", //body
          uId: uid,
          sendBy: "${widget.appointmentDetails!.pName}",
          laId: widget.appointmentDetails!.clinicID);
      await NotificationService.addData(notificationModel);
      await NotificationService.addDataForLabAttender(
          notificationModelForAdmin);
      _handleSendNotification(uid);
    } else {
      ToastMsg.showToastMsg("Something went wrong".tr);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _handleSendNotification(uid) async {
    await _setAdminFcmId();
    //send local notification

    await HandleLocalNotification.showNotification(
      "Canceled",
      "Test Appointment has been canceled", // body
    );
    await UpdateData.updateIsAnyNotification("usersList", uid, true);

    //send notification to admin app for booking confirmation
    await HandleFirebaseNotification.sendPushMessage(
        _adminFCMid, //admin fcm
        "Canceled Appointment", //title
        "${widget.appointmentDetails!.pName} has canceled appointment appointment id: ${widget.appointmentDetails!.id}" //body
        );
    await UpdateData.updateIsAnyNotification("profile", "profile", true);
    ToastMsg.showToastMsg("Successfully Canceled");
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/LabTestAppListPage', ModalRoute.withName('/HomePage'));
  }

  Future<String> _setAdminFcmId() async {
    //loading if data till data fetched
    setState(() {
      _isLoading = true;
    });
    final res = await DrProfileService
        .getData(); //fetch admin fcm id for sending messages to admin

    setState(() {
      _adminFCMid = res[0].fdmId ?? "";
    }); //fetch admin fcm id for sending messages to admin

    setState(() {
      _isLoading = false;
    });
    return "";
  }

  _takeConfirmation() {
    DialogBoxes.confirmationBox(context, "Cancel".tr,
        "Are you sure want to cancel appointment".tr, _handleCancelBtn);
  }
}
