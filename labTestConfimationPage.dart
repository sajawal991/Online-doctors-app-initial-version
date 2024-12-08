import 'package:demopatient/Screen/paypalWebView.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:demopatient/Service/Firebase/updateData.dart';
import 'package:demopatient/Service/Noftification/handleFirebaseNotification.dart';
import 'package:demopatient/Service/Noftification/handleLocalNotification.dart';
import 'package:demopatient/Service/appointmentService.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/Service/lab_test_app_service.dart';
import 'package:demopatient/Service/notificationService.dart';
import 'package:demopatient/config.dart';
import 'package:demopatient/model/lab_test_app_model.dart';
import 'package:demopatient/model/notificationModel.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/style.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../widgets/paymentMethodButton.dart';

class LabTestConfirmationPage extends StatefulWidget {
  final firstName;
  final lastName;
  final phoneNumber;
  final email;
  final age;
  final gender;
  final city;
  final desc;
  final testName;
  final cliniName;
  final location;
  final testId;
  final price;
  final clinicId;

  LabTestConfirmationPage({Key? key,
    this.firstName,
    this.lastName,
    this.testId,
    this.price,
    this.testName,this.email,
    this.gender,
    this.desc,this.age,this.city,this.phoneNumber,
    this.cliniName,
    this.location,
    this.clinicId
  }) : super(key: key);

  @override
  _LabTestConfirmationPageState createState() => _LabTestConfirmationPageState();
}

class _LabTestConfirmationPageState extends State<LabTestConfirmationPage> {
  String _adminFCMid = "";
  String doctorFcm = "";
  bool _isLoading = false;
  String _isBtnDisable = "false";
  String _uId = "";
  String _uid = "";
  String _uName = "";
  int paymentValue = 1;
  int _paymentMeth = 0;
  int _checkoutMethod = 333;

  int _amount = 0;
  bool isOnline = false;
  //static const platform = const MethodChannel("razorpay_flutter");

  Razorpay? _razorpay;
  // final payStack = PaystackPlugin();

  @override
  void initState() {
    _amount=int.parse(widget.price);
    // TODO: implement initState
    super.initState();
    _getAndSetUserData();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    // payStack.initialize(publicKey: payStackPublickKey);
  }

  _makeCheckoutEnableDisable(checkout) {
    if(checkout != 000){
      _isBtnDisable = "";
    }else{
      _isBtnDisable = "true";
    }
  }

  void dispose() {
    super.dispose();
    _razorpay!.clear();
  }

  void openCheckout() async {
    var options = {
      'key': razorpayKeyId,
      'amount': _amount * 100,
      'name': widget.firstName +
          " " +
          widget.lastName,
      'description': widget.desc,
      'prefill': {
        'contact': widget.phoneNumber,
        'email': widget.email
      },
      "notify": {"sms": true, "email": true},
      "method": {
        "netbanking": true,
        "card": true,
        "wallet": false,
        'upi': true,
      },
    };

    try {
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _updateBookedPayLaterSlot(
       widget.firstName,
        widget.lastName,
        widget.phoneNumber,
        widget.email,
        widget.age,
        widget.gender,
      widget.city,
       widget.desc,
      widget.testName,
        "Paid",
        response.paymentId,
        widget.testId,
    );
    ToastMsg.showToastMsg("Payment success, please don't press back button".tr);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //     msg: "ERROR: " + response.code.toString() + " - " + response.message,
    //     toastLength: Toast.LENGTH_SHORT);
    ToastMsg.showToastMsg("Something went wrong".tr);
    setState(() {
      _isLoading = false;
      _isBtnDisable = "false";
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT);
  }

  _getAndSetUserData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uName =
          prefs.getString("firstName")! + " " + prefs.getString("lastName")!;
      _uId = prefs.getString("uid")!;
      _uid = prefs.getString("iuid")??"";

    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        bottomNavigationBar: BottomNavigationStateWidget(
          title: "Confirm Appointment".tr,
          onPressed: () async {

            // commented by hassan005004
            // paymentModeBox();

            if(_checkoutMethod == 333){
              openCheckout();
            }

            // Method handles all the booking system operation.
          },
          clickable: _isBtnDisable,
        ),
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CAppBarWidget(title: "Booking Confirmation".tr),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: IBoxDecoration.upperBoxDecoration(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 10, right: 10),
                          child: _isLoading
                              ? Center(child: LoadingIndicatorWidget())
                              : Center(
                            child: Container(
                              // height: 350,
                                width: double.infinity,
                                child: _cardView()),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));

    //    Container(
    //       color: bgColor,
    //       child: _isLoading
    //           ? Center(child: CircularProgressIndicator())
    //           : Center(
    //               child: Container(
    //                   height: 250,
    //                   width: double.infinity,
    //                   child: _cardView(patientDetailsArgs)),
    //             )),
    // );
  }

