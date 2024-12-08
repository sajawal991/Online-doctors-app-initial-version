import 'dart:async';
import 'package:demopatient/Screen/profile/SwitchProfileScreen.dart';
import 'package:demopatient/Screen/registerUserPage.dart';
import 'package:demopatient/Service/AuthService/authservice.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/inputfields.dart';
import 'package:demopatient/widgets/countrypicker.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:demopatient/widgets/buttonsWidget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Module/User/Provider/auth_provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _phoneNo = "";
  String _verificationId = "";
  String _smsCode = "";
  String _selectedCounteryCode = "";

  bool _otpInputFieldError = false;
  bool _codeSent = false;
  bool _isLoginBtnPressed = false;
  bool bodyLoading = false;
  bool _isVerifyBtnPressed = false;
  //TextEditingController _otpController=TextEditingController();
  TextEditingController _countryCodeControlller = TextEditingController();
  TextEditingController __phnNumberControlller = TextEditingController(text: '1234567890');

  Timer? _timer;
  int _start = 60;
  // ..text = "123456";

  // StreamController<ErrorAnimationType> _errorController;

  @override
  void initState() {
    // TODO: implement initState
    //_errorController = StreamController<ErrorAnimationType>();
    checkLoggedIn();
    super.initState();
  }

  void dispose() {
    // TODO: implement dispose
    // _errorController.close();
    //  _otpController.dispose();
    _countryCodeControlller.dispose();
    __phnNumberControlller.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      //resizeToAvoidBottomInset: false,
      body: bodyLoading
          ? LoadingIndicatorWidget()
          : Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(gradient: gradientColor),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _adminImage(),
                      Text("Dr. Jyothi Kocherla",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontFamily: "OpenSans-ExtraBoldItalic")),
                      // Image(image: AssetImage("assets/images/clinicLogo.png")),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _codeSent
                                        ? Container()
                                        : _countryCodeInputField(),
                                    _codeSent
                                        ? Container()
                                        : _selectedCounteryCode == ""
                                            ? Container()
                                            : SizedBox(height: 10),
                                    _codeSent
                                        ? Container()
                                        : _selectedCounteryCode == ""
                                            ? Container()
                                            : _phnInputField(),
                                    _codeSent
                                        ? Container()
                                        : SizedBox(height: 10),
                                    _codeSent
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("Enter OTP".tr),
                                          )
                                        : Container(),
                                    _codeSent ? _otpInputField() : Container(),
                                    _otpInputFieldError
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Please enter a valid otp".tr,
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ))
                                        : Container(),
                                    _codeSent
                                        ? Container()
                                        : SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _codeSent
                                            ? _isVerifyBtnPressed
                                                ? Container()
                                                : _resetBtn()
                                            : Container(),
                                        _codeSent
                                            ? SizedBox(
                                                width: 10,
                                              )
                                            : Container(),
                                        _codeSent
                                            ? _isVerifyBtnPressed
                                                ? LoadingIndicatorWidget()
                                                : _verifyBtn()
                                            : _isLoginBtnPressed
                                                ? LoadingIndicatorWidget()
                                                : loginBtn(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ),
                      Text("Test Country Code: +91",style: TextStyle(
                          fontSize: 16,
                          color: Colors.white),),
                      SizedBox(height: 10,),
                      Text("Test Phone Number: 1234567890",style: TextStyle(
                          fontSize: 16,
                          color: Colors.white),),
                      SizedBox(height: 10),
                      Text("Test OTP: 123456",style: TextStyle(
                          fontSize: 16,
                          color: Colors.white),)
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _adminImage() {
    return Container(
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/icon/dr.png",
              height: 100,
              fit: BoxFit.fill,

            ),
          ),
        ),
      ),
    );
  }

  _countryCodePicker() async {
    final country = await CountryPicker.countryCodePicker(context);
    if (country != null) {
      // print("Selected Country is: ${country.callingCode}");

      setState(() {
        _countryCodeControlller.text = country.callingCode;
        _selectedCounteryCode = country.callingCode;

        // country.callingCode;
      });
    }
  }

  Widget _resetBtn() {
    return SmallButtonsWidget(
      title: _start == 0 ? "Resend".tr : "Resend".tr+ "$_start(s)", //"Resend",
      onPressed: _start != 0
          ? null
          : () {
              setState(() {
                _start = 60;
                _codeSent = false;
                _isLoginBtnPressed = false;
              });

              //
            },
    );
  }

  Widget loginBtn() {
    return SmallButtonsWidget(
      title: "Login".tr,
      onPressed: _selectedCounteryCode == "" || _phoneNo == ""
          ? null
          : () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoginBtnPressed = true;
                  _isVerifyBtnPressed = false;
                });

                _handleAuth();
              }
            },
    );
  }

  Widget _verifyBtn() {
    return SmallButtonsWidget(
      onPressed: () {
        _formKey.currentState!.validate();
        if (_smsCode.length != 6) {
          // _errorController
          //     .add(ErrorAnimationType.shake); // Triggering error shake animation

          setState(() {
            _otpInputFieldError = true;
          });
        } else {
          setState(() {
            _otpInputFieldError = false;
          });
          setState(() {
            _isLoginBtnPressed = false;
            _isVerifyBtnPressed = true;
          });
          _handleAuth();
        }
      },
      title: "Verify".tr,
    );
  }

  Widget _otpInputField() {
    return InputFields.otpInputField(
      context,
      //  _errorController,
      //  _otpController,
      (value) {
        // print(value);
        setState(() {
          this._smsCode = value;
        });
      },
    );
  }

  Widget _phnInputField() {
    return InputFields.phnInputField(
      context,
      __phnNumberControlller,
      (val) {
        setState(() {
          this._phoneNo = "$val";
        });
      },
    );
  }

  Widget _countryCodeInputField() {
    return InputFields.countryCodeInputField(
      context,
      _countryCodeControlller,
      () {
        _countryCodePicker();
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
    );
  }

  Future<void> _verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified =
        (AuthCredential authResult) async {
      //AuthService()
      bool verified =
          await AuthService().signIn(authResult).catchError((onError) {
        // print(onError);
        return false;
      });
      if (verified) {
        _timer!.cancel();
        setState(() {
          _start = 60;
          _codeSent = false;
          _isLoginBtnPressed = false;
        });

        Fluttertoast.showToast(
            msg: "Signed In".tr,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterUserPage()),
        );
      }
    };

    final PhoneVerificationFailed verificationfailed =
        (FirebaseAuthException authException) {
      // print('${authException.message}');
      Fluttertoast.showToast(
          msg: "Something went wrong".tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0);
      setState(() {
        _isLoginBtnPressed = false;
      });
    };

    final PhoneCodeSent smsSent = (String? verId, [int? forceResend]) {
      this._verificationId = verId!;
      setState(() {
        this._codeSent = true;
      });
      startTimer();
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this._verificationId = verId;
    };

    await FirebaseAuth.instance
        .verifyPhoneNumber(
            phoneNumber: phoneNo, //country code with phone number
            timeout: const Duration(seconds: 60),
            verificationCompleted: verified,
            verificationFailed: verificationfailed, //error handling function
            codeSent: smsSent,
            codeAutoRetrievalTimeout: autoTimeout)
        .catchError((e) {
      // print(e);
    });
  }

  _handleAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("phn", _phoneNo);
    prefs.setString("phone", __phnNumberControlller.text);
    if (_codeSent) {
      bool verified = await AuthService()
          .signInWithOTP(_smsCode, _verificationId)
          .catchError((onError) {
        return false;
      });
      if (verified) {
        Fluttertoast.showToast(
            msg: "Signed In",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0);
        setState(() {
          _start = 60;
          _codeSent = false;
          _isLoginBtnPressed = false;
          _timer!.cancel();
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterUserPage()),
        );
      } else {
        Fluttertoast.showToast(
            msg: "Please enter a valid otp".tr,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0);
        setState(() {
          _isVerifyBtnPressed = false;
        });
      }
    } else
      _verifyPhone("$_selectedCounteryCode$_phoneNo"); //handle auto fill otp
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          // print("Stop time");
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void checkLoggedIn() async {

    setState(() {
      bodyLoading = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    final isLoggedIn = preferences.getBool('login') ?? false;

    if (isLoggedIn) {

      await Provider.of<AuthProvider>(context, listen: false).callApi();

      if(Provider.of<AuthProvider>(context, listen: false).users.length > 1){
        Get.off(SwitchProfileScreen());
      }else{
        Provider.of<AuthProvider>(context, listen: false).setSingleProfileOnReopenApp();
        Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
      }

    }

    setState(() {
      bodyLoading = false;
    });
  }
}
