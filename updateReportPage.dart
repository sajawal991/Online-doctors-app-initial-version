import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:demopatient/Screen/showPrescriptionImae.dart';
import 'package:demopatient/Service/reporstService.dart';
import 'package:demopatient/Service/uploadImageService.dart';
import 'package:demopatient/model/reportModel.dart';
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

class UpdateReportPage extends StatefulWidget {
  final ReportModel? reportModel;
  const UpdateReportPage({Key? key, this.reportModel}) : super(key: key);

  @override
  _UpdateReportPageState createState() => _UpdateReportPageState();
}

class _UpdateReportPageState extends State<UpdateReportPage> {
  TextEditingController _titleController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List<String> _imageUrls = [];
  List<XFile> _listImages = [];
  int _successUploaded = 1;
  bool _isUploading = false;
  bool _isEnableBtn = true;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    _titleController.text = widget.reportModel!.title;
    if (widget.reportModel!.imageUrl != "")
      _imageUrls = widget.reportModel!.imageUrl.toString().split(",");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isUploading
          ? null
          : FloatingActionButton(
              elevation: 0.0,
              child: IconButton(
                  icon: Icon(Icons.add_a_photo), onPressed: _loadAssets),
              backgroundColor: btnColor,
              onPressed: () {}),
      bottomNavigationBar: BottomNavigationStateWidget(
          title: "Update".tr,
          onPressed: _takeUpdateConfirmation,
          clickable: _isEnableBtn ? "true" : ""),
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
        ReportModel reportModel = ReportModel(
          uid: uid,
          id: widget.reportModel!.id,
          imageUrl: imageUrl,
          title: _titleController.text,
        );
        final res = await ReportService.updateData(reportModel);
        if (res == "success") {
          ToastMsg.showToastMsg("Successfully updated".tr);
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/ReportListPage', ModalRoute.withName('/HomePage'));
        } else if (res == "already exists") {
          Navigator.pop(context);
          ToastMsg.showToastMsg("Title name already exists".tr);
        } else
          ToastMsg.showToastMsg("Something went wrong".tr);
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
              '/ReportListPage', ModalRoute.withName('/HomePage'));
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

          ReportModel reportModel = ReportModel(
              uid: uid,
              id: widget.reportModel!.id,
              imageUrl: imageUrl,
              title: _titleController.text);
          final res = await ReportService.updateData(reportModel);
          if (res == "success") {
            ToastMsg.showToastMsg("Successfully updated".tr);
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/ReportListPage', ModalRoute.withName('/HomePage'));
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
          _deleteServiceBtn()
        ],
      ),
    );
  }

  Widget _deleteServiceBtn() {
    return DeleteButtonWidget(
      onPressed: () {
        DialogBoxes.confirmationBox(
            context,
            "Delete".tr,
            "Are you sure want to delete".tr,
            _handleDeleteService); //take confirmation from user
      },
      title: "Delete".tr,
    );
  }

  _handleDeleteService() async {
    setState(() {
      _isUploading = true;
      _isEnableBtn = false;
    });
    final res = await ReportService.deleteData(widget.reportModel!.id);
    print("rrrrrrrr$res");
    if (res == "success") {
      ToastMsg.showToastMsg("Successfully Deleted".tr);
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/ReportListPage', ModalRoute.withName('/HomePage'));
    } else {
      ToastMsg.showToastMsg("Something went wrong".tr);
      setState(() {
        _isUploading = false;
        _isEnableBtn = true;
      });
    }
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
