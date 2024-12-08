import 'dart:convert';

import 'package:az_ui/helper/extensions.dart';
import 'package:demopatient/Module/Doctor/Provider/DoctorProvider.dart';
import 'package:demopatient/Module/Widget/CommonWidget.dart';
import 'package:demopatient/Module/User/Provider/auth_provider.dart';
import 'package:demopatient/Screen/paypalWebView.dart';
import 'package:demopatient/Service/userService.dart';
import 'package:demopatient/controller/get_user_controller.dart';
import 'package:demopatient/model/drProfielModel.dart';
import 'package:demopatient/model/userModel.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:demopatient/Service/Firebase/updateData.dart';
import 'package:demopatient/Service/Noftification/handleFirebaseNotification.dart';
import 'package:demopatient/Service/Noftification/handleLocalNotification.dart';
import 'package:demopatient/Service/appointmentService.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/Service/notificationService.dart';
import 'package:demopatient/SetData/screenArg.dart';
import 'package:demopatient/config.dart';
import 'package:demopatient/model/appointmentModel.dart';
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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../Screen/jitscVideoCall.dart';
import '../../../Service/Apiservice/chatapi.dart';

class AppointmentConfirmationScreen extends StatefulWidget {

  String serviceName;
  int type;
  double amount;

  AppointmentConfirmationScreen({Key? key, required this.type, required this.serviceName, required this.amount}) : super(key: key);

  @override
  _AppointmentConfirmationScreenState createState() => _AppointmentConfirmationScreenState();
}

class _AppointmentConfirmationScreenState extends State<AppointmentConfirmationScreen> {
  // final payStack = PaystackPlugin();
  String _adminFCMid = "";
  String doctorFcm = "";
  bool _isLoading = false;
  String _isBtnDisable = "false";
  String _uId = "";
  String _uName = "";
  int paymentValue = 1;
  String payStaclaccessCode="";
  double _amount = 0;
  bool isOnline = false;
  //static const platform = const MethodChannel("razorpay_flutter");
  var _patientDetailsArgs;
  Razorpay? _razorpay;
  int _paymentMeth = 0;
  double? newAmount;
  bool deductFromWallet=false;
  bool needToPay=true;
  String? walletBalance="0";
  String? deductedWalletAmount="0";
  GetUserController _getUserController=Get.find(tag: "wallet");

  @override
  void initState() {
    // payStack.initialize(publicKey: payStackPublickKey);
    // TODO: implement initState
    super.initState();
    _getAndSetUserData();
    _activePaymentMethods();

    _amount = widget.amount;
    setState(() {

    });
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }


  void dispose() {
    super.dispose();
    _razorpay!.clear();
  }

  int activeWalletMethod = 0;
  int activeWalletAdjustMethod = 0;
  int activeRazorPayMethod = 0;


  // int checkout = 333; // 111 for wallet, 222 for adjust payment method, 333 for razorpay
  _activePaymentMethods(){
    if(int.parse(walletBalance.toString()) > _amount && walletBalance.toString() != "0"){
      activeWalletMethod = 1;
    }
    if(int.parse(walletBalance.toString()) < _amount && walletBalance.toString() != "0"){
      activeWalletAdjustMethod = 1;
    }
    activeRazorPayMethod = 1;
  }

  _makeCheckoutEnableDisable(checkout) {
    if(checkout != 000){
      _isBtnDisable = "";
    }else{
      _isBtnDisable = "true";
    }
  }