  Widget _cardView() {
    return Card(
      // color: Colors.grey[300], // hassan005004
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0, // old value is 20 + hassan005004
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: appBarColor,
              ),
              child: Center(
                child: Text(
                  "Please Confirm All Details".tr,
                  style: TextStyle(
                    fontFamily: 'OpenSans-SemiBold',
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            Divider(),
            Text(
              "Patient Name".tr+"-"+"${widget.firstName} " + "${widget.lastName}",
              style: kCardSubTitleStyle,
            ),
            SizedBox(height: 10),
            Text(
                "Service Name".tr+" - "+"${widget.lastName}",
                style: kCardSubTitleStyle),
            SizedBox(height: 10),
            Text("City".tr+" - "+"${widget.city}", style: kCardSubTitleStyle),
            SizedBox(height: 10),
            Text("Clinic".tr+" - "+"${widget.cliniName}", style: kCardSubTitleStyle),
            SizedBox(height: 10),
            Text( "Location Name".tr+" - "+"${widget.location}", style: kCardSubTitleStyle),
            SizedBox(height: 10),
            Text("Mobile Number".tr+" - "+"${widget.phoneNumber}", style: kCardSubTitleStyle),
            SizedBox(height: 10),
            Text("Amount".tr+" - "+"$_amount\u{20B9}", style: kCardSubTitleStyle),

            /*ListTile(
              title: Text("Pay Now".tr),
              leading: Radio(
                value: 1,
                groupValue: paymentValue,
                onChanged: (int? value) {
                  setState(() {
                    paymentValue = value!;
                  });
                },
              ),
            ),*/

            SizedBox(height: 10),

            PaymentMethodButton(
              title: 'Razorpay'.tr,
              isSelected: _checkoutMethod == 333 ? 1 : 0,
              amount: _amount,
              onPressed: (){
                // the button is true make it false
                bool value = _checkoutMethod == 333 ? true : false;
                if(value == true){
                  _makeCheckoutEnableDisable(333);
                  _checkoutMethod = 000;
                }else{
                  _makeCheckoutEnableDisable(000);
                  _checkoutMethod = 333;
                }

                setState(() {
                  // _paymentMeth = _paymentMeth == 0 ? 1 : 0;
                  // deductFromWallet = false;
                  // newAmount = _amount;
                });
              },

            ),

            /*InkWell(
                onTap: (){
                  bool value = _paymentMeth == 0 ? true : false;
                  if(value == true){
                    _makeCheckoutEnableDisable(333);
                  }else{
                    _makeCheckoutEnableDisable(000);
                  }

                  setState(() {
                    _paymentMeth = _paymentMeth == 0 ? 1 : 0;
                    // deductFromWallet = false;
                    // newAmount = _amount;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 45,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: btnColor.withOpacity(0.1),
                        border: Border.all(
                            width: _paymentMeth == 0 ? 2.0 : 2.0,
                            color: _paymentMeth == 0 ? btnColor : btnColor.withOpacity(0.1)
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0) //                 <--- border radius here
                        ),
                      ),
                      child: Row(
                        children: [
                          Text('Razorpay'.tr),
                          Spacer(),
                          _paymentMeth == 0 ? Icon(Icons.check, color: btnColor,) : Center()
                        ],
                      ),
                    ),
                    _paymentMeth == 0 ?
                    // newAmount == null ?
                    Text("Pay Amount: Rs.".tr + _amount.toString()) :
                    // Text("Pay Amount: Rs.".tr + newAmount.toString()) :
                    Container(),
                  ],
                )
            ),*/

            // paymentValue == 1
            //     ? ListTile(
            //   title: const Text('Paypal Payment'),
            //   leading: Radio(
            //     value: 1,
            //     groupValue: _paymentMeth,
            //     onChanged: (int? value) {
            //       setState(() {
            //         _paymentMeth = value!;
            //       });
            //     },
            //   ),
            // )
            //     : Container(),
            // paymentValue == 1
            //     ? Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     "Note: Please use this id and password for paypal test payment\nEmail: MyclinicTest@paypal.com\nPassword: 12345678",
            //     style: TextStyle(color: Colors.red),
            //   ),
            // )
            //     : Container(),
            // paymentValue == 1
            //     ? ListTile(
            //   title: const Text('Razorpay Indian Payment'),
            //   leading: Radio(
            //     value: 0,
            //     groupValue: _paymentMeth,
            //     onChanged: (int? value) {
            //       setState(() {
            //         _paymentMeth = value!;
            //       });
            //     },
            //   ),
            // )
            //     : Container(),
            // args.serviceName == "Online"
            //     ? Container()
            //     : ListTile(
            //   title: const Text('Pay Later'),
            //   leading: Radio(
            //     value: 0,
            //     groupValue: paymentValue,
            //     onChanged: (int? value) {
            //       setState(() {
            //         paymentValue = value!;
            //       });
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  void _updateBookedPayLaterSlot(
      pFirstName,
      pLastName,
      pPhn,
      pEmail,
      age,
      gender,
      pCity,
      desc,
      serviceName,
      paymentStatus,
      paymentId,
      testId) async {
    setState(() {
      _isLoading = true;
      _isBtnDisable = "";
    });

    final LabTestAppModel labTestAppModel= LabTestAppModel(
        pName: pFirstName+" "+pLastName,
        pPhn: pPhn,
        pEmail: pEmail,
        pAge: age,
        pGender: gender,
        pCity: pCity,
        pDesc: desc,
        serviceName: serviceName,
        uid: _uid,
        pymentStatus: paymentStatus,
        paymentId:  paymentId,
        paymentAmount: _amount.toString(),
        labTestId: widget.testId,
      clinicID: widget.clinicId,
      status: "0"
          ); //initialize all values

    final insertStatus = await LabTestAppService.addData(labTestAppModel);
    if (insertStatus != "error") {


        final notificationModel = NotificationModel(
            title: "Successfully Booked!",
            body:
            "Lab Test Appointment has been booked on. Waiting for confirmation",
            uId: _uId,
            routeTo: "/LabTestAppListPage",
            sendBy: "user",
            sendFrom: _uName,
            sendTo: "Admin");
        final notificationModelForAdmin = NotificationModel(
            title: "New Lab Test Appointment!",
            body:
            "$pFirstName $pLastName booked Lab Test Appointment",
            uId: _uId,
            sendBy: _uName,
            laId: widget.testId);

        final msgAdded = await NotificationService.addData(notificationModel);

        if (msgAdded == "success") {
          await NotificationService.addDataForLabAttender(notificationModelForAdmin);
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          try {
            _prefs.getStringList("patientData")!.clear();
            _prefs.setBool("inPaymentState", false);
          } catch (e) {
            print(e);
          }
          ToastMsg.showToastMsg("Successfully Booked".tr);
          _handleSendNotification(pFirstName, pLastName, serviceName);
        } else if (msgAdded == "error") {
          ToastMsg.showToastMsg("Something went wrong. try again".tr);

          Navigator.pop(context);
        }

    } else {
      ToastMsg.showToastMsg("Something went wrong. try again".tr);
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
      _isBtnDisable = "false";
    });
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
    });

    // final res2 = await DrProfileService.getDataByDrId(
    //     doctId); //fetch admin fcm id for sending messages to admin
    //
    // setState(() {
    //   doctorFcm = res2[0].fdmId ?? "";
    // });

    setState(() {
      _isLoading = false;
    });
    return "";
  }

  void _handleSendNotification(String firstName, String lastName,
      String serviceName) async {
    setState(() {
      _isLoading = true;
      _isBtnDisable = "";
    });
   await _setAdminFcmId();
    await HandleLocalNotification.showNotification(
      "Successfully Booked", //title
      "Lab Test Appointment has been booked. Waiting for confirmation", // body
    );
    await UpdateData.updateIsAnyNotification("usersList", _uId, true);

    //send notification to admin app for booking confirmation
    // print("++++++++++++admin$_adminFCMid");
    // print("++++++++++++doctor$doctorFcm");
    await HandleFirebaseNotification.sendPushMessage(
        _adminFCMid, //admin fcm
        "New Lab Test Appointment", //title
        "$firstName $lastName booked lab test appointment" //body
    );
    // await HandleFirebaseNotification.sendPushMessage(
    //     doctorFcm, //admin fcm
    //     "New Appointment", //title
    //     "$firstName $lastName booked an appointment on $selectedDate at $setTime" //body
    // );
  //  await UpdateData.updateIsAnyNotification("doctorsNoti", doctId, true);
    await UpdateData.updateIsAnyNotification("profile", "profile", true);

    Navigator.of(context).pushNamedAndRemoveUntil(
        '/LabTestAppListPage', ModalRoute.withName('/HomePage'));
  }
  paymentModeBox(){
    return  showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: new Text("Payment Getaway".tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: .1,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: (){
                    Navigator.of(context).pop();
                    openCheckout();
                  },
                  title: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 10,
                          child: Icon(Icons.check,color: Colors.white,size: 17,)),
                      SizedBox(width: 5),
                      Flexible(child: Text("Razorpay Indian Payment (India)")),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: .1,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: (){
                    Navigator.of(context).pop();
                    openCheckoutPayPal();
                  },
                  title: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 10,
                          child: Icon(Icons.check,color: Colors.white,size: 17,)),
                      SizedBox(width: 5),
                      Flexible(child: Text("PayPal")),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Please use this id and password for paypal test payment\nEmail: MyclinicTest@paypal.com\nPassword: 12345678"),
                  ),
                ),
              ),
              Card(
                elevation: .1,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: (){
                    Navigator.of(context).pop();
                    openCheckOutPayStack();
                  },
                  title: Row(
                    children: [
                      CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 10,
                          child: Icon(Icons.check,color: Colors.white,size: 17,)),
                      SizedBox(width: 5),
                      Flexible(child: Text("Paystack Payment")),
                    ],
                  ),
                ),
              ),

            ],
          ),
          actions: <Widget>[
            new ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnColor,
                ),
                child: new Text("Cancel".tr),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            // usually buttons at the bottom of the dialog
          ],
        );
      },
    );
  }
  void openCheckoutPayPal() async {
    setState(() {
      _isLoading=true;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalPayment(
          itemPrice: int.parse(_amount.toString()),
          onFinish: (number) async {
            ToastMsg.showToastMsg(
                "Payment success, please don't press back button".tr);
            _updateBookedPayLaterSlot(
              widget.firstName,
              widget.lastName,
              widget.phoneNumber,
              widget.email,
              widget.age,
              widget.gender,
              widget.city,
              widget.desc,
              widget.testName,
              "Paid",
              number.toString(),
              widget.testId,
            );
            ToastMsg.showToastMsg("Payment success, please don't press back button".tr);
            //  _handleAddData(isCOD: false,paymentID: number,paymentMode:"paypal");
          },
        ),
      ),
    );
    setState(() {
      _isLoading=false;
    });

  }
  openCheckOutPayStack()async{
    // setState(() {
    //   _isLoading=true;
    // });
    // final getAccessCode=await AppointmentService.getPayStackAcceessCodeData("customer@email.com", _amount * 100);
    // if(getAccessCode!="error"){
    //   if (getAccessCode['status']==true){
    //     Charge charge = Charge()
    //       ..amount =   _amount * 100
    //       ..accessCode = getAccessCode['data']['access_code']
    //       ..email = 'customer@email.com';
    //     CheckoutResponse response = await payStack.checkout(
    //       context,
    //       method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
    //       charge: charge,
    //     );
    //     //print(response.status);reference
    //     if(response.status)
    //     {
    //       print("Ref No");
    //       _updateBookedPayLaterSlot(
    //         widget.firstName,
    //         widget.lastName,
    //         widget.phoneNumber,
    //         widget.email,
    //         widget.age,
    //         widget.gender,
    //         widget.city,
    //         widget.desc,
    //         widget.testName,
    //         "Paid",
    //         response.reference,
    //         widget.testId,
    //       );
    //       ToastMsg.showToastMsg("Payment success, please don't press back button".tr);
    //       ToastMsg.showToastMsg("Payment success, please don't press back button".tr);
    //     }
    //     else ToastMsg.showToastMsg("Payment Failed".tr);
    //     print(response);
    //
    //   }else ToastMsg.showToastMsg("Something went wrong".tr);
    //
    // }else ToastMsg.showToastMsg("Something went wrong".tr);
    // setState(() {
    //   _isLoading=false;
    // });
  }
}
