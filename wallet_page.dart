import 'package:demopatient/Screen/paypalWebView.dart';
import 'package:demopatient/Service/Firebase/updateData.dart';
import 'package:demopatient/Service/Noftification/handleLocalNotification.dart';
import 'package:demopatient/Service/appointmentService.dart';
import 'package:demopatient/Service/notificationService.dart';
import 'package:demopatient/Service/userService.dart';
import 'package:demopatient/config.dart';
import 'package:demopatient/controller/get_user_controller.dart';
import 'package:demopatient/model/notificationModel.dart';
import 'package:demopatient/model/wallet_history_model.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
class WalletPage extends StatefulWidget {
  final GetUserController? getUserController;
  const WalletPage({Key? key,this.getUserController}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  Razorpay? _razorpay;
  bool _isLoading=false;
  ScrollController _scrollController=ScrollController();
  TextEditingController _textEditingController=TextEditingController();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  // late GetUserController? _getUserController;
  // GetUserController? _getUserController = Get.put(GetUserController(),tag: "wallet");

  String uid="";
  String uName="";
  String? prAmount;
  // final payStack = PaystackPlugin();

  @override
  void initState() {
    // TODO: implement initState
    getAndSetData();
    _textEditingController.text="1000";
    // _getUserController=widget.getUserController;
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
    // payStack.initialize(publicKey: payStackPublickKey);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay!.clear();
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    ToastMsg.showToastMsg("Payment success, please don't press back button".tr);
    _handleUpdateData(response.paymentId);

  }
  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isLoading=false;
    });
    ToastMsg.showToastMsg("Something went wrong".tr);
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isLoading=false;
    });
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          CAppBarWidget(title: "Wallet".tr),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: IBoxDecoration.upperBoxDecoration(),
              child:_isLoading?LoadingIndicatorWidget(): ListView(
                padding: EdgeInsets.all(5),
                controller: _scrollController,
                children: [
                  buildBalanceCard(),
                  buildAddMoneyContainer(),
                  // Divider(),
                  Card(
                    elevation: 0.5,
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text("Wallet History".tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                  ),

                  FutureBuilder(
                      future: UserService.getWalletHistory(), //fetch images form database
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData)
                          return snapshot.data.length == 0
                              ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("No Transaction History Found".tr,textAlign: TextAlign.center,),
                              )
                              : _buildListView(snapshot.data);
                        else if (snapshot.hasError)
                          return IErrorWidget(); //if any error then you can also use any other widget here
                        else
                          return LoadingIndicatorWidget();
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildListView(data) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
          itemCount: data.length,
        controller: _scrollController,
        shrinkWrap: true,
        itemBuilder: (context, index) {
        UserWalletHistoryModel userWalletHistoryModel=data[index];
      return Card(
        elevation: 0, // old value is .3
        // color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.white,
        child: ListTile(
            contentPadding: EdgeInsets.all(10),
            title: Text("${userWalletHistoryModel.status=="0"?"Credited".tr:"Deducted".tr} \u{20B9}${userWalletHistoryModel.amount??""}",
                style: TextStyle(
                    color: userWalletHistoryModel.status=="0"?Colors.green:Colors.red),
                ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(userWalletHistoryModel.description??""),
            SizedBox(height: 5),
            Text(userWalletHistoryModel.dateTTime??""),
          ],
        )),
      );
    });
  }

  buildBalanceCard() {
    return Card(
      elevation: 0, // old value is 10 + hassan005004
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Color(0xFF414370),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20,20,20,10),
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
                widget.getUserController == null ?
                Text("",style: TextStyle(
                    fontSize: 17,
                    color: Colors.white
                )) :
                Obx(() {
                  if (!widget.getUserController!.isError.value) { // if no any error
                    if (widget.getUserController!.isLoading.value) {
                      return const Text("\u{20B9}",style: TextStyle(
                          fontSize: 17,
                          color: Colors.white
                      ));
                    } else if (widget.getUserController!.dataList.isEmpty) {
                      return  Text("\u{20B9}0",style: TextStyle(
                          fontSize: 17,
                          color: Colors.white
                      ));
                    } else {
                      return  Text("\u{20B9}${widget.getUserController?.dataList[0].amount.toString()=="null"?
                      "0":widget.getUserController?.dataList[0].amount.toString()
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
    );
  }

  buildAddMoneyContainer() {
    return Card(
      elevation: 0, // old value is 5 + hassan005004
      // color: bgColor,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child:
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Text("Add Money To Wallet".tr,style: TextStyle(
              fontFamily: "OpenSans-SemiBold",
              fontSize: 16
            ),),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Container(
                decoration:BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  )
                ]),
                child: TextFormField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    cursorColor: btnColor,
                  controller: _textEditingController,
                  validator: (String? item){
                      if(item!.length==0){
                        return "Enter Amount".tr;

                      }else if(item.length>0){
                        if(_textEditingController.text=="0"||int.parse(_textEditingController.text)>10000){
                          return "Enter a amount between 1 to 10,000 only".tr;
                        }else{
                          return null;
                        }
                      }else return null;

                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: "\u{20B9}",
                    //   labelText: lableText,
                    hintText: "1000",
                    fillColor: Colors.white,
                    filled: true,
                    // labelStyle: TextStyle(
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.w500
                    // ),
                    contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.grey.shade400)),
                    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: Colors.red, width: 2.0)),
                    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide:const BorderSide(color: Colors.red, width: 2.0)),
                  )
                ),
              ),
            ),
            SizedBox(height: 10),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: (){
              if(_formKey.currentState!.validate()){
                // hassan005004
                // paymentModeBox();
                openCheckout();
              }
            },
            child: Text("Topup Wallet".tr, style: TextStyle(fontSize: 14)))

          ],
        ),
      ),
    );
  }

  void _handleUpdateData(paymentId) async{
    setState(() {
      _isLoading=true;
    });
    await UserService.addDataWallet(
        payment_id: paymentId?.toString()??"",
        amount: _textEditingController.text,
        status: "0",
        prAmount: prAmount??"0",
        desc: "Balance Created By User");
    // _getUserController!.getData();
    final notificationModel = NotificationModel(
        title: "Credited!",
        body: "${_textEditingController.text}\u{20B9} successfully credited to your wallet",
        uId: uid,
        routeTo: "",
        sendBy: "user",
        sendFrom: uName,
        sendTo: "Admin");
  await NotificationService.addData(notificationModel);
    await HandleLocalNotification.showNotification(
      "Credit", //title
      "${_textEditingController.text}\u{20B9} successfully credited to your wallet", // body
    );
    await UpdateData.updateIsAnyNotification("usersList", uid, true);
    setState(() {
      _isLoading=false;
    });
  }
  void openCheckout() async {
    setState(() {
      _isLoading=true;
    });
    final getUserDetails=await UserService.getData();
    prAmount=getUserDetails[0].amount??"0";
    var options = {
      'key': razorpayKeyId,
      'amount': int.parse(_textEditingController.text) * 100,
      'name':  getUserDetails[0].firstName??"" +
          " " +getUserDetails[0].lastName!,
      'description': "Add Money To Wallet",
      'prefill': {
        'contact': getUserDetails[0].pNo,
        'email': getUserDetails[0].email
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
  void openCheckoutPayPal() async {
    setState(() {
      _isLoading=true;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalPayment(
          itemPrice: int.parse(_textEditingController.text),
          onFinish: (number) async {
            ToastMsg.showToastMsg(
                "Payment success, please don't press back button".tr);
            _handleUpdateData(number.toString(),);
            //  _handleAddData(isCOD: false,paymentID: number,paymentMode:"paypal");
          },
        ),
      ),
    );

  }

  void getAndSetData()async {
    setState(() {
       _isLoading=true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uName =
          prefs.getString("firstName")! + " " + prefs.getString("lastName")!;
      uid = prefs.getString("uid")!;
    });
    setState(() {
      _isLoading=false;
    });
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
              // commented by hassan005004
              /*Card(
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
              ),*/
              /*Card(
                elevation: .1,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: (){
                    Navigator.of(context).pop();
                    print("llll");
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
              ),*/

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
  openCheckOutPayStack()async{
    // setState(() {
    //   _isLoading=true;
    // });
    // final getAccessCode=await AppointmentService.getPayStackAcceessCodeData("customer@email.com", int.parse(_textEditingController.text) * 100);
    // if(getAccessCode!="error"){
    //   if (getAccessCode['status']==true){
    //     Charge charge = Charge()
    //       ..amount =   int.parse(_textEditingController.text) * 100
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
    //       // print("Ref No");
    //       // print(response.reference);
    //       _handleUpdateData( response.reference);
    //       ToastMsg.showToastMsg("Payment success, please don't press back button".tr);
    //     }
    //     else ToastMsg.showToastMsg("Payment Failed".tr);
    //     // print(response);
    //
    //   }else ToastMsg.showToastMsg("Something went wrong".tr);
    //
    // }else ToastMsg.showToastMsg("Something went wrong".tr);
  }
}
