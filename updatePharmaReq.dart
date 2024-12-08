import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:demopatient/Screen/showPrescriptionImae.dart';
import 'package:demopatient/Service/Firebase/updateData.dart';
import 'package:demopatient/Service/Noftification/handleFirebaseNotification.dart';
import 'package:demopatient/Service/notificationService.dart';
import 'package:demopatient/Service/pharmaService.dart';
import 'package:demopatient/Service/pharma_req_service.dart';
import 'package:demopatient/Service/uploadImageService.dart';
import 'package:demopatient/model/notificationModel.dart';
import 'package:demopatient/model/pharma_req_model.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/dialogBox.dart';
import 'package:demopatient/utilities/imagePicker.dart';
import 'package:demopatient/utilities/inputfields.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/buttonsWidget.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPharmaReqPage extends StatefulWidget {
  final PharmacyReqModel? reportModel;
  const EditPharmaReqPage({Key? key, this.reportModel}) : super(key: key);
  @override
  _EditPharmaReqPageState createState() => _EditPharmaReqPageState();
}

class _EditPharmaReqPageState extends State<EditPharmaReqPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _statuscont = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List<String> _imageUrls = [];
  List<XFile> _listImages = [];
  int _successUploaded = 1;
  bool _isUploading = false;
  bool _isEnableBtn = true;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  void initState() {
    _statuscont.text = widget.reportModel!.status == "0"
        ? "Pending".tr
        : widget.reportModel!.status == "1"
            ? "Confirmed".tr
            : widget.reportModel!.status == "2"
                ? "Delivered".tr
                : "Not Updated".tr;
    // TODO: implement initState
    _titleController.text = widget.reportModel!.desc;
    if (widget.reportModel!.imageUrl != "")
      _imageUrls = widget.reportModel!.imageUrl.toString().split(",");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.reportModel!.status == "0"
          ? _isUploading
              ? null
              : FloatingActionButton(
                  elevation: 0.0,
                  child: IconButton(
                      icon: Icon(Icons.add_a_photo), onPressed: _loadAssets),
                  backgroundColor: btnColor,
                  onPressed: () {})
          : null,
      bottomNavigationBar: widget.reportModel!.status == "0"
          ? BottomNavigationStateWidget(
              title: "Update".tr,
              onPressed: _takeUpdateConfirmation,
              clickable: _isEnableBtn ? "true" : "")
          : null,
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          CAppBarWidget(title: "Update Reports".tr),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: IBoxDecoration.upperBoxDecoration(),
              child: _isUploading ? LoadingIndicatorWidget() : buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAssets() async {
    final res = await ImagePickerOld.loadAssets(
        _listImages, mounted, 10); //get images from phone gallery with 10 limit
    setState(() {
      _listImages = res;
      // if (res.length > 0)
      //   _isEnableBtn = true;
      // else
      //   _isEnableBtn = false;
    });
  }

  _takeUpdateConfirmation() {
    if (_listImages.length == 0 && _imageUrls.length == 0) {
      ToastMsg.showToastMsg("Please add at least one image".tr);
    } else
      DialogBoxes.confirmationBox(context, "Update".tr,
          "Are you sure want to update details".tr, _handleUpdate);
  }

  _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
        _isEnableBtn = false;
      });
      if (_listImages.length == 0) {
        String imageUrl = "";
        if (_imageUrls.length != 0) {
          for (var e in _imageUrls) {
            if (imageUrl == "") {
              imageUrl = e;
            } else {
              imageUrl = imageUrl + "," + e;
            }
          }
        }
        SharedPreferences preferences = await SharedPreferences.getInstance();
        final uid = await preferences.getString("uidp") ?? "";
        PharmacyReqModel reportModel = PharmacyReqModel(
            uid: uid,
            id: widget.reportModel!.id,
            imageUrl: imageUrl,
            desc: _titleController.text);
        final res = await PharmaReqService.updateData(reportModel);
        if (res == "success") {
          ToastMsg.showToastMsg("Successfully updated".tr);
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/PharmaReqListPage', ModalRoute.withName('/HomePage'));
        } else if (res == "already exists") {
          Navigator.pop(context);
          ToastMsg.showToastMsg("Title name already exists".tr);
        } else
          ToastMsg.showToastMsg("Something went wrong");
      } else {
        await _startUploading();
      }

      setState(() {
        _isUploading = false;
        _isEnableBtn = true;
      });
    }
  }

  _startUploading() async {
    int index = _successUploaded - 1;
    // setState(() {
    //   _imageName = _listImages[index].name;
    // });

    if (_successUploaded <= _listImages.length) {
      final res = await UploadImageService.uploadImages(
          _listImages[index]); //  represent the progress of uploading task
      if (res == "0") {
        ToastMsg.showToastMsg(
            "Sorry, ${_listImages[index].name} is not in format only JPG, JPEG, PNG, & GIF files are allowed to upload");
        if (_successUploaded < _listImages.length) {
          //check more images for upload
          setState(() {
            _successUploaded = _successUploaded + 1;
          });
          _startUploading(); //if images is remain to upload then again run this task

        } else {}
      } else if (res == "1") {
        ToastMsg.showToastMsg(
            "Image ${_listImages[index].name} size must be less the 1MB");
        if (_successUploaded < _listImages.length) {
          //check more images for upload
          setState(() {
            _successUploaded = _successUploaded + 1;
          });
          _startUploading(); //if images is remain to upload then again run this task

        } else {}
      } else if (res == "2") {
        ToastMsg.showToastMsg(
            "Image ${_listImages[index].name} size must be less the 1MB");
        if (_successUploaded < _listImages.length) {
          //check more images for upload
          setState(() {
            _successUploaded = _successUploaded + 1;
          });
          _startUploading(); //if images is remain to upload then again run this task

        } else {}
      } else if (res == "3" || res == "error") {
        ToastMsg.showToastMsg("Something went wrong".tr);
        if (_successUploaded < _listImages.length) {
          //check more images for upload
          setState(() {
            _successUploaded = _successUploaded + 1;
          });
          _startUploading(); //if images is remain to upload then again run this task

        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/PharmaReqListPage', ModalRoute.withName('/HomePage'));
        }
      } else if (res == "") {
        ToastMsg.showToastMsg("Something went wrong".tr);
        if (_successUploaded < _listImages.length) {
          //check more images for upload
          setState(() {
            _successUploaded = _successUploaded + 1;
          });
          _startUploading(); //if images is remain to upload then again run this task

        } else {}
      } else {
        setState(() {
          _imageUrls.add(res);
        });

        if (_successUploaded < _listImages.length) {
          //check more images for upload
          setState(() {
            _successUploaded = _successUploaded + 1;
          });
          _startUploading(); //if images is remain to upload then again run this task

        } else {
          // print("***********${_imageUrls.length}");
          String imageUrl = "";
          if (_imageUrls.length != 0) {
            for (var e in _imageUrls) {
              if (imageUrl == "") {
                imageUrl = e;
              } else {
                imageUrl = imageUrl + "," + e;
              }
            }
          }
          SharedPreferences preferences = await SharedPreferences.getInstance();
          final uid = await preferences.getString("uidp") ?? "";

          PharmacyReqModel reportModel = PharmacyReqModel(
              uid: uid,
              id: widget.reportModel!.id,
              imageUrl: imageUrl,
              desc: _titleController.text);
          final res = await PharmaReqService.updateData(reportModel);
          if (res == "success") {
            ToastMsg.showToastMsg("Successfully updated".tr);
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/PharmaReqListPage', ModalRoute.withName('/HomePage'));
          } else if (res == "already exists") {
            ToastMsg.showToastMsg("Title name already exists".tr);
          } else
            ToastMsg.showToastMsg("Something went wrong".tr);
        }
      }
    }
    setState(() {
      _isUploading = false;
      _isEnableBtn = true;
    });
  }

  buildBody() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          InputFields.commonInputField(
              _titleController, "Enter Report Title".tr, (item) {
            return item.length > 0 ? null : "Enter Title".tr;
          }, TextInputType.text, 1),
          InputFields.readableInputField(_statuscont, "Status".tr, 1),
          _imageUrls.length == 0
              ? Container()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    "Previous attached image".tr,
                    style: TextStyle(
                        fontFamily: "OpenSans-SemiBold", fontSize: 14),
                  ),
                ),
          _buildImageList(),
          _listImages.length == 0
              ? Container()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    "New attached image".tr,
                    style: TextStyle(
                        fontFamily: "OpenSans-SemiBold", fontSize: 14),
                  ),
                ),
          _buildNewImageList(),
          widget.reportModel!.status == "0" ? _deleteServiceBtn() : Container()
        ],
      ),
    );
  }

  Widget _deleteServiceBtn() {
    return DeleteButtonWidget(
      onPressed: () {
        showDialog(
          // barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: new Text("Cancel".tr),
              content:
                  new Text("Are you sure want to update status to Cancel".tr),
              actions: <Widget>[
                new ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                    ),
                    child: new Text("OK".tr),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _handleUpdateReqService("3");
                    })
                // usually buttons at the bottom of the dialog
              ],
            );
          },
        );
        //take confirmation from user
      },
      title: "Cancel Request".tr,
    );
  }

  _handleUpdateReqService(String status) async {
    setState(() {
      _isUploading = true;
      _isEnableBtn = false;
    });
    final res =
        await PharmaReqService.updateStatus(status, widget.reportModel!.id);
    if (res == "success") {
      _handleSendNoti(status);
    } else {
      ToastMsg.showToastMsg("Something went wrong".tr);
      setState(() {
        _isUploading = false;
        _isEnableBtn = true;
      });
    }
  }

  _handleSendNoti(String status) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final fName = await preferences.getString("firstName") ?? "";
    final lName = await preferences.getString("lastName") ?? "";
    final uName = fName + " " + lName;
    final fuid = FirebaseAuth.instance.currentUser!.uid;
    final res2 =
        await PharmacyService.getDataByApId(pid: widget.reportModel!.pharmaId);
    final notificationModelForAdmin = NotificationModel(
        title: "Update Request!",
        body:
            "Request id ${widget.reportModel!.id} status has been update by $uName",
        uId: fuid,
        sendBy: uName,
        pharmaID: widget.reportModel!.pharmaId);
    await NotificationService.addDataForPharma(notificationModelForAdmin);
    if (res2[0].fcmId != "") {
      await HandleFirebaseNotification.sendPushMessage(
          res2[0].fcmId ?? "", //admin fcm
          "Update Request", //title
          "Request id ${widget.reportModel!.id} status has been update by $uName " //body
          );
    }
    await UpdateData.updateIsAnyNotification(
        "pharma", widget.reportModel!.pharmaId, true);
    ToastMsg.showToastMsg("Successfully updated".tr);
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/PharmaReqListPage', ModalRoute.withName('/HomePage'));
  }

  _buildNewImageList() {
    // in this section assets convert into file
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: _listImages.length,
          itemBuilder: (context, index) {
            File asset = File(_listImages[index].path);
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                onLongPress: () {
                  DialogBoxes.confirmationBox(context, "Delete".tr,
                      "Are you sure want to delete selected image".tr, () {
                    setState(() {
                      _listImages.removeAt(index);
                    });
                  });
                },
                child: Image.file(asset,
                  width: 300,
                  height: 300,
                ),
              ),
            );
          }),
    );
  }

  _buildImageList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: _imageUrls.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowPrescriptionImagePage(
                          imageUrls: _imageUrls,
                          selectedImagesIndex: index,
                          title: "Image"),
                    ),
                  );
                },
                onLongPress: () {
                  DialogBoxes.confirmationBox(context, "Delete".tr,
                      "Are you sure want to delete selected image".tr, () {
                    setState(() {
                      _imageUrls.removeAt(index);
                    });
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ImageBoxContainWidget(
                    imageUrl: _imageUrls[index],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
