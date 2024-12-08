// import 'package:demopatient/Service/drProfileService.dart';
// import 'package:demopatient/helper/extensions/date_time.dart';
// import 'package:demopatient/helper/extensions/string.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../Service/Apiservice/chatapi.dart';
// import '../../Service/Firebase/updateData.dart';
// import '../../Service/Model/ChatModel.dart';
// import '../../Service/Noftification/handleFirebaseNotification.dart';
// import '../../Service/notificationService.dart';
// import '../../Service/prescriptionService.dart';
// import '../../Service/userService.dart';
// import '../../model/appointmentModel.dart';
// import '../../model/notificationModel.dart';
// import '../../utilities/color.dart';
// import '../../utilities/decoration.dart';
// import '../../utilities/toastMsg.dart';
// import '../../widgets/appbarsWidget.dart';
// import '../../widgets/errorWidget.dart';
// import '../../widgets/loadingIndicator.dart';
// import '../../widgets/noDataWidget.dart';
// import '../CustomUI/OwnMessgaeCrad.dart';
// import '../CustomUI/ReplyCard.dart';
// import 'dart:io';
// import '../CustomUI/labDetail.dart';
// import '../jitscVideoCall.dart';
// import '../prescription/prescriptionDetails.dart';
//
// class IndividualPage extends StatefulWidget {
//   AppointmentModel? appointmentDetails;
//   IndividualPage(this.appointmentDetails, {Key? key}) : super(key: key);
//   // final ChatModell? chatModel;
//   // final ChatModell? sourchat;
//
//
//   @override
//   State<IndividualPage> createState() => _IndividualPageState();
// }
//
// class _IndividualPageState extends State<IndividualPage> {
//
//   bool show = false;
//   FocusNode focusNode = FocusNode();
//   bool sendButton = false;
//   List<ChatClass> chatmessages = [];
//   ValueNotifier<int> chatmessagesNotifier = ValueNotifier<int>(0);
//   TextEditingController _controller = TextEditingController();
//   ScrollController _scrollController = ScrollController();
//   // IO.Socket socket;
//   @override
//   void initState() {
//     super.initState();
//     // connect();
//     apiGetMessages();
//     focusNode.addListener(() {
//       if (focusNode.hasFocus) {
//         setState(() {
//           show = false;
//         });
//       }
//     });
//     // connect();
//   }
//   apiGetMessages() async {
//     chatmessages = await ChatApi().GetPatientMessages(widget.appointmentDetails!.id);
//     chatmessagesNotifier.value = 1;
//     Future.delayed(Duration(seconds: 1)).then((value) => setState(() {
//       // EasyLoading.dismiss();
//       _scrollDown();
//     }));
//
//   }
//   void _scrollDown() {
//     if (_scrollController.hasClients)
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent + 70,
//         duration: Duration(seconds: 2),
//         curve: Curves.fastOutSlowIn,
//       );
//   }
//
//   void sendchatmessage(dynamic message,dynamic type) {
//     setchatmessage(message,type);
//     // socket.emit("message",
//     //     {"message": message, "sourceId": sourceId, "targetId": targetId});
//   }
//
//   void setchatmessage(dynamic message,dynamic type) {
//     ChatClass messageModel = ChatClass(
//       drprofileId: widget.appointmentDetails!.doctId,
//       appointmentId: widget.appointmentDetails!.id,
//         userListId: widget.appointmentDetails!.uId.toString(),
//         sender: '1',
//         type: type,
//         message: message,
//         createdAt: DateTime.now());
//     print(chatmessages);
//     chatmessages.add(messageModel);
//     chatmessagesNotifier.value = 1;
//
//     // setState(() {
//     //   chatmessages.add(ChatClass());
//     // });
//   }
//
//   final imagePicker = ImagePicker();
//    late File imageFile;
//
//   void getImage() async {
//
//     PickedFile? image = await imagePicker.getImage(source: ImageSource.gallery);
//     setState(() {
//       imageFile = File(image!.path);
//     });
//     print(1234);
//         sendchatmessage(image!.path, '3');
//         print(123);
//
//
//         final login = await ChatApi().PatinetSendMessage(
//             widget.appointmentDetails!.id.toString(),
//             widget.appointmentDetails!.uId.toString(),
//             widget.appointmentDetails!.doctId.toString(),
//             1,
//             4,
//             '',
//             image);
//         print('send');
//   }
//   void getImagecamera() async {
//
//     PickedFile? image = await imagePicker.getImage(source: ImageSource.camera);
//     setState(() {
//       imageFile = File(image!.path);
//     });
//     print(1234);
//     sendchatmessage(image!.path, '4');
//     print(123);
//
//
//
//     final login = await ChatApi().PatinetSendMessage(
//         widget.appointmentDetails!.id.toString(),
//         widget.appointmentDetails!.uId.toString(),
//         widget.appointmentDetails!.doctId.toString(),
//         1,
//         4,
//         '',
//         image);
//     print('send');
//   }
//   void _handleFileSelection() async {
//
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions:  ['jpg', 'pdf', 'doc'],
//     );
//
//     if (result != null) {
//         PlatformFile file = result.files.first;
//         print(1234);
//        setState(() {
//          sendchatmessage(file!.path, '3');
//
//        });
//         print(123);
//
//
//
//       setState(() async {
//         final login = await ChatApi().PatinetSendMessage(
//             widget.appointmentDetails!.id.toString(),
//             widget.appointmentDetails!.uId.toString(),
//             widget.appointmentDetails!.doctId.toString(),
//             1,
//             3,
//             '',
//             file);
//
//         print('send');
//       });
//
//     } else {
//       print('No file selected');
//     }
//   }
//
//
//
// @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // Image.asset(
//         //   "assets/whatsapp_Back.png",
//         //   height: MediaQuery.of(context).size.height,
//         //   width: MediaQuery.of(context).size.width,
//         //   fit: BoxFit.cover,
//         // ),
//         Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: PreferredSize(
//             preferredSize: Size.fromHeight(60),
//             child: AppBar(
//               backgroundColor: appBarColor,
//               leadingWidth: 70,
//               titleSpacing: 0,
//               leading: InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(right: 6.0),
//                       child: Icon(
//                         Icons.arrow_back,
//                         size: 24,
//                       ),
//                     ),
//                     CircleAvatar(
//                     backgroundImage: NetworkImage('https://media.istockphoto.com/id/1190555658/vector/medical-doctor-profile-icon-male-doctor-avatar-vector-illustration.jpg?s=612x612&w=0&k=20&c=hZrwCttxlScGjelFj7kVzS6aCKJdCAaTBA_MSSJK2hQ='),
//                       radius: 20,
//                       backgroundColor: Colors.blueGrey,
//                     ),
//                   ],
//                 ),
//               ),
//               title: InkWell(
//                 onTap: () {},
//                 child: Container(
//                   margin: EdgeInsets.all(6),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.appointmentDetails!.doctName,
//                         style: TextStyle(
//                           fontSize: 18.5,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         widget.appointmentDetails!.clinicName,
//                         style: TextStyle(
//                           fontSize: 13,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               actions: [
//                 InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => Meeting(
//                               uid: widget
//                                   .appointmentDetails!
//                                   .uId,
//                               doctid: widget
//                                   .appointmentDetails!
//                                   .doctId,
//                               email: widget
//                                   .appointmentDetails!
//                                   .pEmail,
//                             )),
//
//                       );
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Icon(Icons.videocam),
//                     )),
//                 InkWell(
//                     onTap: () {
//                       showModalBottomSheet(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           backgroundColor: Colors.white,
//                           context: context,
//                           builder: (context) {
//                             return  Container(
//                               color: Colors.transparent, //could change this to Color(0xFF737373),
//                               //so you don't have to change MaterialApp canvasColor
//                               child:  Container(
//                                   decoration:  BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius:  BorderRadius.only(
//                                           topLeft: const Radius.circular(10.0),
//                                           topRight: const Radius.circular(10.0))),
//                                   child:  Padding(
//                                     padding: const EdgeInsets.all(12.0),
//                                     child: Text(widget.appointmentDetails!.description,style: TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.normal,
//                                       fontSize: 16,
//                                     ),),
//                                   )),
//                             );
//                           });
//
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Icon(Icons.info_outline),
//                     )),
//                 InkWell(
//                     onTap: () {
//                       AppointmentChatModal.prescriptionModal(
//                           context, widget.appointmentDetails!.id);
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.all(5.0),
//                       child: Icon(Icons.medication),
//                     )),
//
//                 InkWell(
//                     onTap: () {
//                       print('name');
//                       print(widget.appointmentDetails?.id.toString());
//                       AppointmentChatModal.labModal(
//                           context, widget.appointmentDetails!.id,widget.appointmentDetails);
//
//                       // AppointmentChatModal.labModal(
//                       //     context, widget.appointmentDetails!.id, widget.appointmentDetails);
//                     },
//                     child: Padding(
//
//                       padding: const EdgeInsets.all(5.0),
//                       child: Icon(Icons.medical_services),
//
//                     )),
//
//                 // PopupMenuButton<String>(
//                 //   padding: EdgeInsets.all(0),
//                 //   onSelected: (value) {
//                 //     print(value);
//                 //   },
//                 //   itemBuilder: (BuildContext contesxt) {
//                 //     return [
//                 //       PopupMenuItem(
//                 //         child: Text("View Contact"),
//                 //         value: "View Contact",
//                 //       ),
//                 //       PopupMenuItem(
//                 //         child: Text("Media, links, and docs"),
//                 //         value: "Media, links, and docs",
//                 //       ),
//                 //       PopupMenuItem(
//                 //         child: Text("Whatsapp Web"),
//                 //         value: "Whatsapp Web",
//                 //       ),
//                 //       PopupMenuItem(
//                 //         child: Text("Search"),
//                 //         value: "Search",
//                 //       ),
//                 //       PopupMenuItem(
//                 //         child: Text("Mute Notification"),
//                 //         value: "Mute Notification",
//                 //       ),
//                 //       PopupMenuItem(
//                 //         child: Text("Wallpaper"),
//                 //         value: "Wallpaper",
//                 //       ),
//                 //     ];
//                 //   },
//                 // ),
//               ],
//             ),
//           ),
//           body: Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             child: WillPopScope(
//               child: Stack(
//                 children: [
//                   // FutureBuilder(
//                   //   future: ChatApi().GetPatientMessages(),
//                   //   builder: (context, AsyncSnapshot<ChatModel> snapshot) {
//                   //     if (snapshot.hasData) {
//                   //       return  Container(
//                   //         height: MediaQuery.of(context).size.height - 170,
//                   //         margin: EdgeInsets.only(bottom: 70),
//                   //         child:  ListView.builder(
//                   //           shrinkWrap: true,
//                   //           controller: _scrollController,
//                   //           itemCount: snapshot.data!.data.length,
//                   //           itemBuilder: (context, i) {
//                   //             if (i == snapshot.data!.data.length) {
//                   //               return Container(
//                   //                 height: 60,
//                   //               );
//                   //             }
//                   //             if (snapshot.data!.data[i].sender == "1") {
//                   //               return OwnMessageCard(
//                   //                 data: snapshot.data!.data[i],
//                   //
//                   //               );
//                   //             } else {
//                   //               return ReplyCard(
//                   //                 message: snapshot.data!.data[i].message ,
//                   //                 time: snapshot.data!.data[i].createdAt.toString(),
//                   //               );
//                   //             }
//                   //           },
//                   //         ),
//                   //       );
//                   //     }
//                   //     return Center(
//                   //       child: CircularProgressIndicator(),
//                   //     );
//                   //   },
//                   // ),
//
//                   Container(
//                     height: MediaQuery.of(context).size.height - 170,
//                     margin: EdgeInsets.only(bottom: 70),
//                     child: ValueListenableBuilder(
//                       valueListenable: chatmessagesNotifier,
//                       builder: (context, value, _) {
//                         _scrollDown();
//                         chatmessagesNotifier.value = 0;
//                         return ListView.builder(
//                           controller: _scrollController,
//                           shrinkWrap: true,
//                           // reverse: true,
//                           itemCount: chatmessages.length,
//                           itemBuilder: (context, i) {
//                             if (i == chatmessages.length) {
//                               return Container(
//                                 height: 60,
//                               );
//                             }
//                             // if (messages[i].sender == "2") {
//                             return OwnMessageCard(
//                                 data: chatmessages[i],
//                                 widget: widget.appointmentDetails!.id
//                                     .toString());
//                             // } else {
//                             //   return ReplyCard(
//                             //     data: messages[i],
//                             //   );
//                             // }
//                           },
//                         );
//                       },
//                     ),
//
//                   ),
//
//                   Positioned(
//                     bottom: 0,
//                     child: Container(
//                       height: 70,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: MediaQuery.of(context).size.width - 60,
//                                 child: Card(
//                                   margin: EdgeInsets.only(
//                                       left: 2, right: 2, bottom: 8),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(25),
//                                   ),
//                                   child: TextFormField(
//                                     controller: _controller,
//                                     // focusNode: focusNode,
//
//                                     textAlignVertical: TextAlignVertical.center,
//                                     keyboardType: TextInputType.multiline,
//                                     maxLines: 5,
//                                     minLines: 1,
//                                     onChanged: (value) {
//                                       if (value.length > 0) {
//                                         setState(() {
//                                           sendButton = true;
//                                         });
//                                       } else {
//                                         setState(() {
//                                           sendButton = false;
//                                         });
//                                       }
//                                     },
//                                     decoration: InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: "Type a message",
//                                       hintStyle: TextStyle(color: Colors.grey),
//                                       prefixIcon: IconButton(
//                                         icon: Icon(
//                                           show
//                                               ? Icons.keyboard
//                                               : Icons.emoji_emotions_outlined,
//                                         ),
//                                         onPressed: () {
//                                           if (!show) {
//                                             focusNode.unfocus();
//                                             focusNode.canRequestFocus = false;
//                                           }
//                                           setState(() {
//                                             show = !show;
//                                           });
//                                         },
//                                       ),
//                                       suffixIcon: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           InkWell(
//                                             onTap:(){
//                                               showModalBottomSheet(
//                                                   backgroundColor:
//                                                   Colors.transparent,
//                                                   context: context,
//                                                   builder: (builder) =>
//                                                       Container(
//                                                         height: 175,
//                                                         width: MediaQuery.of(context).size.width,
//                                                         child: Card(
//                                                           margin: const EdgeInsets.all(18.0),
//                                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                                                           child: Padding(
//                                                             padding: const EdgeInsets.only(left: 10,right: 10, top: 20),
//                                                             child: Column(
//                                                               children: [
//                                                                 Row(
//                                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                                   children: [
//                                                                     Column(
//                                                                       children: [
//                                                                         InkWell(
//                                                                           onTap: () {
//                                                                             _handleFileSelection();
//                                                                           },
//                                                                           child: CircleAvatar(
//                                                                             radius: 30,
//                                                                             backgroundColor: Colors.indigo,
//                                                                             child: Icon(
//                                                                               Icons.insert_drive_file,
//                                                                               // semanticLabel: "Help",
//                                                                               size: 29,
//                                                                               color: Colors.white,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height: 10,
//                                                                         ),
//                                                                         Text(
//                                                                           'Document',
//
//                                                                           style: TextStyle(
//                                                                             fontSize: 12,
//                                                                             // fontWeight: FontWeight.w100,
//                                                                           ),
//                                                                         )
//                                                                       ],
//                                                                     ),
//                                                                     SizedBox(
//                                                                       width: 40,
//                                                                     ),
//                                                                     Column(
//                                                                       children: [
//                                                                         InkWell(
//                                                                           onTap: () {
//                                                                             getImagecamera();
//                                                                           },
//                                                                           child: CircleAvatar(
//                                                                             radius: 30,
//                                                                             backgroundColor: Colors.pink,
//                                                                             child: Icon(
//                                                                               Icons.camera_alt,
//                                                                               // semanticLabel: "Help",
//                                                                               size: 29,
//                                                                               color: Colors.white,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height: 10,
//                                                                         ),
//                                                                         Text(
//                                                                           'Camera',
//
//                                                                           style: TextStyle(
//                                                                             fontSize: 12,
//                                                                             // fontWeight: FontWeight.w100,
//                                                                           ),
//                                                                         )
//                                                                       ],
//                                                                     ),
//                                                                     SizedBox(
//                                                                       width: 40,
//                                                                     ),
//                                                                     Column(
//                                                                       children: [
//                                                                         InkWell(
//                                                                           onTap: () {
//                                                                             getImage();
//                                                                           },
//                                                                           child: const CircleAvatar(
//                                                                             radius: 30,
//                                                                             backgroundColor: Colors.purple,
//                                                                             child: Icon(
//                                                                               Icons.insert_photo,
//                                                                               // semanticLabel: "Help",
//                                                                               size: 29,
//                                                                               color: Colors.white,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height: 10,
//                                                                         ),
//                                                                         Text(
//                                                                           'Gallery',
//
//                                                                           style: TextStyle(
//                                                                             fontSize: 12,
//                                                                             // fontWeight: FontWeight.w100,
//                                                                           ),
//                                                                         )
//                                                                       ],
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                                 SizedBox(
//                                                                   height: 30,
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ));
//                                             },
//                                               child: Icon(Icons.attach_file)),
//                                           IconButton(
//                                             icon:  Icon(Icons.camera_alt),
//                                             onPressed: () {
//                                               getImagecamera();
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                       contentPadding: EdgeInsets.all(5),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(
//                                   bottom: 8,
//                                   right: 2,
//                                   left: 2,
//                                 ),
//                                 child: CircleAvatar(
//                                   radius: 25,
//                                   backgroundColor: Color(0xFF128C7E),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       sendButton ? Icons.send : Icons.send,
//                                       color: Colors.white,
//                                     ),
//
//                                     onPressed: () async {
//                                       if (sendButton) {
//
//                                         String msg = _controller.text;
//                                         debugPrint('inseft');
//
//                                         print('data insrted 1');
//
//                                         setchatmessage(msg, '1');
//
//                                         _controller.clear();
//                                         print('data insrted');
//
//                                         final login = await ChatApi().PatinetSendMessage(
//                                             widget.appointmentDetails!.id.toString(),
//                                             widget.appointmentDetails!.uId.toString(),
//                                             widget.appointmentDetails!.doctId,
//                                             1,
//                                             1,
//                                             msg,
//                                             null);
//
//
//                                         // print('data insrted20');
//
//                                         if (login.st.toString() == '1') {
//                                           // ToastMsg.showToastMsg("Successfully Added");
//                                           print('user response 2');
//                                           await _sendNotification();
//                                           print('user response3');
//                                           // Navigator.of(this.context).pushNamedAndRemoveUntil(
//                                           //     '/AppointmentListPage', ModalRoute.withName('/HomePage'));
//                                         } else{
//                                           ToastMsg.showToastMsg("Something went wrong");
//                                         }
//
//
//
//                                         // setState(() {
//                                         //   sendButton = false;
//                                         // });
//                                       }
//                                       // if (sendButton) {
//                                       //   _scrollController.animateTo(
//                                       //       _scrollController
//                                       //           .position.maxScrollExtent,
//                                       //       duration:
//                                       //       Duration(seconds: 1),
//                                       //       curve: Curves.easeOut);
//                                       //
//                                       //   sendchatmessage(
//                                       //       _controller.text,'1');
//                                       //
//                                       //   setState(() async {
//                                       //     final login = await ChatApi().PatinetSendMessage(
//                                       //         widget.appointmentDetails!.id.toString(),
//                                       //         widget.appointmentDetails!.uId.toString(),
//                                       //         widget.appointmentDetails!.doctId.toString(),
//                                       //         1,
//                                       //         1,
//                                       //         _controller.text,
//                                       //         null
//                                       //     );
//                                       //   });
//                                       //
//                                       //
//                                       //   _controller.clear();
//                                       //
//                                       //   setState(() {
//                                       //     sendButton = false;
//                                       //   });
//                                       // }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           // show ? emojiSelect() : Container(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               onWillPop: () {
//                 if (show) {
//                   setState(() {
//                     show = false;
//                   });
//                 } else {
//                   Navigator.pop(context);
//                 }
//                 return Future.value(false);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//
//   }
//
//
//   Widget iconCreation(IconData icons, Color color, String text,) {
//     return InkWell(
//       onTap: () {
//
//       },
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundColor: color,
//             child: Icon(
//               icons,
//               // semanticLabel: "Help",
//               size: 29,
//               color: Colors.white,
//             ),
//           ),
//           SizedBox(
//             height: 5,
//           ),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12,
//               // fontWeight: FontWeight.w100,
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   // Widget emojiSelect() {
//   //   return EmojiPicker(
//   //       rows: 4,
//   //       columns: 7,
//   //       onEmojiSelected: (emoji, category) {
//   //         print(emoji);
//   //         setState(() {
//   //           _controller.text = _controller.text + emoji.emoji;
//   //         });
//   //       });
//   // }
//
//   Widget _buildCard(prescriptionDetails) {
//     // _itemLength=notificationDetails.length;
//     return ListView.builder(
//         controller: _scrollController,
//         itemCount: prescriptionDetails.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => PrescriptionDetailsPage(
//                         title: prescriptionDetails[index].appointmentName,
//                         prescriptionDetails: prescriptionDetails[index])),
//               );
//             },
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ListTile(
//                     title: Text(prescriptionDetails[index].appointmentName,
//                         style: TextStyle(
//                           fontFamily: 'OpenSans-Bold',
//                           fontSize: 14.0,
//                         )),
//                     trailing: Icon(
//                       Icons.arrow_forward_ios,
//                       color: iconsColor,
//                       size: 20,
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "${prescriptionDetails[index].patientName}",
//                           style: TextStyle(
//                             fontFamily: 'OpenSans-SemiBold',
//                             fontSize: 14,
//                           ),
//                         ),
//                         Text(
//                           "By ${prescriptionDetails[index].drName}",
//                           style: TextStyle(
//                             fontFamily: 'OpenSans-SemiBold',
//                             fontSize: 14,
//                           ),
//                         ),
//                         Text(
//                           "${prescriptionDetails[index].appointmentDate} ${prescriptionDetails[index].appointmentTime}",
//                           style: TextStyle(
//                             fontFamily: 'OpenSans-Regular',
//                             fontSize: 10,
//                           ),
//                         ),
//                       ],
//                     )),
//               ),
//             ),
//           );
//         });
//   }
//   // _sendNotificationmessal() async {
//   //   String title = "New Message";
//   //   String body = "New Message has been added for #${widget.appointmentDetails!.id} please check it";
//   //   final notificationModel = NotificationModel(
//   //       title: title,
//   //       body: body,
//   //       uId: widget.appointmentDetails!.uId,
//   //       routeTo: "/LoginPage",
//   //       sendBy: "patient",
//   //       sendFrom: "Patient",
//   //       sendTo: "Doctor");
//   //   final msgAdded = await NotificationService.addData(notificationModel);
//   //   if (msgAdded == "success") {
//   //     final res = await UserService.getUserById(
//   //         widget.appointmentDetails!.uId); //get fcm id of specific user
//   //
//   //     HandleFirebaseNotification.sendPushMessage(res[0].fcmId.toString(), title, body);
//   //     await UpdateData.updateIsAnyNotification(
//   //         "usersList", widget.appointmentDetails!.uId, true);
//   //   }
//   // }
//   _sendNotification() async {
//     String title = "New Message Received";
//     String body = "For the appointment #${widget.appointmentDetails!.id}";
//     print('msgAdded3');
//     final notificationModel = NotificationModel(
//         title: title,
//         body: body,
//         uId: widget.appointmentDetails!.uId,
//         routeTo: "/UsersListForNotificationPage",
//         sendBy: "patient",
//         sendFrom: "Patient",
//         doctId: widget.appointmentDetails!.doctId,
//         sendTo: "Dcotor"
//     );
//     print('msgAdded2');
//     final msgAdded = await NotificationService.addData(notificationModel);
//     print('msgAdded');
//     final res = await DrProfileService.getDataByDrId(widget.appointmentDetails!.doctId); //get fcm id of specific user
//     print('123');
//          if (msgAdded == "success") {
//       HandleFirebaseNotification.sendPushMessage(res[0].fdmId.toString(), title, body);
//       await UpdateData.updateIsAnyNotification(
//           "usersList", widget.appointmentDetails!.uId, true);
//          }
//   }
// }
//
// Widget _buildCard2(prescriptionDetails,details)
// {
//   // _itemLength=notificationDetails.length;
//   return ListView.builder(
//     // controller: _scrollController,
//       itemCount: prescriptionDetails.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () {
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(
//             //       builder: (context) => PrescriptionDetailsPage(
//             //           title: prescriptionDetails[index].appointmentName,
//             //           prescriptionDetails: prescriptionDetails[index])),
//             // );
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => LabDetail(
//                       prescriptionDetails: prescriptionDetails[index],
//                       details
//                   )),
//             );
//
//           },
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ListTile(
//                   title: Text(prescriptionDetails[index].labName,
//                       style: TextStyle(
//                         fontFamily: 'OpenSans-Bold',
//                         fontSize: 14.0,
//                       )),
//                   trailing: Icon(
//                     Icons.arrow_forward_ios,
//                     color: iconsColor,
//                     size: 20,
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "${prescriptionDetails[index].date}",
//                         style: TextStyle(
//                           fontFamily: 'OpenSans-SemiBold',
//                           fontSize: 14,
//                         ),
//                       ),
//                       // Text(
//                       //   "${prescriptionDetails[index].appointmentDate} ${prescriptionDetails[index].appointmentTime}",
//                       //   style: TextStyle(
//                       //     fontFamily: 'OpenSans-Regular',
//                       //     fontSize: 10,
//                       //   ),
//                       // ),
//                     ],
//                   )),
//             ),
//           ),
//         );
//       });
// }
// Widget _prescriptionCard(prescriptionDetails) {
//   // _itemLength=notificationDetails.length;
//   return ListView.builder(
//     // controller: _scrollController,
//       itemCount: prescriptionDetails.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => PrescriptionDetailsPage(
//                       title: prescriptionDetails[index].appointmentName,
//                       prescriptionDetails: prescriptionDetails[index])),
//             );
//           },
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ListTile(
//                   title: Text(prescriptionDetails[index].prescription.toString().limitChars(20),
//                       style: TextStyle(
//                         fontFamily: 'OpenSans-Bold',
//                         fontSize: 14.0,
//                       )),
//                   trailing: Icon(
//                     Icons.arrow_forward_ios,
//                     color: iconsColor,
//                     size: 20,
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         prescriptionDetails[index].appointmentDate.toString().toStandardDateTime(),
//                         style: TextStyle(
//                           fontFamily: 'OpenSans-Regular',
//                           fontSize: 10,
//                         ),
//                       ),
//                     ],
//                   )),
//             ),
//           ),
//         );
//       });
// }
// Widget _labTestCard(prescriptionDetails,details) {
//   // _itemLength=notificationDetails.length;
//   return ListView.builder(
//     // controller: _scrollController,
//       itemCount: prescriptionDetails.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => LabDetail(
//                       prescriptionDetails: prescriptionDetails[index],
//                       details
//                   )),
//             );
//           },
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ListTile(
//                   title: Text(prescriptionDetails[index].labName,
//                       style: TextStyle(
//                         fontFamily: 'OpenSans-Bold',
//                         fontSize: 14.0,
//                       )),
//                   trailing: Icon(
//                     Icons.arrow_forward_ios,
//                     color: iconsColor,
//                     size: 20,
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(prescriptionDetails[index].date.toString().toStandardDate(),
//                         style: TextStyle(
//                           fontFamily: 'OpenSans-SemiBold',
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   )),
//             ),
//           ),
//         );
//       });
// }
// class AppointmentChatModal {
//   static prescriptionModal(context, appointmentId) {
//     showModalBottomSheet(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         backgroundColor: Colors.white,
//         context: context,
//         builder: (context) {
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 margin: EdgeInsets.all(10),
//                 child: Text('Prescriptions',
//                     style:TextStyle(
//                         fontSize:18,
//                         fontWeight: FontWeight.bold
//                     )),
//               ),
//               Container(
//                 height: 400,
//                 child: FutureBuilder(
//                     future: PrescriptionService.getDataByApId(appointmentId: appointmentId),
//                     //ReadData.fetchNotification(FirebaseAuth.instance.currentUser.uid),//fetch all times
//                     builder: (context, AsyncSnapshot snapshot) {
//                       if (snapshot.hasData)
//                         return snapshot.data.length == 0
//                             ? NoDataWidget()
//                             : Padding(
//                             padding: const EdgeInsets.only(
//                                 top: 0.0, left: 8, right: 8),
//                             child: _prescriptionCard(
//                               snapshot.data,
//                             ));
//                       else if (snapshot.hasError)
//                         return IErrorWidget(); //if any error then you can also use any other widget here
//                       else
//                         return LoadingIndicatorWidget();
//                     }),
//               ),
//             ],
//           );
//         });
//   }
//   static labModal(context, appointmentId,widget) {
//
//
//     showModalBottomSheet(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         backgroundColor: Colors.white,
//         context: context,
//         builder: (context) {
//           return Container(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   margin: EdgeInsets.all(10),
//                   child: Text('Labs Test',
//                       style:TextStyle(
//                           fontSize:18,
//                           fontWeight: FontWeight.bold
//                       )),
//                 ),
//                 Container(
//                   height: 400,
//                   child: FutureBuilder(
//                       future: PrescriptionService.getLabTest(appointmentId: appointmentId),
//                       //ReadData.fetchNotification(FirebaseAuth.instance.currentUser.uid),//fetch all times
//                       builder: (context, AsyncSnapshot snapshot) {
//                         if (snapshot.hasData) {
//                           return snapshot.data.length == 0
//                               ? NoDataWidget()
//                               : Padding(
//                               padding: const EdgeInsets.only(top: 0.0, left: 8, right: 8),
//                               child: _labTestCard(snapshot.data,widget)
//                           );
//                         } else if (snapshot.hasError) {
//                           print(snapshot.error);
//                           return IErrorWidget(); //if any error then you can also use any other widget here
//                         }else {
//                           return LoadingIndicatorWidget();
//                         }
//                       }),
//                 ),
//               ],
//             ),
//           );
//         });
//   }
//
// }
