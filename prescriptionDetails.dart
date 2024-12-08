import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/inputfields.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:open_filex/open_filex.dart';

import '../../Service/Apiservice/chatapi.dart';
import '../../config.dart';

class PrescriptionDetailsPage extends StatefulWidget {
  final title;
  final prescriptionDetails;
  PrescriptionDetailsPage(
      {@required this.title, @required this.prescriptionDetails});
  @override
  _PrescriptionDetailsPageState createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  var taskId;
  ReceivePort _port = ReceivePort();
  ProgressDialog? pd;
  TextEditingController _serviceNameController = TextEditingController();
  TextEditingController _patientNameController = TextEditingController();
  TextEditingController _drNameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List _imageUrls = [];

  @override
  void initState() {
    // TODO: implement initState
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) async {
      print("Port start listing");
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      print("Download Status $progress");
      // print(data);
      pd!.update(value: progress);
      await FlutterDownloader.open(taskId: taskId);
      pd!.close();
      // if (status == DownloadTaskStatus(3)) {
      //   Future.delayed(const Duration(milliseconds: 2000), () async {
      //     try {
      //       await FlutterDownloader.open(taskId: taskId);
      //     } catch (e) {}
      //   });
      // }
      setState(() {});
    });
    // FlutterDownloader.registerCallback(downloadCallback);
    setState(() {
      _serviceNameController.text = widget.prescriptionDetails.appointmentName;
      _patientNameController.text = widget.prescriptionDetails.patientName;
      _drNameController.text = widget.prescriptionDetails.drName;
      _dateController.text = widget.prescriptionDetails.appointmentDate;
      _timeController.text = widget.prescriptionDetails.appointmentTime;
      _messageController.text = widget.prescriptionDetails.prescription;
      if (widget.prescriptionDetails.imageUrl != "")
        _imageUrls = widget.prescriptionDetails.imageUrl.toString().split(",");
    });

    super.initState();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _serviceNameController..dispose();
    _patientNameController.dispose();
    _drNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _messageController.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          CAppBarWidget(title: widget.title),
          Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: IBoxDecoration.upperBoxDecoration(),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView(
                    children: [
                      /*InputFields.readableInputField(_serviceNameController, "Service".tr, 1),
                      InputFields.readableInputField(_patientNameController, "Name".tr, 1),
                      InputFields.readableInputField(_drNameController, "Dr Name".tr, 1),
                      InputFields.readableInputField(_dateController, "Date".tr, 1),
                      InputFields.readableInputField(_timeController, "Time".tr, 1),
                      InputFields.readableInputField(_messageController, "Message".tr, null),*/

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                onTap: () async {
                                  print(1);
                                  pd = ProgressDialog(context: context);
                                  print('${apiUrlLaravel}/patient/prescription/export/${widget.prescriptionDetails.id}');
                                  ChatApi().download('${apiUrlLaravel}/patient/prescription/export/${widget.prescriptionDetails.id}',
                                      'Prescription.pdf',
                                      type: 'prescription',
                                  );
                                  // final fileNameWithExt = getFileNameFromUrl('${apiUrl}/api/patient/prescription/export/${widget.prescriptionDetails.id}');
                                  //
                                  // var perStatus = await Permission.storage.request();
                                  // print(3);
                                  // if (perStatus.isGranted) {
                                  //   String path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
                                  //   if (await File("${path}/MyClinic/$fileNameWithExt").exists() == true) {
                                  //     print("file exists");
                                  //     await OpenFilex.open('${path}/MyClinic/$fileNameWithExt');
                                  //     //await  Directory("storage/emulated/0/Android/media/com.medicaljunction.download/files").create(recursive: true);
                                  //   } else {
                                  //     if (await Directory("$path/MyClinic").exists() == false) {
                                  //       await Directory("${path}/MyClinic").create(recursive: true);
                                  //     }
                                  //
                                  //     print(5);
                                  //     ToastMsg.showToastMsg("Download Stated, please wait".tr);
                                  //     pd!.show(
                                  //       max: 100,
                                  //       msg: 'Downloading...'.tr,
                                  //       progressType: ProgressType.valuable,
                                  //     );
                                  //     taskId = await FlutterDownloader.enqueue(
                                  //       url: '${apiUrl}/api/patient/prescription/export/${widget.prescriptionDetails.id}',
                                  //       savedDir: "${path}/MyClinic",
                                  //       fileName: "$fileNameWithExt",
                                  //       showNotification: true,
                                  //       // show download progress in status bar (for Android)
                                  //       openFileFromNotification:
                                  //       true, // click on notification to open downloaded file (for Android)
                                  //     );
                                  //   }
                                  // } else if (perStatus.isPermanentlyDenied) {
                                  //   ToastMsg.showToastMsg("Please give us app storage permission from app settings".tr);
                                  // }
                                },
                                child: Row(
                                  children: [
                                    Text('Download',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.download,
                                          color: Colors.white,
                                          size: 20,
                                        )),
                                  ],
                                )),
                          ),
                        ],
                      ),

                      Html(data: _messageController.text.toString()),
                      // _buildImageList()
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  _buildImageList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), // left and right old value is 10 + hassan005004
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: _imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Card(
                  color: bgColor,
                  elevation: .5,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          getFileNameFromUrl(_imageUrls[index]),
                          style: TextStyle(
                              fontFamily: "OpenSans-SemiBold", fontSize: 16),
                        ),
                      ),
                      Flexible(
                        child: IconButton(
                            onPressed: () async {
                              pd = ProgressDialog(context: context);
                              final fileNameWithExt =
                                  getFileNameFromUrl(_imageUrls[index]);

                              var perStatus = await Permission.storage.request();
                              if (perStatus.isGranted) {
                                String path = await ExternalPath
                                    .getExternalStoragePublicDirectory(
                                        ExternalPath.DIRECTORY_DOWNLOADS);
                                if (await File(
                                            "${path}/MyClinic/$fileNameWithExt")
                                        .exists() ==
                                    true) {
                                  print("file exists");
                                  await OpenFilex.open(
                                      '${path}/MyClinic/$fileNameWithExt');
                                  //await  Directory("storage/emulated/0/Android/media/com.medicaljunction.download/files").create(recursive: true);
                                } else {
                                  if (await Directory("$path/MyClinic")
                                          .exists() ==
                                      false) {
                                    await Directory("${path}/MyClinic")
                                        .create(recursive: true);
                                  }
                                  ToastMsg.showToastMsg(
                                      "Download Stated, please wait".tr);
                                  pd!.show(
                                    max: 100,
                                    msg: 'Downloading...'.tr,
                                    progressType: ProgressType.valuable,
                                  );
                                  taskId = await FlutterDownloader.enqueue(
                                    url: _imageUrls[index],
                                    savedDir: "${path}/MyClinic",
                                    fileName: "$fileNameWithExt",
                                    showNotification: true,
                                    // show download progress in status bar (for Android)
                                    openFileFromNotification:
                                        true, // click on notification to open downloaded file (for Android)
                                  );
                                }
                              } else if (perStatus.isPermanentlyDenied) {
                                ToastMsg.showToastMsg(
                                    "Please give us app storage permission from app settings"
                                        .tr);
                              }
                            },
                            icon: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.download,
                                  color: Colors.white,
                                  size: 20,
                                ))),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  getFileNameFromUrl(fileUrl) {
    final File _file = File(fileUrl);
    final _filename = basename(_file.path);
    return _filename;
  }
}
