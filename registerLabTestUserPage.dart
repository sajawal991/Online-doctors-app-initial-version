import 'package:demopatient/Screen/labTest/labTestConfimationPage.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/inputfields.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPatientLabTest extends StatefulWidget {
  final testName;
  final testId;
  final price;
  final clinicName;
  final locationName;
  final cliniId;
  RegisterPatientLabTest({Key? key,this.testName,this.price,this.testId,this.locationName,this.clinicName,this.cliniId}) : super(key: key);

  @override
  _RegisterPatientLabTestState createState() => _RegisterPatientLabTestState();
}

class _RegisterPatientLabTestState extends State<RegisterPatientLabTest> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController _desController = TextEditingController();
  String? _selectedGender;
  var _isBtnDisable = "false";

  @override
  void initState() {
    // TODO: implement initState
    _getAndSetData();
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    ageController.dispose();
    _cityController.dispose();
    _desController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationStateWidget(
          title: "Next".tr,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_selectedGender == "Gender"||_selectedGender==null) {
                ToastMsg.showToastMsg("Please select gender".tr);
              } else {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LabTestConfirmationPage(
                    clinicId: widget.cliniId,
                    price: widget.price,
                    testId: widget.testId,
                    testName: widget.testName,
                    firstName: _firstNameController.text,
                     lastName: _lastNameController.text,
                    gender:_selectedGender ,
                    age: ageController.text,
                    email: _emailController.text,
                    desc: _desController.text,
                    city: _cityController.text,
                    phoneNumber:_phoneNumberController.text ,
                    cliniName: widget.clinicName,
                    location: widget.locationName,
                  ),
                ),
              );

              }
            }
          },
          clickable: _isBtnDisable,
        ),
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CAppBarWidget(title: "Register Patient".tr),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: IBoxDecoration.upperBoxDecoration(),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8.0, left: 15, right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            "Phone Number*".tr,
                            TextInputType.number,
                            _phoneNumberController,
                            1,
                                (item) {
                              return item.length > 8
                                  ? null
                                  : "Enter a valid Phone number".tr;
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
                            ageController,
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
                          Container(
                            width: double.infinity,
                            child: _genderDropDown(),
                          ),
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
                          InputFields.textInputFormField(
                            context,
                            "Description, About your Problem".tr,
                            TextInputType.text,
                            _desController,
                            5,
                                (item) {
                              if (item.isEmpty)
                                return null;
                              else {
                                return item.length > 0
                                    ? null
                                    : "Enter Description".tr;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  _genderDropDown() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 0, right: 15),
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
            print(value);
            _selectedGender = value!;
          });
        },
      ),
    );
  }

  void _getAndSetData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _firstNameController.text = _prefs.getString("firstName")!;
    _lastNameController.text = _prefs.getString("lastName")!;
    _phoneNumberController.text = _prefs.getString('phn')!;
    _emailController.text = _prefs.getString("email")!;
    ageController.text = _prefs.getString("age")!;
    _cityController.text = _prefs.getString("city")!;
    setState(() {
      _selectedGender = _prefs.getString("gender")!;
    });
  }
}
