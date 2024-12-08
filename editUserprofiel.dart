import 'dart:io';

import 'package:demopatient/Service/uploadImageService.dart';
import 'package:demopatient/model/userModel.dart';
import 'package:demopatient/service/userService.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/dialogBox.dart';
import 'package:demopatient/utilities/inputfields.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/utilities/imagePicker.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditUserProfilePage extends StatefulWidget {
  const EditUserProfilePage({Key? key}) : super(key: key);
  @override
  _EditUserProfilePageState createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  bool _isLoading = false;
  String _imageUrl = "";
  List<XFile> _images = [];
  String? _selectedGender;
  String _isEnableBtn = "false";
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _uIdController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _mrdController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _setData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _uIdController.dispose();
    _idController.dispose();
    super.dispose();
  }

  _takeConfirmation() {
    DialogBoxes.confirmationBox(
        context,
        "Update".tr,
        "Are you sure you want to update profile details".tr,
        _handleUpdate); //take a confirmation form the user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationStateWidget(
        title: "Update".tr,
        onPressed: _takeConfirmation,
        clickable: _isEnableBtn,
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          CAppBarWidget(title: "Profile".tr), //common app bar
          Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child:
                  //_stopBooking?showDialogBox():
                  Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: IBoxDecoration.upperBoxDecoration(),
                      child: _buildContent())),
        ],
      ),
    );
  }

  _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == ""||_selectedGender==null) {
        ToastMsg.showToastMsg("Please select gender".tr);
      } else {
        setState(() {
          _isEnableBtn = "";
          _isLoading = true;
        });
        if (_imageUrl == "" && _images.length == 0)
          _updateDetails("");
        else if (_imageUrl != "")
          _updateDetails(_imageUrl);
        else if (_imageUrl == "" && _images.length > 0) _handleUploadImage();
      } // _images.length > 0 ? _uploadImg() : _uploadNameAndDesc("");
    }
  }

  _updateDetails(imageDownloadUrl) async {
    final pattern = RegExp('\\s+'); //remove all space
    final fullName = _firstNameController.text + _lastNameController.text;
    String searchByName = fullName.toLowerCase().replaceAll(pattern, "");
    final userModel = UserModel(
        imageUrl: imageDownloadUrl,
        email: _emailController.text,
        lastName: _lastNameController.text,
        firstName: _firstNameController.text,
        age: _ageController.text,
        city: _cityController.text,
        uId: _uIdController.text,
        searchByName: searchByName,
        gender: _selectedGender,
        mrd: _mrdController.text,
        pNo: _phoneNumberController.text);
    // print(">>>>>>>>>>>>>>>>>>>>>>${userModel.toUpdateJson()}");
    final res = await UserService.updateData(userModel);
    if (res == "success") {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString("firstName", _firstNameController.text);
      prefs.setString("lastName", _lastNameController.text);
      prefs.setString("imageUrl", imageDownloadUrl);

      ToastMsg.showToastMsg("Successfully Updated".tr);
    } else if (res == "error") {
      ToastMsg.showToastMsg("Something went wrong".tr);
    }
    setState(() {
      _isEnableBtn = "false";
      _isLoading = false;
    });
  }

  void _handleUploadImage() async {
    final res = await UploadImageService.uploadImages(_images[0]);
    if (res == "0")
      ToastMsg.showToastMsg(
          "Sorry, only JPG, JPEG, PNG, & GIF files are allowed to upload");
    else if (res == "1")
      ToastMsg.showToastMsg("Image size must be less the 1MB".tr);
    else if (res == "2")
      ToastMsg.showToastMsg(
          "Sorry, only JPG, JPEG, PNG, & GIF files are allowed to upload");
    else if (res == "3" || res == "error")
      ToastMsg.showToastMsg("Something went wrong".tr);
    else if (res == "")
      ToastMsg.showToastMsg("Something went wrong".tr);
    else {
      await _updateDetails(res);
    }

    setState(() {
      _isEnableBtn = "false";
      _isLoading = false;
    });
  }

  Widget _readOnlyInputField(String labelText, controller) {
    return InputFields.readableInputField(controller, labelText, 1);
  }

  Widget _ageInputField(String labelText, controller) {
    return InputFields.commonInputField(controller, labelText, (item) {
      if (item.length > 0 && item.length <= 3)
        return null;
      else if (item.length > 3)
        return "Enter valid age".tr;
      else
        return "Enter age".tr;
    }, TextInputType.number, 1);
  }

  Widget _inputField(String labelText, String validatorText, controller) {
    return InputFields.commonInputField(controller, labelText, (item) {
      return item.length > 0 ? null : validatorText;
    }, TextInputType.text, 1);
  }

  Widget _emailInputField() {
    return InputFields.commonInputField(_emailController, "Email".tr, (item) {
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
    }, TextInputType.emailAddress, 1);
  }

  Widget _phnNumInputField() {
    return InputFields.readableInputField(
        _phoneNumberController, "Mobile Number".tr, 1);
  }

  Widget _profileImage() {
    return Center(
      child: Container(
        height: 150,
        width: 150,
        //  color: Colors.green,
        child: Stack(
          children: <Widget>[
            ClipOval(
                child: _imageUrl == ""
                    ? Image.file(File(_images[0].path),
                      width: 150,
                      height: 150,
                    )
                    //:Container()
                    : ImageBoxFillWidget(imageUrl: _imageUrl)),
            Positioned(
                top: -5,
                right: -10,
                child: IconButton(
                  onPressed: _removeImage,
                  icon: Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                    size: 30,
                  ),
                ))
          ],
        ),
      ),
    );

    //   ClipRRect(
    //     borderRadius: //BorderRadius.circular(8.0),
    //     child:  Image.network( )
    // );
  }

  Widget _circularIcon() {
    return Center(
      child: Container(
        height: 150,
        width: 150,
        child: GestureDetector(
          onTap: _handleImagePicker,
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.camera_enhance_rounded,
                size: 50, color: appBarColor),
          ),
        ),
      ),
    );
  }

  void _handleImagePicker() async {
    final res = await ImagePickerOld.loadAssets(_images, mounted, 1);
    setState(() {
      _images = res;
    });
  }

  void _removeImage() {
    setState(() {
      _images.clear();
      _imageUrl = "";
    });
  }

  _genderDropDown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: DropdownButton<String>(
        focusColor: Colors.white,
        value: _selectedGender,
        //elevation: 5,
        style: TextStyle(color: Colors.white),
        iconEnabledColor: appBarColor,
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

  _buildContent() {
    return _isLoading
        ? LoadingIndicatorWidget()
        : Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 20),
                if (_imageUrl == "")
                  if (_images.length == 0) _circularIcon() else _profileImage()
                else
                  _profileImage(),
                InputFields.readableInputField(_mrdController, "MRD", 1),
                _inputField(
                    "First Name".tr, "Enter first name".tr, _firstNameController),
                _inputField(
                    "Last Name".tr, "Enter last name".tr, _lastNameController),
                _inputField("City".tr, "Enter city".tr, _cityController),
                _ageInputField("Age".tr, _ageController),
                _genderDropDown(),
                _emailInputField(),
                _phnNumInputField(),
                _readOnlyInputField("User Id".tr, _uIdController),
              ],
            ),
          );
  }

  void _setData() async {
    setState(() {
      _isLoading = true;
    });
    final user = await UserService.getData();
    if(user.length > 0) {
      _emailController.text = user[0].email!;
      _lastNameController.text = user[0].lastName!;
      _firstNameController.text = user[0].firstName!;
      _firstNameController.text = user[0].firstName!;
      _phoneNumberController.text = user[0].pNo!;
      _imageUrl = user[0].imageUrl!;
      _cityController.text = user[0].city!;
      _uIdController.text = user[0].uId!; //firebase id
      _idController.text = user[0].id!;
      _ageController.text = user[0].age!;
      _selectedGender = user[0].gender!;
      _mrdController.text =
      user[0].mrd == "" || user[0].mrd == null ? "" : user[0].mrd;
    }
    setState(() {
      _isLoading = false;
    });
  }
}
