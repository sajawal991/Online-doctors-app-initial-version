import 'package:demopatient/Screen/profile/SwitchProfileScreen.dart';
import 'package:demopatient/Service/Firebase/addData.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/inputfields.dart';
import 'package:demopatient/utilities/style.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:demopatient/Service/userService.dart';
import 'package:demopatient/model/userModel.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Module/User/Provider/auth_provider.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({Key? key}) : super(key: key);
  @override
  _RegisterUserPageState createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  String? _selectedGender;

  var _isBtnEnable = "true";
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    _checkUserIsRegistered();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _isLoading
            ? null
            : AppBar(
                backgroundColor: appBarColor,
                title: Text("Register".tr, style: kAppbarTitleStyle),
                centerTitle: true,
                actions: [
                  // IconButton(
                  //     icon: Icon(Icons.logout),
                  //     onPressed: () {
                  //       AuthService.signOut();
                  //     })
                ],
              ),
        bottomNavigationBar: _isLoading
            ? null
            : BottomNavigationStateWidget(
                title: "Next".tr,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedGender == "Gender"||_selectedGender ==null) {
                      Fluttertoast.showToast(
                          msg: "Please select gender".tr,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 14.0);
                    } else
                      _handleUpload();
                  }
                },
                clickable: _isBtnEnable,
              ),
        body: _isLoading
            ? LoadingIndicatorWidget()
            : Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 15, right: 15),
                  child: ListView(
                    children: <Widget>[
                      InputFields.textInputFormField(
                        context,
                        "First Name*".tr,
                        TextInputType.text,
                        _firstNameController,
                        1,
                        (item) {
                          return item.length > 0
                              ? null
                              : "Enter your first name".tr;
                        },
                      ),
                      InputFields.textInputFormField(
                        context,
                        "Last Name*".tr,
                        TextInputType.text,
                        _lastNameController,
                        1,
                        (item) {
                          return item.length > 0 ? null : "Enter last name".tr;
                        },
                      ),
                      InputFields.textInputFormField(
                        context,
                        "Email".tr,
                        TextInputType.emailAddress,
                        _emailController,
                        1,
                        (item) {
                          Pattern pattern =
                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                              r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                              r"{0,253}[a-zA-Z0-9])?)*$";
                          RegExp regex = new RegExp(pattern.toString());
                          if (item.length > 0) {
                            if (!regex.hasMatch(item) || item == null)
                              return 'Enter a valid email address'.tr;
                            else
                              return null;
                          } else
                            return null;
                        },
                      ),
                      InputFields.ageInputFormField(
                        context,
                        "Age*".tr,
                        TextInputType.number,
                        _ageController,
                        false,
                        (item) {
                          if (item.length > 0 && item.length <= 3)
                            return null;
                          else if (item.length > 3)
                            return "Enter valid age".tr;
                          else
                            return "Enter age".tr;
                        },
                      ),
                      _genderDropDown(),
                      InputFields.textInputFormField(
                        context,
                        "City*".tr,
                        TextInputType.text,
                        _cityController,
                        1,
                        (item) {
                          return item.length > 0 ? null : "Enter city".tr;
                        },
                      ),
                    ],
                  ),
                ),
              ));
  }

  void _handleUpload() async {
    String fcmId = "";
    setState(() {
      _isBtnEnable = "";
      _isLoading = true;
    });
    try {
      fcmId = await FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      // print(e);
    }

    final pattern = RegExp('\\s+'); //remove all space
    final fullName = _firstNameController.text + _lastNameController.text;
    String searchByName = fullName.toLowerCase().replaceAll(pattern, "");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString("phn");
    final pNo = prefs.getString("phone");
    final userModel = UserModel(
        uId: FirebaseAuth.instance.currentUser!.uid,
        searchByName: searchByName,
        city: _cityController.text,
        age: _ageController.text,
        gender: _selectedGender,
        email: _emailController.text,
        fcmId: fcmId,
        firstName: _firstNameController.text,
        imageUrl: "",
        lastName: _lastNameController.text,
        phone: phone,
        pNo: pNo);
    final insertStatus = await UserService.addData(userModel);
    if (insertStatus == "success") {
      await AddData.addRegisterDetails(FirebaseAuth.instance.currentUser!.uid);
      SharedPreferences preferences = await SharedPreferences.getInstance();

      await preferences.setBool("login", true);

      await _getAndSetUserData(); //get users details from database

      ToastMsg.showToastMsg("Registered Logged In".tr);


      await Provider.of<AuthProvider>(context, listen: false).callApi();

      if(Provider.of<AuthProvider>(context, listen: false).users.length > 1){
        Get.off(SwitchProfileScreen());
      }else{
        Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
      }

    } else {
      ToastMsg.showToastMsg("Something went wrong".tr);
    }
    setState(() {
      _isBtnEnable = "true";
      _isLoading = false;
    });
  }

  _checkUserIsRegistered() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString("phone") ?? "";
    // final user = FirebaseAuth.instance.currentUser;
    //  print("=======================${user.uid}===============");
    final res = await UserService.getDataByPhn(phone);
    if (res.length > 0) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool("login", true);
      await _getAndSetUserData(); //get users details from database

      await Provider.of<AuthProvider>(context, listen: false).callApi();

      if(Provider.of<AuthProvider>(context, listen: false).users.length > 1){
        Get.off(SwitchProfileScreen());
      }else{
        Navigator.of(context).pushNamedAndRemoveUntil('/HomePage', (Route<dynamic> route) => false);
      }

      setState(() {
        _isLoading = false;
      });
    } else
      setState(() {
        _isLoading = false;
      });
  }

  _getAndSetUserData() async {
    //start loading indicator
    setState(() {
      _isLoading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final phone = preferences.getString("phone") ?? "";
    // final user = FirebaseAuth.instance.currentUser;
    //  print("=======================${user.uid}===============");
    final user = await UserService.getDataByPhn(phone);
    // get all user details from database
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //set all data
    // setState(() {
    //   _uId = user[0].uId!;
    //   _uPhn = user[0].pNo!;
    // });

    prefs.setString("lastName", user[0].lastName!);
    prefs.setString("firstName", user[0].firstName!);
    prefs.setString("lastName", user[0].lastName!);
    prefs.setString("uid", user[0].uId!);
    prefs.setString("iuid", user[0].id??"");
    prefs.setString("uidp", user[0].id!);
    prefs.setString("imageUrl", user[0].imageUrl!);
    prefs.setString("email", user[0].email!);
    prefs.setString("age", user[0].age!);
    prefs.setString("gender", user[0].gender!);
    prefs.setString("city", user[0].city!);
    prefs.setString("createdDate", user[0].createdDate!);
    String fcm = "";
    try {
      fcm = await FirebaseMessaging.instance.getToken() ?? "";
      await UserService.updateFcmId(user[0].uId!, fcm);
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  _genderDropDown() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 0, right: 0),
      child: DropdownButton<String>(
        focusColor: Colors.white,
        value: _selectedGender,
        //elevation: 5,
        style: TextStyle(color: Colors.white),
        iconEnabledColor: btnColor,
        items: <String>[
          'Male',
          'Female',
          'Other',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value.tr,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        hint: Text(
          "Select Gender".tr,
        ),
        onChanged: (String? value) {
          setState(() {
            // print(value);
            _selectedGender = value!;
          });
        },
      ),
    );
  }
}