  void openCheckout() async {
    // if(newAmount==0||_amount==0) {
      // _updateBookedPayLaterSlot(
      //   _patientDetailsArgs!.pFirstName,
      //   _patientDetailsArgs!.pLastName,
      //   _patientDetailsArgs!.pPhn,
      //   _patientDetailsArgs!.pEmail,
      //   _patientDetailsArgs!.age,
      //   _patientDetailsArgs!.gender,
      //   _patientDetailsArgs!.pCity,
      //   _patientDetailsArgs!.desc,
      //   _patientDetailsArgs!.serviceName,
      //   _patientDetailsArgs!.serviceTimeMIn,
      //   _patientDetailsArgs!.selectedTime,
      //   _patientDetailsArgs!.selectedDate,
      //   _patientDetailsArgs!.doctName,
      //   _patientDetailsArgs!.deptName,
      //   _patientDetailsArgs!.hName,
      //   _patientDetailsArgs!.doctId,
      //   "Paid",
      //   "XXXXXX",
      //   "online",
      //   _patientDetailsArgs!.cityId,
      //   _patientDetailsArgs!.clinicId,
      //   _patientDetailsArgs!.deptId,
      // );
    // }
    // else{
      UserModel activeUser = await Provider.of<AuthProvider>(context, listen: false).activeUser;
      var options = {
        'key': razorpayKeyId,
        'amount': newAmount == null ? _amount * 100 : newAmount! * 100,
        'name': "${activeUser.firstName} ${activeUser.lastName}",
        'description': widget.serviceName,
        'prefill': {
          'contact': activeUser.phone,
          'email': activeUser.email
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
    // }

  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    UserModel activeUser = await Provider.of<AuthProvider>(context, listen: false).activeUser;
    DrProfileModel? doctor = await Provider.of<DoctorProvider>(context, listen: false).doctor;


    DateTime now = DateTime.now();
    String date = "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";

    _updateBookedPayLaterSlot(
        activeUser.firstName,
        activeUser.lastName,
        activeUser.phone,
        activeUser.email,
        activeUser.age,
        activeUser.gender,
        activeUser.city,
        'emergency call',//activeUser.desc,
        widget.serviceName,
        '30', //_patientDetailsArgs!.serviceTimeMIn,
        '', // pass null or empty string for emergencey call//_patientDetailsArgs!.selectedTime,
        date,//_patientDetailsArgs!.selectedDate,
        doctor!.firstName.toString() + " " + doctor!.lastName.toString(),
        doctor.deptName.toString(),
        doctor.hName.toString(),
        doctor.id.toString(),
        "Paid",
        response.paymentId,
        "online",
        1,//doctor!.cityId,
        doctor.clinicId,
        doctor.deptId);
    ToastMsg.showToastMsg("Payment success, please don't press back button".tr);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //     msg: "ERROR: " + response.code.toString() + ": " + response.message,
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
      _uName = prefs.getString("firstName")! + " " + prefs.getString("lastName")!;
      _uId = prefs.getString("uid")!;
    });
    final userData=await UserService.getData();
    if(userData.isNotEmpty){
      walletBalance=userData[0].amount??"0";
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        bottomNavigationBar: BottomNavigationStateWidget(
          title: "Confirm Appointment".tr,
          onPressed: (){
            // checkout for razorpay
            print(_paymentMeth);
            print(activeRazorPayMethod);
            if(_paymentMeth == 0 && activeRazorPayMethod == 1){
              openCheckout();
            }
          },
          // onPressed: paymentValue ==-1 ? null:() async {
          //   setState(() {
          //     _isLoading = true;
          //     _isBtnDisable = "";
          //   });
          //   final checkRes = await AppointmentService.getCheckPD(
          //       _patientDetailsArgs!.doctId,
          //       _patientDetailsArgs!.selectedDate,
          //       _patientDetailsArgs!.serviceName=="Online"?"true":"false"
          //   );
          //   if (checkRes.length<int.parse(_patientDetailsArgs.wspd)) {
          //     if (paymentValue == 0) {
          //       _updateBookedPayLaterSlot(
          //           _patientDetailsArgs!.pFirstName,
          //           _patientDetailsArgs!.pLastName,
          //           _patientDetailsArgs!.pPhn,
          //           _patientDetailsArgs!.pEmail,
          //           _patientDetailsArgs!.age,
          //           _patientDetailsArgs!.gender,
          //           _patientDetailsArgs!.pCity,
          //           _patientDetailsArgs!.desc,
          //           _patientDetailsArgs!.serviceName,
          //           _patientDetailsArgs!.serviceTimeMIn,
          //           _patientDetailsArgs!.selectedTime,
          //           _patientDetailsArgs!.selectedDate,
          //           _patientDetailsArgs!.doctName,
          //           _patientDetailsArgs!.deptName,
          //           _patientDetailsArgs!.hName,
          //           _patientDetailsArgs!.doctId,
          //           "Pay Later",
          //           "",
          //           "Pay Later",
          //           _patientDetailsArgs!.cityId,
          //           _patientDetailsArgs!.clinicId,
          //           _patientDetailsArgs!.deptId);
          //     } else if (paymentValue == 1) {
          //       setState(() {
          //         _isLoading = true;
          //         _isBtnDisable = "";
          //       });
          //       if (_paymentMeth == 2) {
          //         setState(() {
          //           _isLoading = false;
          //           _isBtnDisable = "true";
          //         });
          //         if(newAmount==0||_amount==0) {
          //           _updateBookedPayLaterSlot(
          //             _patientDetailsArgs!.pFirstName,
          //             _patientDetailsArgs!.pLastName,
          //             _patientDetailsArgs!.pPhn,
          //             _patientDetailsArgs!.pEmail,
          //             _patientDetailsArgs!.age,
          //             _patientDetailsArgs!.gender,
          //             _patientDetailsArgs!.pCity,
          //             _patientDetailsArgs!.desc,
          //             _patientDetailsArgs!.serviceName,
          //             _patientDetailsArgs!.serviceTimeMIn,
          //             _patientDetailsArgs!.selectedTime,
          //             _patientDetailsArgs!.selectedDate,
          //             _patientDetailsArgs!.doctName,
          //             _patientDetailsArgs!.deptName,
          //             _patientDetailsArgs!.hName,
          //             _patientDetailsArgs!.doctId,
          //             "Paid",
          //             "XXXXXX",
          //             "online",
          //             _patientDetailsArgs!.cityId,
          //             _patientDetailsArgs!.clinicId,
          //             _patientDetailsArgs!.deptId,
          //           );
          //         }else{
          //           final getAccessCode=await AppointmentService.getPayStackAcceessCodeData("customer@email.com",(_amount * 100).toInt());
          //           if(getAccessCode!="error"){
          //             if (getAccessCode['status']==true){
          //               Charge charge = Charge()
          //                 ..amount =   newAmount == null ? (_amount * 100).toInt() : (newAmount! * 100).toInt()
          //                 ..accessCode = getAccessCode['data']['access_code']
          //                 ..email = 'customer@email.com';
          //               CheckoutResponse response = await payStack.checkout(
          //                 context,
          //                 method: CheckoutMethod.card, // Defaults to CheckoutMethod.selectable
          //                 charge: charge,
          //               );
          //               //print(response.status);reference
          //               if(response.status)
          //               {
          //                 // print("Ref No");
          //                 // print(response.reference);
          //                 _updateBookedPayLaterSlot(
          //                     _patientDetailsArgs!.pFirstName,
          //                     _patientDetailsArgs!.pLastName,
          //                     _patientDetailsArgs!.pPhn,
          //                     _patientDetailsArgs!.pEmail,
          //                     _patientDetailsArgs!.age,
          //                     _patientDetailsArgs!.gender,
          //                     _patientDetailsArgs!.pCity,
          //                     _patientDetailsArgs!.desc,
          //                     _patientDetailsArgs!.serviceName,
          //                     _patientDetailsArgs!.serviceTimeMIn,
          //                     _patientDetailsArgs!.selectedTime,
          //                     _patientDetailsArgs!.selectedDate,
          //                     _patientDetailsArgs!.doctName,
          //                     _patientDetailsArgs!.deptName,
          //                     _patientDetailsArgs!.hName,
          //                     _patientDetailsArgs!.doctId,
          //                     "Paid",
          //                     response.reference,
          //                     "online",
          //                     _patientDetailsArgs!.cityId,
          //                     _patientDetailsArgs!.clinicId,
          //                     _patientDetailsArgs!.deptId);
          //                 ToastMsg.showToastMsg("Payment success, please don't press back button".tr);
          //               }
          //               else ToastMsg.showToastMsg("Payment Failed".tr);
          //               // print(response);
          //
          //             }else ToastMsg.showToastMsg("Something went wrong".tr);
          //
          //           }else ToastMsg.showToastMsg("Something went wrong".tr);
          //         }
          //
          //
          //       }
          //       else if (_paymentMeth == 1) {
          //         setState(() {
          //           _isLoading = false;
          //           _isBtnDisable = "true";
          //         });
          //         if(newAmount==0||_amount==0) {
          //           _updateBookedPayLaterSlot(
          //             _patientDetailsArgs!.pFirstName,
          //             _patientDetailsArgs!.pLastName,
          //             _patientDetailsArgs!.pPhn,
          //             _patientDetailsArgs!.pEmail,
          //             _patientDetailsArgs!.age,
          //             _patientDetailsArgs!.gender,
          //             _patientDetailsArgs!.pCity,
          //             _patientDetailsArgs!.desc,
          //             _patientDetailsArgs!.serviceName,
          //             _patientDetailsArgs!.serviceTimeMIn,
          //             _patientDetailsArgs!.selectedTime,
          //             _patientDetailsArgs!.selectedDate,
          //             _patientDetailsArgs!.doctName,
          //             _patientDetailsArgs!.deptName,
          //             _patientDetailsArgs!.hName,
          //             _patientDetailsArgs!.doctId,
          //             "Paid",
          //             "XXXXXX",
          //             "online",
          //             _patientDetailsArgs!.cityId,
          //             _patientDetailsArgs!.clinicId,
          //             _patientDetailsArgs!.deptId,
          //           );
          //         }else{
          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (BuildContext context) => PaypalPayment(
          //                 itemPrice: newAmount == null ? _amount  : newAmount!,
          //                 onFinish: (number) async {
          //                   setState(() {
          //                     _isLoading = true;
          //                     _isBtnDisable = "";
          //                   });
          //
          //                   _updateBookedPayLaterSlot(
          //                       _patientDetailsArgs!.pFirstName,
          //                       _patientDetailsArgs!.pLastName,
          //                       _patientDetailsArgs!.pPhn,
          //                       _patientDetailsArgs!.pEmail,
          //                       _patientDetailsArgs!.age,
          //                       _patientDetailsArgs!.gender,
          //                       _patientDetailsArgs!.pCity,
          //                       _patientDetailsArgs!.desc,
          //                       _patientDetailsArgs!.serviceName,
          //                       _patientDetailsArgs!.serviceTimeMIn,
          //                       _patientDetailsArgs!.selectedTime,
          //                       _patientDetailsArgs!.selectedDate,
          //                       _patientDetailsArgs!.doctName,
          //                       _patientDetailsArgs!.deptName,
          //                       _patientDetailsArgs!.hName,
          //                       _patientDetailsArgs!.doctId,
          //                       "Paid",
          //                       number.toString(),
          //                       "online",
          //                       _patientDetailsArgs!.cityId,
          //                       _patientDetailsArgs!.clinicId,
          //                       _patientDetailsArgs!.deptId);
          //                   ToastMsg.showToastMsg(
          //                       "Payment success, please don't press back button".tr);
          //                   //  _handleAddData(isCOD: false,paymentID: number,paymentMode:"paypal");
          //                 },
          //               ),
          //             ),
          //           );
          //         }
          //
          //       }
          //       else if (_paymentMeth == 4){
          //         openCheckout();
          //       }else
          //         openCheckout();
          //     }
          //   }
          //   else {
          //     setState(() {
          //       _isLoading = false;
          //       _isBtnDisable = "true";
          //     });
          //     ToastMsg.showToastMsg(
          //         "Slots are fulled, please book for a different date".tr);
          //     Navigator.pop(context);
          //     Navigator.pop(context);
          //     Navigator.pop(context);
          //   }
          //   // Method handles all the booking system operation.
          // },
          clickable: _isBtnDisable,
        ),
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CAppBarWidget(title: "Booking Confirmation".tr),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
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
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Background color
                                      border: Border.all(
                                        color: Color(0xFFE1E1E1),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0), // Radius for all corners
                                      ),
                                    ),
                                    child: Card(
                                      // color: Colors.grey[300],
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      elevation: 0, // old value is 20 + hassan005004
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Consumer<AuthProvider>(
                                            builder: (context, authProvider, _) {
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  height: 40,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(50),
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
                                                Divider(
                                                  thickness: 0.5,
                                                ),
                                                SizedBox(height: 10),
                                                if(widget.serviceName == "Emergency Call")
                                                  Center(
                                                    child: Container(
                                                      height: 150,
                                                      width: 150,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(100.0),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Center(
                                                          child: Image.asset(
                                                            'assets/icon/emergency.png',
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                gapY(),

                                                Text("for").azText().fs(18),

                                                gapY(),

                                                Text("${authProvider.activeUser.firstName} ${authProvider.activeUser.lastName}", style: kCardSubTitleStyle,)
                                                    .azText().bold().fs(20),

                                                gapY(),

                                                Center(
                                                  child: Text("If doctor not pick call, doctor will callback")
                                                    .azText()
                                                    .textAlign(TextAlign.center)
                                                ),

                                                gapY(),

                                                // SizedBox(height: 10),
                                                // Text("Date".tr+"- ${args.selectedDate}", style: kCardSubTitleStyle),
                                                // SizedBox(height: 10),
                                                // Text("Time".tr+": ${args.selectedTime}", style: kCardSubTitleStyle),
                                                // SizedBox(height: 10),
                                                // Text("City".tr+": ${args.cityName}", style: kCardSubTitleStyle),
                                                // SizedBox(height: 10),
                                                // Text("Clinic".tr+": ${args.clinicName}", style: kCardSubTitleStyle),
                                                // SizedBox(height: 10),
                                                // Text("Doctor Name".tr +": ${args.doctName}", style: kCardSubTitleStyle),
                                                // SizedBox(height: 10),
                                                // Text("Department".tr+": ${args.deptName}", style: kCardSubTitleStyle),
                                                // SizedBox(height: 10),
                                                // Text("Hospital Name".tr+": ${args.hName}", style: kCardSubTitleStyle),
                                                // SizedBox(height: 10),
                                                // Text("Mobile Number".tr+": ${args.pPhn}", style: kCardSubTitleStyle),
                                                // SizedBox(height: 10),
                                                // newAmount==null?
                                                // Text("Pay Amount: Rs.".tr+" $_amount",      style: TextStyle(
                                                //     fontSize: 16,
                                                //     fontFamily: "OpenSans-SemiBold"
                                                // )) : Text("Pay Amount: Rs.".tr+" $newAmount",      style: TextStyle(
                                                //     fontSize: 16,
                                                //     fontFamily: "OpenSans-SemiBold"
                                                // )),
                                                // SizedBox(height: 10),
                                                // Text("Available Wallet Balance".tr+" \u{20B9}$walletBalance",
                                                //   style: TextStyle(
                                                //       fontSize: 16,
                                                //       fontFamily: "OpenSans-SemiBold"
                                                //   ),),


                                                // deduct from wallet new
                                                if(activeWalletMethod == 1)
                                                  InkWell(
                                                      onTap: (){
                                                        bool value = deductFromWallet == true ? false : true;
                                                        if(value == true){
                                                          _makeCheckoutEnableDisable(111);
                                                        }else{
                                                          _makeCheckoutEnableDisable(000);
                                                        }

                                                        // unset razorpay checkout
                                                        _paymentMeth = 1;

                                                        setState(() {
                                                          deductFromWallet=value!;
                                                        });

                                                        final walletIntAmount=int.parse(walletBalance.toString());
                                                        if(value??false){
                                                          if(walletIntAmount<_amount)
                                                            setState(() {
                                                              newAmount = _amount-int.parse(walletBalance.toString());
                                                              deductedWalletAmount=walletIntAmount.toString();
                                                              // needToPay=true;
                                                              // paymentValue=1;
                                                            });
                                                          else if(walletIntAmount>=_amount){
                                                            setState(() {
                                                              newAmount =0;
                                                              // needToPay=false;
                                                              // paymentValue=1;
                                                            });
                                                            deductedWalletAmount=(_amount.round()).toString();
                                                            // print(deductedWalletAmount);
                                                          }
                                                        }else{
                                                          setState(() {
                                                            newAmount = null;
                                                            // needToPay=true;
                                                            // paymentValue=1;
                                                          });

                                                        }
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
                                                                  width: deductFromWallet == true ? 2.0 : 2.0,
                                                                  color: deductFromWallet == true ? btnColor : btnColor.withOpacity(0.1)
                                                              ),
                                                              borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0) //                 <--- border radius here
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text('Deduct From Wallet Balance'.tr),
                                                                Spacer(),
                                                                deductFromWallet == true ? Icon(Icons.check, color: btnColor,) : Center()
                                                              ],
                                                            ),
                                                          ),
                                                          deductFromWallet == true ?
                                                          newAmount == null ?
                                                          Text("Pay Amount: Rs.".tr + _amount.toString()) :
                                                          Text("Pay Amount: Rs.".tr + newAmount.toString()) :
                                                          Container(),
                                                        ],
                                                      )
                                                  ),

                                                // adjust from wallet new
                                                if(activeWalletAdjustMethod == 1)
                                                  InkWell(
                                                      onTap: (){
                                                        bool value = deductFromWallet == true ? false : true;

                                                        if(value == true){
                                                          _makeCheckoutEnableDisable(222);
                                                        }else{
                                                          _makeCheckoutEnableDisable(000);
                                                        }

                                                        // unset razorpay checkout
                                                        _paymentMeth = 1;

                                                        setState(() {
                                                          deductFromWallet=value!;
                                                        });

                                                        final walletIntAmount=int.parse(walletBalance.toString());
                                                        if(value??false){
                                                          if(walletIntAmount<_amount)
                                                            setState(() {
                                                              newAmount = _amount-int.parse(walletBalance.toString());
                                                              deductedWalletAmount=walletIntAmount.toString();
                                                              _paymentMeth = 4; // also for razor checkot
                                                              // needToPay=true;
                                                              // paymentValue=1;
                                                            });
                                                          else if(walletIntAmount>=_amount){
                                                            setState(() {
                                                              newAmount =0;
                                                              // needToPay=false;
                                                              // paymentValue=1;
                                                            });
                                                            deductedWalletAmount=(_amount.round()).toString();
                                                            // print(deductedWalletAmount);
                                                          }
                                                        }else{
                                                          setState(() {
                                                            newAmount = null;
                                                            // needToPay=true;
                                                            // paymentValue=1;
                                                          });

                                                        }
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
                                                                  width: deductFromWallet == true ? 2.0 : 2.0,
                                                                  color: deductFromWallet == true ? btnColor : btnColor.withOpacity(0.1)
                                                              ),
                                                              borderRadius: BorderRadius.all(
                                                                  Radius.circular(10.0) //                 <--- border radius here
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text('Adjust with Razorpay'.tr),
                                                                Spacer(),
                                                                deductFromWallet == true ? Icon(Icons.check, color: btnColor,) : Center()
                                                              ],
                                                            ),
                                                          ),
                                                          _paymentMeth == 4 ?
                                                          newAmount == null ?
                                                          Text("Pay Amount: Rs.".tr + _amount.toString()) :
                                                          Text("Pay Amount: Rs.".tr + newAmount.toString()) :
                                                          Container(),
                                                        ],
                                                      )
                                                  ),

                                                SizedBox(height: 10,),

                                                needToPay ?
                                                Column(
                                                  children: [
                                                    // _patientDetailsArgs.payNowActive!="1"?
                                                    // Container():
                                                    Column(
                                                      children: [
                                                        /*ListTile(
                          title:  Text('Pay Now'.tr),
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
                                                        /*
                        * Razorpay method
                        * Value should 0
                        * Variable _paymentMeth
                        * */
                                                        if(activeRazorPayMethod == 1)
                                                          InkWell(
                                                              onTap: (){
                                                                bool value = _paymentMeth == 0 ? true : false;
                                                                if(value == true){
                                                                  _makeCheckoutEnableDisable(333);
                                                                }else{
                                                                  _makeCheckoutEnableDisable(000);
                                                                }

                                                                setState(() {
                                                                  _paymentMeth = _paymentMeth == 0 ? 1 : 0;
                                                                  deductFromWallet = false;
                                                                  newAmount = _amount;
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
                                                                          Radius.circular(50.0) //                 <--- border radius here
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
                                                                  newAmount == null ?
                                                                  Text("Pay Amount: Rs.".tr + _amount.toString()) :
                                                                  Text("Pay Amount: Rs.".tr + newAmount.toString()) :
                                                                  Container(),
                                                                ],
                                                              )
                                                          ),

                                                        // other payment methods are commented by hassan005004
                                                        /*paymentValue == 1
                            ? ListTile(
                          title: const Text('Paypal Payment'),
                          leading: Radio(
                            value: 1,
                            groupValue: _paymentMeth,
                            onChanged: (int? value) {
                              setState(() {
                                _paymentMeth = value!;
                              });
                            },
                          ),
                        )
                            : Container(),
                        paymentValue == 1
                            ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Note: Please use this id and password for paypal test payment\nEmail: MyclinicTest@paypal.com\nPassword: 12345678",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                            : Container(),
                        paymentValue == 1
                            ? ListTile(
                          title: const Text('Paystack Payment'),
                          leading: Radio(
                            value: 2,
                            groupValue: _paymentMeth,
                            onChanged: (int? value) {
                              setState(() {
                                _paymentMeth = value!;
                              });
                            },
                          ),
                        )
                            : Container(),*/
                                                        /*paymentValue == 1
                            ? ListTile(
                          title: const Text('Razorpay Indian Payment'),
                          leading: Radio(
                            value: 0,
                            groupValue: _paymentMeth,
                            onChanged: (int? value) {
                              setState(() {
                                _paymentMeth = value!;
                              });
                            },
                          ),
                        )
                            : Container(),*/
                                                      ],
                                                    ),


                                                    /*args.serviceName == "Online"
                        ? Container()
                        :  _patientDetailsArgs.payLaterActive=="1"?ListTile(
                      title:  Text('Pay Later'.tr),
                      leading: Radio(
                        value: 0,
                        groupValue: paymentValue,
                        onChanged: (int? value) {
                          setState(() {
                            paymentValue = value!;
                          });
                        },
                      ),
                    ): Container()*/
                                                  ],
                                                ):Container(),

                                              ],
                                            );
                                          }
                                        ),
                                      ),
                                    )
                                ),
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
      serviceTimeMin,
      setTime,
      selectedDate,
      String doctName,
      String department,
      String hName,
      String doctId,
      paymentStatus,
      paymentId,
      payMode,
      cityId,
      clinicId,
      deptId) async {

    setState(() {
      _isLoading = true;
      _isBtnDisable = "";
    });

    if(deductFromWallet) {
      if(deductedWalletAmount!="0"&&deductedWalletAmount!=null){

        await UserService.addDataWallet(payment_id: "XXXXXX",
            amount: deductedWalletAmount ?? "0",
            status: "1",
            desc: "Deduct For Appointment",
            prAmount: walletBalance ?? "0");

        _getUserController.getData();

        final notificationModel = NotificationModel(
            title: "Debited!",
            body: "${deductedWalletAmount ?? "0"}\u{20B9} successfully debited from your wallet, Deduct For Appointment",
            uId: _uId,
            routeTo: "",
            sendBy: "user",
            sendFrom: _uName,
            sendTo: "Admin");

        await NotificationService.addData(notificationModel);

        await HandleLocalNotification.showNotification(
          "Debited", //title
          "${deductedWalletAmount ?? "0"}\u{20B9} successfully debited from your wallet, Deduct For Appointment", // body
        );

      }
    }

    // List dateC = selectedDate.toString().split("-");
    final pattern = RegExp('\\s+'); //remove all space
    final patientName = pFirstName + pLastName;
    String searchByName = patientName.toLowerCase().replaceAll(pattern, ""); //lowercase all letter and remove all space

    final appointmentModel = AppointmentModel(
        pFirstName: pFirstName,
        pLastName: pLastName,
        pPhn: pPhn,
        pEmail: pEmail,
        age: age,
        gender: gender,
        pCity: pCity,
        description: desc,
        serviceName: serviceName,
        serviceTimeMin: serviceTimeMin,
        appointmentTime: setTime,
        appointmentDate: selectedDate,
        appointmentStatus: "Pending",
        searchByName: searchByName,
        uId: _uId,
        userId: Provider.of<AuthProvider>(context, listen: false).activeUser.id,
        uName: _uName,
        doctId: doctId,
        department: department,
        doctName: doctName,
        hName: hName,
        paymentStatus: paymentStatus,
        oderId: paymentId,
        amount: _amount.toString(),
        paymentMode: payMode,
        deptId: deptId,
        cityId: cityId,
        clinicId: clinicId,
        isOnline: isOnline ? "true" : "false",
        dateC: selectedDate,//dateC[2] + "-" + dateC[0] + "-" + dateC[1],
        type: widget.type,
    ); //initialize all values

    final insertStatus = await AppointmentService.addData(appointmentModel);
    // print("::::::::${appointmentModel.toJsonAdd()}:::::::::::::;$insertStatus");
    if (insertStatus != "error") {

      AppointmentModel appointment = appointmentModelFromJsonSingle(insertStatus);
      // final updatedTimeSlotsStatus = await UpdateData.updateTimeSlot(
      //     serviceTimeMin, setTime, selectedDate, insertStatus, doctId);
      // //if appoint details added successfully added
      //
      // if (updatedTimeSlotsStatus == "") {

      final notificationModel = NotificationModel(
          title: "Successfully Booked!",
          body: "Appointment has been booked on $selectedDate. Waiting for confirmation",
          uId: _uId,
          routeTo: "/Appointmentstatus",
          sendBy: "user",
          sendFrom: _uName,
          sendTo: "Admin");

      final notificationModelForAdmin = NotificationModel(
          title: "New Appointment",
          body:
          "$pFirstName $pLastName booked an appointment on $selectedDate at $setTime",
          uId: _uId,
          sendBy: _uName,
          doctId: doctId);

      final msgAdded = await NotificationService.addData(notificationModel);

      if (msgAdded == "success") {
        await NotificationService.addDataForAdmin(notificationModelForAdmin);
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        try {
          _prefs.getStringList("patientData")!.clear();
          _prefs.setBool("inPaymentState", false);
        } catch (e) {
          // print(e);
        }
        ToastMsg.showToastMsg("Successfully Booked".tr);
        _handleSendNotification(pFirstName, pLastName, pEmail, serviceName, selectedDate, setTime, doctId, appointment.id);
      } else if (msgAdded == "error") {
        ToastMsg.showToastMsg("Something went wrong. try again 1".tr);

        Navigator.pop(context);
      }
      // } else {
      //   ToastMsg.showToastMsg("Something went wrong. try again");
      //   Navigator.pop(context);
      // }
    } else {
      ToastMsg.showToastMsg("Something went wrong. try again 2".tr);
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
      _isBtnDisable = "false";
    });
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

  void _handleSendNotification(String firstName, String lastName, pEmail,
      String serviceName, String selectedDate, String setTime, doctId, appointmentId) async {
    setState(() {
      _isLoading = true;
      _isBtnDisable = "";
    });
    await _setAdminFcmId(doctId);

    await HandleLocalNotification.showNotification(
      "Successfully Booked", //title
      "Appointment has been booked on $selectedDate. Waiting for confirmation", // body
    );

    await UpdateData.updateIsAnyNotification("usersList", _uId, true);

    //send notification to admin app for booking confirmation
    // print("++++++++++++admin$_adminFCMid");
    // print("++++++++++++doctor$doctorFcm");
    await HandleFirebaseNotification.sendPushMessage(
        _adminFCMid, //admin fcm
        "New Appointment", //title
        "$firstName $lastName booked an appointment on $selectedDate at $setTime" //body
    );

    await HandleFirebaseNotification.sendPushMessage(
        doctorFcm, //admin fcm
        "New Appointment", //title
        "$firstName $lastName booked an appointment on $selectedDate at $setTime" //body
    );

    await UpdateData.updateIsAnyNotification("doctorsNoti", doctId, true);
    await UpdateData.updateIsAnyNotification("profile", "profile", true);


    await ChatApi().PatinetSendMessage(
        appointmentId.toString(),
        _uId.toString(),
        Provider.of<AuthProvider>(context, listen: false).activeUser.id.toString(),
        doctId, 2, 8, "Call", null);
    Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => Meeting(
            uid: _uId,
            doctid: doctId,
            email: pEmail,
          )),
    );

    // Navigator.of(context).pushNamedAndRemoveUntil(
    //     '/Appointmentstatus', ModalRoute.withName('/HomePage'));
  }


}
