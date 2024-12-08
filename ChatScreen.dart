import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:demopatient/Provider/notify_provider.dart';
import 'package:demopatient/Service/Firebase/readData.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/helper/extensions/date_time.dart';
import 'package:demopatient/helper/extensions/string.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import '../../Module/Doctor/Provider/DoctorProvider.dart';
import '../../Service/Apiservice/chatapi.dart';
import '../../Service/Apiservice/notification_services.dart';
import '../../Service/Firebase/updateData.dart';
import '../../Service/Model/ChatModel.dart';
import '../../Service/Noftification/handleFirebaseNotification.dart';
import '../../Service/notificationService.dart';
import '../../Service/pharma_req_service.dart';
import '../../Service/prescriptionService.dart';
import '../../config.dart';
import '../../model/appointmentModel.dart';
import '../../model/drProfielModel.dart';
import '../../model/notificationModel.dart';
import '../../model/pharma_req_model.dart';
import '../../utilities/color.dart';
import '../../utilities/toastMsg.dart';
import '../../widgets/errorWidget.dart';
import '../../widgets/loadingIndicator.dart';
import '../../widgets/noDataWidget.dart';
import 'dart:io';
import 'package:demopatient/Screen/appointment/ChatScreenWidget/labDetail.dart';
import 'package:demopatient/Screen/appointment/ChatScreenWidget/OwnMessgaeCrad.dart';
import '../jitscVideoCall.dart';
import '../prescription/prescriptionDetails.dart';
import '../resch/reSchTimeSlotPage.dart';
import '../resch/walkInReschPage.dart';
import 'ChatScreenWidget/message_card_loader.dart';
import 'appointmentDetailsPage.dart';

class ChatScreen extends StatefulWidget {
  AppointmentModel? appointmentDetails;
  String? doctorId;
  String? userId;
  String? doctorName;
  String? uId;
  ChatScreen(this.appointmentDetails, this.doctorId, this.doctorName, this.userId, this.uId, {Key? key}) : super(key: key);
  // final ChatModell? chatModel;
  // final ChatModell? sourchat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool showEmoji = false;
  int _groupValue = -1;
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = true;
  List<ChatClass> chatmessages = [];
  ValueNotifier<int> chatmessagesNotifier = ValueNotifier<int>(0);
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  NotificationServices services = NotificationServices();
  bool _isLoading = false;
  ValueNotifier<bool> _isLoadingChat = ValueNotifier<bool>(true);

  String chatUniqueId = '0';
  String doctorId = '0';
  String userId = '0';
  String doctorName = '0';
  String uId = '0';
  String pEmail = '';

  // IO.Socket socket;
  @override
  initState() {
    // connect();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   DrProfileModel? doctor = await Provider.of<DoctorProvider>(context, listen: false).doctor;
    // });

    super.initState();
    focusNode.addListener(() {
      // print("hassan 12");
      // print("hassan 1");
      setState(() {
        showEmoji = false;
      });
    });
    // apiGetMessages();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });

    // if(widget.appointmentDetails != null){
    //   chatUniqueId = widget.appointmentDetails!.id.toString();
    //   doctorId = widget.appointmentDetails!.doctId.toString();
    //   userId = widget.userId.toString();
    //   doctorName = widget.appointmentDetails!.doctName.toString();
    //   uId = widget.appointmentDetails!.uId.toString();
    //   pEmail = widget.appointmentDetails!.pEmail;
    // }else{
      chatUniqueId = '${widget.userId}${widget.doctorId}';
      doctorId = widget.doctorId.toString();
      userId = widget.userId.toString();
      doctorName = widget.doctorName.toString();
      uId = widget.uId.toString();

      setEmail();
    // }

    setState(() {

    });
  }

  setEmail() async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    pEmail = _prefs.getString("email") ?? '';
    setState(() {

    });
  }

  void dispose(){
    // unSetChatScreen();
    super.dispose();
  }

  List _imageUrls = [];
  void _scrollDown() {
    if (_scrollController.hasClients)
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 70,
        duration: Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
  }

  // void sendchatmessage(dynamic message,dynamic type) {
  //   setchatmessage(message,type);
  //   // socket.emit("message",
  //   //     {"message": message, "sourceId": sourceId, "targetId": targetId});
  // }
  //
  // void setchatmessage(dynamic message,dynamic type) {
  //   ChatClass messageModel = ChatClass(
  //     drprofileId: doctorId,
  //     appointmentId: widget.appointmentDetails!.id,
  //       userListId: uId.toString(),
  //       sender: '1',
  //       type: type,
  //       message: message,
  //       createdAt: DateTime.now());
  //   // print(chatmessages);
  //   chatmessages.add(messageModel);
  //   chatmessagesNotifier.value = 1;
  //
  //   // setState(() {
  //   //   chatmessages.add(ChatClass());
  //   // });
  // }

  final imagePicker = ImagePicker();
  late File imageFile;

  void getImage() async {

    PickedFile? image = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(image!.path);
    });
    Navigator.pop(context);
    _isLoadingChat.value = true;

        // sendchatmessage(image!.path, '3');
        // if(widget.appointmentDetails != null){
          final login = await ChatApi().PatinetSendMessage(
              chatUniqueId.toString(),
              uId.toString(),
              userId.toString(),
              doctorId.toString(),
              1,
              4,
              '',
              image);
        // }
        // print('send');
  }
  void getImagecamera() async {

    PickedFile? image = await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      imageFile = File(image!.path);
    });
    // print(1234);
    // sendchatmessage(image!.path, '4');
    Navigator.pop(context);
    _isLoadingChat.value = true;
    // print(123);

    // if(widget.appointmentDetails != null) {
      final login = await ChatApi().PatinetSendMessage(
          chatUniqueId.toString(),
          uId.toString(),
          userId.toString(),
          doctorId.toString(),
          1,
          4,
          '',
          image);
    // }
    // print('send');
  }
  void _handleFileSelection() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:  ['jpg', 'pdf', 'doc'],
    );

    if (result != null) {
        PlatformFile file = result.files.first;
        setState(() {
          // sendchatmessage(file!.path, '3');
        });

        Navigator.pop(context);
        _isLoadingChat.value = true;

      setState(() async {
        // if(widget.appointmentDetails != null) {
          final login = await ChatApi().PatinetSendMessage(
              chatUniqueId.toString(),
              uId.toString(),
              userId.toString(),
              doctorId.toString(),
              1,
              3,
              '',
              file);
        // }
        print('send');
      });

    } else {
      print('No file selected');
    }
  }
  TextEditingController _messageController = TextEditingController();

  bool _isUploading = false;
  bool _isEnableBtn = true;
  File? _file;

  static const senderColor = 0xFFDCF8C6;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotifyProvider>(context);
    // print(provider);
    return Stack(
      children: [
        // Image.asset(
        //   "assets/whatsapp_Back.png",
        //   height: MediaQuery.of(context).size.height,
        //   width: MediaQuery.of(context).size.width,
        //   fit: BoxFit.cover,
        // ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(55),
            child: AppBar(
              backgroundColor: appBarColor,
              leadingWidth: 76,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:6.0, right: 6.0),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.white
                      ),
                    ),
                    Consumer<DoctorProvider>(
                      builder: (context, provider, _) {
                        if(provider.doctor != null && provider.doctor!.profileImageUrl != null )
                          return CircleAvatar(
                          backgroundImage: NetworkImage(provider.doctor!.profileImageUrl.toString()),
                            radius: 20,
                            backgroundColor: Colors.blueGrey,
                          );

                        return CircleAvatar(
                          backgroundImage: NetworkImage('https://mydoctorjo.com/public/profile.jpg'),
                          radius: 20,
                          backgroundColor: Colors.blueGrey,
                        );
                      }
                    ),
                  ],
                ),
              ),
              title: InkWell(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if(widget.appointmentDetails != null)
                        Text(
                          doctorName,
                          style: TextStyle(
                            fontSize: 18.5,
                            fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),

                      if(widget.appointmentDetails != null)
                        Text(
                        widget.appointmentDetails!.clinicName.toString(),
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  splashRadius: 22,
                  padding: EdgeInsets.only(left:10,right:5),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.videocam, color: Colors.white),
                  onPressed: () async {
                    _isLoadingChat.value = true;
                    // if(widget.appointmentDetails != null) {
                      await ChatApi().PatinetSendMessage(
                          chatUniqueId.toString(),
                          uId.toString(),
                          userId.toString(),
                          doctorId,
                          2,
                          8,
                          "Call",
                          null);
                        Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context) =>
                              Meeting(
                                uid: uId,
                                doctid: doctorId,
                                email: pEmail,
                              )
                          ),
                        );
                    // }
                  },
                ),
                /*IconButton(
                  splashRadius: 22,
                  padding: EdgeInsets.only(left:5,right:5),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.info_outline, ),
                  onPressed: () {
                    showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.white,
                        context: context,
                        builder: (context) {

                          if(widget.appointmentDetails != null && widget.appointmentDetails!.description != '')
                            return Container(
                              color: Colors
                                  .transparent, //could change this to Color(0xFF737373),
                              //so you don't have to change MaterialApp canvasColor
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(10.0),
                                          topRight:
                                          const Radius.circular(10.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      widget.appointmentDetails!.description,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )),
                            );
                          else
                            return Container(
                              color: Colors.transparent, //could change this to Color(0xFF737373),
                              //so you don't have to change MaterialApp canvasColor
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(10.0),
                                          topRight:
                                          const Radius.circular(10.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text("Patient did not describe",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )),
                            );
                        });
                    // showModalBottomSheet(
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //     ),
                    //     backgroundColor: Colors.white,
                    //     context: context,
                    //     builder: (context) {
                    //       return  Container(
                    //         color: Colors.transparent, //could change this to Color(0xFF737373),
                    //         //so you don't have to change MaterialApp canvasColor
                    //         child:  Container(
                    //             decoration:  BoxDecoration(
                    //                 color: Colors.white,
                    //                 borderRadius:  BorderRadius.only(
                    //                     topLeft: const Radius.circular(10.0),
                    //                     topRight: const Radius.circular(10.0))),
                    //             child:  Padding(
                    //               padding: const EdgeInsets.all(12.0),
                    //               child: Text(widget.appointmentDetails!.description,style: TextStyle(
                    //                 color: Colors.black,
                    //                 fontWeight: FontWeight.normal,
                    //                 fontSize: 16,
                    //               ),),
                    //             )),
                    //       );
                    //     });

                  },
                ),*/
                IconButton(
                  splashRadius: 22,
                  padding: EdgeInsets.only(left:5,right:5),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.medication, color: Colors.white),
                  onPressed: () {
                    // if(widget.appointmentDetails != null){
                      AppointmentChatModal.prescriptionModal(
                          context, chatUniqueId);
                    // }
                  },
                ),
                IconButton(
                  splashRadius: 22,
                  padding: EdgeInsets.only(left:5,right:10),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.medical_services, color: Colors.white),
                  onPressed: () {
                    print('nouman');
                    // if(widget.appointmentDetails != null) {
                      AppointmentChatModal.labModal(
                          context, chatUniqueId,
                          widget.appointmentDetails);
                    // }
                  },
                ),
                /*InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Meeting(
                              uid: widget
                                  .appointmentDetails!
                                  .uId,
                              doctid: widget
                                  .appointmentDetails!
                                  .doctId,
                              email: widget
                                  .appointmentDetails!
                                  .pEmail,
                            )),

                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.videocam),
                    )),
                InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.white,
                          context: context,
                          builder: (context) {
                            return  Container(
                              color: Colors.transparent, //could change this to Color(0xFF737373),
                              //so you don't have to change MaterialApp canvasColor
                              child:  Container(
                                  decoration:  BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:  BorderRadius.only(
                                          topLeft: const Radius.circular(10.0),
                                          topRight: const Radius.circular(10.0))),
                                  child:  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(widget.appointmentDetails!.description,style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),),
                                  )),
                            );
                          });

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.info_outline),
                    )),
                InkWell(
                    onTap: () {
                      AppointmentChatModal.prescriptionModal(
                          context, chatUniqueId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.medication),
                    )),
                InkWell(
                    onTap: () {
                      // print('name');
                      // print(widget.appointmentDetails?.id.toString());
                      AppointmentChatModal.labModal(
                          context, chatUniqueId,widget.appointmentDetails);

                      // AppointmentChatModal.labModal(
                      //     context, chatUniqueId, widget.appointmentDetails);
                    },
                    child: Padding(

                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.medical_services),

                    )),*/
                // PopupMenuButton<String>(
                //   padding: EdgeInsets.all(0),
                //   onSelected: (value) {
                //     print(value);
                //   },
                //   itemBuilder: (BuildContext contesxt) {
                //     return [
                //       PopupMenuItem(
                //         child: Text("View Contact"),
                //         value: "View Contact",
                //       ),
                //       PopupMenuItem(
                //         child: Text("Media, links, and docs"),
                //         value: "Media, links, and docs",
                //       ),
                //       PopupMenuItem(
                //         child: Text("Whatsapp Web"),
                //         value: "Whatsapp Web",
                //       ),
                //       PopupMenuItem(
                //         child: Text("Search"),
                //         value: "Search",
                //       ),
                //       PopupMenuItem(
                //         child: Text("Mute Notification"),
                //         value: "Mute Notification",
                //       ),
                //       PopupMenuItem(
                //         child: Text("Wallpaper"),
                //         value: "Wallpaper",
                //       ),
                //     ];
                //   },
                // ),
                // PopupMenuButton(
                //   padding: EdgeInsets.all(0),
                //   onSelected: (value) {
                //     if(value == "appointment_detail"){
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => AppointmentDetailsPage(
                //               appointmentDetails: widget.appointmentDetails),
                //         ),
                //       );
                //     }else if(value == "status_change"){
                //       updateStatus();
                //     }
                //   },
                //   itemBuilder: (BuildContext contesxt) {
                //     return [
                //       PopupMenuItem(
                //         child: Text("Appointment Detail"),
                //         value: "appointment_detail",
                //       ),
                //       PopupMenuItem(
                //         child: Text("Status Change"),
                //         value: "status_change",
                //       ),
                //     ];
                //   },
                // ),
              ],
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: WillPopScope(
              child: Stack(
                children: [
                  // FutureBuilder(
                  //   future: messages,
                  //   builder: (context, AsyncSnapshot<ChatModel> snapshot) {
                  //     if (snapshot.hasData) {
                  //
                  //
                  //       return
                  // for firebase

                  Container(
                    height: MediaQuery.of(context).size.height - 145 - 40,
                    margin: EdgeInsets.only(bottom: 70),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: StreamBuilder(
                          stream: ReadData.fetchMessagesStream(chatUniqueId).orderByChild('time').onValue,
                          builder: (context, snapshot) {

                            if (snapshot.hasData && !snapshot.hasError) {
                              _isLoadingChat.value = false;

                              DatabaseEvent databaseEvent = snapshot.data as DatabaseEvent; // 👈 Get the DatabaseEvent from the AsyncSnapshot
                              var databaseSnapshot = databaseEvent.snapshot; // 👈 Get the DataSnapshot from the DatabaseEvent

                              if(databaseSnapshot.value != null){
                                Map<dynamic, dynamic> map = databaseSnapshot.value as Map<dynamic, dynamic>;

                                // List<ChatClass> chat = map.values.toList() as List<ChatClass>;
                                // print('Snapshossst4: ${databaseSnapshot.value}');
                                // List<Chat> list = map.values.toList();
                                // List<ChatClass> list = List<ChatClass>.from(map.values.toList().map((x) => ChatClass.fromJson(x)));

                                List _list = map.values.toList();
                                List<dynamic> list = _list..sort((a, b) => a['time'].compareTo(b['time']));

                                List<ChatClass> chat_class_list = [];
                                for(int i = 0; i < list.length; ++i){
                                  ChatClass chat = ChatClass.fromJson(jsonDecode(jsonEncode(list[i])));
                                  chat_class_list.add(chat);
                                }

                                _scrollDown();

                                return Column(
                                    children: [
                                      for(int i = 0; i < chat_class_list.length; ++i)
                                      // Text(chat_class_list[i].createdAt)
                                        OwnMessageCard(
                                            data: chat_class_list[i],
                                            appointmentDetails: widget.appointmentDetails,
                                            uId: uId,

                                            doctId: doctorId,
                                            pEmail: pEmail,
                                        ),

                                      // if(_isLoadingChat.value == true)
                                      ValueListenableBuilder(
                                        valueListenable: _isLoadingChat,
                                        builder: (context, value, _) {
                                          _scrollDown();
                                          if(_isLoadingChat.value == true) {
                                            return MessageCardShimmer(senderColor, Alignment.centerRight);
                                          } else {
                                            return Center();
                                          }
                                        }
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(8.0),
                                      //   child: Card(
                                      //     shadowColor: Colors.grey.shade500,
                                      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                                      //     elevation: 2,
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.all(12.0),
                                      //       child: Column(
                                      //         crossAxisAlignment: CrossAxisAlignment.start,
                                      //         children: [
                                      //           Text('Custom Offer',
                                      //             style: TextStyle(
                                      //               fontWeight: FontWeight.bold,
                                      //               fontSize: 18,
                                      //             ),),
                                      //           SizedBox(height: 2,),
                                      //           Text('DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription',
                                      //             maxLines: 2,
                                      //             overflow: TextOverflow.ellipsis,
                                      //             style: TextStyle(
                                      //               // fontWeight: FontWeight.bold,
                                      //               fontSize: 14,
                                      //               color: Colors.grey.shade500
                                      //             ),),
                                      //           SizedBox(height: 5,),
                                      //           Row(
                                      //             mainAxisAlignment: MainAxisAlignment.start,
                                      //             children: [
                                      //               Text('Total Amount: ',
                                      //                 style: TextStyle(
                                      //                   // fontWeight: FontWeight.bold,
                                      //                   fontSize: 16,
                                      //                 ),),
                                      //               Spacer(),
                                      //               Text('1000',
                                      //                 style: TextStyle(
                                      //                   fontWeight: FontWeight.bold,
                                      //                   fontSize: 16,
                                      //                 ),),
                                      //             ],
                                      //           ),
                                      //           SizedBox(height: 2,),
                                      //           Row(
                                      //             mainAxisAlignment: MainAxisAlignment.start,
                                      //             children: [
                                      //               Text('Installment Pay every xMonth:',
                                      //                 style: TextStyle(
                                      //                   // fontWeight: FontWeight.bold,
                                      //                   fontSize: 16,
                                      //                 ),),
                                      //               Spacer(),
                                      //               Text('3 Months',
                                      //                 style: TextStyle(
                                      //                   fontWeight: FontWeight.bold,
                                      //                   fontSize: 16,
                                      //                 ),),
                                      //             ],
                                      //           ),
                                      //           SizedBox(height: 2,),
                                      //           Row(
                                      //             mainAxisAlignment: MainAxisAlignment.start,
                                      //             children: [
                                      //               Text(
                                      //                   'Number of Installment:',
                                      //                 style: TextStyle(
                                      //                   // fontWeight: FontWeight.bold,
                                      //                   fontSize: 16,
                                      //                 ),),
                                      //               Spacer(),
                                      //               Text('1',
                                      //                 style: TextStyle(
                                      //                   fontWeight: FontWeight.bold,
                                      //                   fontSize: 16,
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //
                                      //           SizedBox(height: 5,),
                                      //           Divider(height: 25,),
                                      //           Row(
                                      //             mainAxisAlignment: MainAxisAlignment.start,
                                      //             children: [
                                      //               Text('Amount to Pay:',
                                      //                 style: TextStyle(
                                      //                   // fontWeight: FontWeight.bold,
                                      //                   fontSize: 16,
                                      //                 ),
                                      //               ),
                                      //               Spacer(),
                                      //               Text('100',
                                      //                 style: TextStyle(
                                      //                   fontWeight: FontWeight.bold,
                                      //                   fontSize: 16,
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //           // SizedBox(height: 5,),
                                      //           // Row(
                                      //           //   children: [
                                      //           //     Expanded(
                                      //           //       child: ElevatedButton(
                                      //           //         onPressed: () {
                                      //           //           Razorpay razorpay = Razorpay();
                                      //           //           var options = {
                                      //           //             'key': 'rzp_test_1DP5mmOlF5G5ag',
                                      //           //             'amount': 100,
                                      //           //             'name': 'Acme Corp.',
                                      //           //             'description': 'Fine T-Shirt',
                                      //           //             'retry': {'enabled': true, 'max_count': 1},
                                      //           //             'send_sms_hash': true,
                                      //           //             'prefill': {
                                      //           //               'contact': '8888888888',
                                      //           //               'email': 'test@razorpay.com'
                                      //           //             },
                                      //           //             'external': {
                                      //           //               'wallets': ['paytm']
                                      //           //             }
                                      //           //           };
                                      //           //           razorpay.on(
                                      //           //               Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
                                      //           //           razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                                      //           //               handlePaymentSuccessResponse);
                                      //           //           razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                                      //           //               handleExternalWalletSelected);
                                      //           //           razorpay.open(options);
                                      //           //         },
                                      //           //         style: ElevatedButton.styleFrom(
                                      //           //             backgroundColor: btnColor,
                                      //           //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
                                      //           //         ),
                                      //           //         child: Text(
                                      //           //           'Pay',
                                      //           //           style: TextStyle(color: Colors.white),
                                      //           //         ),
                                      //           //       ),
                                      //           //     ),
                                      //           //   ],
                                      //           // ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ]
                                );
                              }else{
                                return Container(
                                  height: MediaQuery.of(context).size.height - 160,
                                  child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.no_cell, size:45, color: Colors.grey),
                                          SizedBox(height:20),
                                          Text('Be the first to start communicate',
                                              style: TextStyle(
                                                  color: Colors.grey
                                              )
                                          ),
                                        ],
                                      )
                                  ),
                                );
                              }
                            }else{
                              return MessageScreenShimmer();
                            }
                          }),
                    ),
                  ),
                  // for api
                  /*Container(
                      height: MediaQuery.of(context).size.height - 170,
                      margin: EdgeInsets.only(bottom: 70),
                      child: ValueListenableBuilder(
                        valueListenable: chatmessagesNotifier,
                        builder: (context, value, _) {
                          _scrollDown();
                          chatmessagesNotifier.value = 0;
                          return Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              // reverse: true,
                              itemCount: chatmessages.length,
                              itemBuilder: (context, i) {
                                if (i == chatmessages.length) {
                                  return Container(
                                    height: 60,
                                  );
                                }
                                // if (messages[i].sender == "2") {
                                return OwnMessageCard(
                                    data: chatmessages[i],
                                    widget: widget.appointmentDetails.id
                                        .toString());
                                // } else {
                                //   return ReplyCard(
                                //     data: messages[i],
                                //   );
                                // }
                              },
                            ),
                          );
                        },
                      ),
                    ),*/
                  //     }
                  //     return Center(
                  //       child: CircularProgressIndicator(),
                  //     );
                  //   },
                  // ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      // height: 74,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 60,
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: 2, right: 2, bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xFFE1E1E1),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(25.0), // Radius for all corners
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _controller,
                                    focusNode: focusNode,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    onTap: (){
                                      showEmoji = false;
                                    },
                                    onChanged: (value) {
                                      // if (value.length > 0) {
                                      //   setState(() {
                                      //     sendButton = true;
                                      //   });
                                      // } else {
                                      //   setState(() {
                                      //     sendButton = false;
                                      //   });
                                      // }
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Type a message",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: IconButton(
                                        icon: Icon(
                                          showEmoji ? Icons.keyboard : Icons.emoji_emotions_outlined,
                                        ),
                                        onPressed: () {
                                          if (showEmoji == true) {
                                            // focusNode.unfocus();
                                            //   focusNode.canRequestFocus = false;
                      
                                            // show keyboard
                                            SystemChannels.textInput.invokeMethod('TextInput.show');
                                          }else{
                                            // hide keyboard
                                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                                          }
                      
                                          setState(() {
                                            showEmoji = !showEmoji;
                                          });
                                        },
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            padding:EdgeInsets.zero,
                                            splashRadius: 22,
                                            icon: const Icon(Icons.attach_file),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                backgroundColor:
                                                Colors.transparent,
                                                context: context,
                                                builder: (builder) =>
                                                Container(
                                                  height: 175,
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Card(
                                                    margin: const EdgeInsets.all(18.0),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10,right: 10, top: 20),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      _handleFileSelection();
                                                                    },
                                                                    child: CircleAvatar(
                                                                      radius: 30,
                                                                      backgroundColor: Colors.indigo,
                                                                      child: Icon(
                                                                        Icons.insert_drive_file,
                                                                        // semanticLabel: "Help",
                                                                        size: 29,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 10,),
                                                                  Text(
                                                                    'Document',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      // fontWeight: FontWeight.w100,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(width: 40,),
                                                              Column(
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      getImagecamera();
                                                                    },
                                                                    child: CircleAvatar(
                                                                      radius: 30,
                                                                      backgroundColor: Colors.pink,
                                                                      child: Icon(
                                                                        Icons.camera_alt,
                                                                        // semanticLabel: "Help",
                                                                        size: 29,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Text(
                                                                    'Camera',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      // fontWeight: FontWeight.w100,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(width: 40,),
                                                              Column(
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      getImage();
                                                                    },
                                                                    child: const CircleAvatar(
                                                                      radius: 30,
                                                                      backgroundColor: Colors.purple,
                                                                      child: Icon(
                                                                        Icons.insert_photo,
                                                                        // semanticLabel: "Help",
                                                                        size: 29,
                                                                        color: Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Text(
                                                                    'Gallery',
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      // fontWeight: FontWeight.w100,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 30,),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ));;
                                            },
                                          ),
                                          IconButton(
                                            splashRadius: 22,
                                            icon: Icon(Icons.camera_alt, ),
                                            onPressed: () {
                                              getImagecamera();
                                            },
                                          ),
                                        ],
                                      ),
                                      contentPadding: EdgeInsets.all(5),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8,
                                  right: 2,
                                  left: 2,
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFF128C7E),
                                  child: IconButton(
                                    icon: Icon(
                                      sendButton ? Icons.send : Icons.send, // mic
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      // print(_controller.text);
                      
                                      if (sendButton) {
                                        String msg = _controller.text;
                      
                                        // for api
                                        // setchatmessage(msg, '1');
                      
                                        _controller.clear();
                                        _isLoadingChat.value = true;
                      
                                        // if(widget.appointmentDetails != null) {
                                          await ChatApi().PatinetSendMessage(
                                              chatUniqueId.toString(),
                                              uId.toString(),
                                              userId.toString(),
                                              doctorId.toString(),
                                              1,
                                              1,
                                              msg,
                                              null);
                                        // }
                                        // print('data insrted20');
                      
                                        // if (login.st.toString() == '1') {
                                        //   // ToastMsg.showToastMsg("Successfully Added");
                                        //   print('user response 2');
                                        //   await _sendNotificationmessal();
                                        //   print('user response3');
                                        //   // Navigator.of(this.context).pushNamedAndRemoveUntil(
                                        //   //     '/AppointmentListPage', ModalRoute.withName('/HomePage'));
                                        // } else{
                                        //   ToastMsg.showToastMsg("Something went wrong");
                                        // }
                      
                                        // setState(() {
                                        //   sendButton = false;
                                        // });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          showEmoji == true ? emojiSelect() : Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onWillPop: () {
                if (showEmoji) {
                  setState(() {
                    showEmoji = false;
                  });
                } else {
                  Navigator.pop(context);
                }
                return Future.value(false);
              },
            ),
          )
        ),
      ],
    );
  }


  void offerpay(){
    setState(() {
      _isLoading=true;
    });
    var options = {
      'key': razorpayKeyId,
      'amount': '100',
      'name':  "Nmn" ,
      'description': "Add Money To Wallet",
      'prefill': {
        'contact': '1234567890',
        'email': 'abc123@gmail.com'
      },
      "notify": {"sms": true, "email": true},
      "method": {
        "netbanking": true,
        "card": true,
        "wallet": false,
        'upi': true,
      },
    };

    // try {
    //   _razorpay!.open(options);
    // } catch (e) {
    //   debugPrint('Error: e');
    // }
  }

  Widget emojiSelect() {
    return SizedBox(
      height:250,
      width:MediaQuery.of(context).size.width,
      child: EmojiPicker(
        // onEmojiSelected: (category, Emoji emoji) {
        //   // Do something when emoji is tapped (optional)
        //   _controller.text = _controller.text + emoji.emoji;
        // },
        // onBackspacePressed: () {

        //   // Do something when the user taps the backspace button (optional)
        //   // Set it to null to hide the Backspace-Button
        // },
        textEditingController: _controller, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
        config: Config(
          // columns: 7,
          // emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
          // verticalSpacing: 0,
          // horizontalSpacing: 0,
          // gridPadding: EdgeInsets.zero,
          // initCategory: Category.RECENT,
          // bgColor: Color(0xFFF2F2F2),
          // indicatorColor: Colors.blue,
          // iconColor: Colors.grey,
          // iconColorSelected: Colors.blue,
          // backspaceColor: Colors.blue,
          // skinToneDialogBgColor: Colors.white,
          // skinToneIndicatorColor: Colors.grey,
          // enableSkinTones: true,
          // recentTabBehavior: RecentTabBehavior.RECENT,
          // recentsLimit: 28,
          // noRecents: const Text(
          //   'No Recents',
          //   style: TextStyle(fontSize: 20, color: Colors.black26),
          //   textAlign: TextAlign.center,
          // ), // Needs to be const Widget
          // loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
          // tabIndicatorAnimDuration: kTabScrollDuration,
          // categoryIcons: const CategoryIcons(),
          // buttonMode: ButtonMode.MATERIAL,
        ),
      ),
    );

    // return EmojiPicker(
    //     rows: 4,
    //     columns: 7,
    //     onEmojiSelected: (emoji, category) {
    //       // print(emoji);
    //       setState(() {
    //         _controller.text = _controller.text + emoji.emoji;
    //       });
    //     });
  }
  Widget _myRadioButton({String? title, int? value, onChanged}) {
    return RadioListTile(
      activeColor: btnColor,
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged, //onChanged,
      title: Text(title ?? ""),
    );
  }
  updateStatus() {
    return showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: new Text("Choose a status"),
            content: Container(
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // _myRadioButton(
                    //     title: "Confirmed",
                    //     value: 0,
                    //     onChanged: (newValue) => setState(() {
                    //       _groupValue = newValue;
                    //     })),
                    // _myRadioButton(
                    //   title: "Visited",
                    //   value: 1,
                    //   onChanged: (newValue) =>
                    //       setState(() => _groupValue = newValue),
                    // ),
                    // _myRadioButton(
                    //   title: "Pending",
                    //   value: 2,
                    //   onChanged: (newValue) =>
                    //       setState(() => _groupValue = newValue),
                    // ),
                    // _myRadioButton(
                    //   title: "Reject",
                    //   value: 3,
                    //   onChanged: (newValue) =>
                    //       setState(() => _groupValue = newValue),
                    // ),
                    _myRadioButton(
                      title: "Reschedule",
                      value: 4,
                      onChanged: (newValue) =>
                          setState(() => _groupValue = newValue),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                  ),
                  child: new Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    switch (_groupValue) {


                      case 1:
                      {
                          Navigator.of(context).pop();
                          _handleRescheduleBtn();
                        }
                        break;
                      default:
                      // print("Not Select");
                        break;
                    }
                  }),
              new ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                  ),
                  child: new Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              // usually buttons at the bottom of the dialog
            ],
          );
        });
      },
    );
  }
  _handleRescheduleBtn() {

    widget.appointmentDetails!.appointmentStatus ==
        "Canceled"
        ? null
        : () {
      if (widget.appointmentDetails!.walkin == "1") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WalkinReschTimeSlotPage(
                  appDate:
                  widget.appointmentDetails!.appointmentDate,
                  appId: chatUniqueId,
                  ageController: widget.appointmentDetails!.age,
                  cityController:
                  widget.appointmentDetails!.pCity,
                  desController:
                  widget.appointmentDetails!.description,
                  emailController:
                  widget.appointmentDetails!.pEmail,
                  firstNameController:
                  widget.appointmentDetails!.pFirstName,
                  lastNameController:
                  widget.appointmentDetails!.pLastName,
                  phoneNumberController:
                  widget.appointmentDetails!.pPhn,
                  selectedGender:
                  widget.appointmentDetails!.gender,
                  serviceName:
                  widget.appointmentDetails!.serviceName,
                  serviceTimeMin: int.parse(widget
                      .appointmentDetails!.serviceTimeMin
                      .toString()),
                  doctName: doctorName,
                  hospitalName: widget.appointmentDetails!.hName,
                  deptName: widget.appointmentDetails!.department,
                  doctId: doctorId,
                  clinicId: widget.appointmentDetails!.clinicId,
                  cityId: widget.appointmentDetails!.cityId,
                  deptId: widget.appointmentDetails!.deptId,
                  cityName: widget.appointmentDetails!.cityName,
                  clinicName:
                  widget.appointmentDetails!.clinicName,
                ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReschTimeSlotPage(
                  appDate:
                  widget.appointmentDetails!.appointmentDate,
                  appId: chatUniqueId,
                  ageController: widget.appointmentDetails!.age,
                  cityController:
                  widget.appointmentDetails!.pCity,
                  desController:
                  widget.appointmentDetails!.description,
                  emailController:
                  widget.appointmentDetails!.pEmail,
                  firstNameController:
                  widget.appointmentDetails!.pFirstName,
                  lastNameController:
                  widget.appointmentDetails!.pLastName,
                  phoneNumberController:
                  widget.appointmentDetails!.pPhn,
                  selectedGender:
                  widget.appointmentDetails!.gender,
                  serviceName:
                  widget.appointmentDetails!.serviceName,
                  serviceTimeMin: int.parse(widget
                      .appointmentDetails!.serviceTimeMin
                      .toString()),
                  doctName: doctorName,
                  hospitalName: widget.appointmentDetails!.hName,
                  deptName: widget.appointmentDetails!.department,
                  doctId: doctorId,
                  clinicId: widget.appointmentDetails!.clinicId,
                  cityId: widget.appointmentDetails!.cityId,
                  deptId: widget.appointmentDetails!.deptId,
                  cityName: widget.appointmentDetails!.cityName,
                  clinicName:
                  widget.appointmentDetails!.clinicName,
                ),
          ),
        );
      }
    };

  }

  Widget iconCreation(IconData icons, Color color, String text,) {
    return InkWell(
      onTap: () {

      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

/*  Widget _buildCard(prescriptionDetails) {
    // _itemLength=notificationDetails.length;
    return ListView.builder(
        controller: _scrollController,
        itemCount: prescriptionDetails.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PrescriptionDetailsPage(
                        title: prescriptionDetails[index].appointmentName,
                        prescriptionDetails: prescriptionDetails[index])),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                    title: Text(prescriptionDetails[index].appointmentName,
                        style: TextStyle(
                          fontFamily: 'OpenSans-Bold',
                          fontSize: 14.0,
                        )),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: iconsColor,
                      size: 20,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${prescriptionDetails[index].patientName}",
                          style: TextStyle(
                            fontFamily: 'OpenSans-SemiBold',
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "By ${prescriptionDetails[index].drName}",
                          style: TextStyle(
                            fontFamily: 'OpenSans-SemiBold',
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${prescriptionDetails[index].appointmentDate} ${prescriptionDetails[index].appointmentTime}",
                          style: TextStyle(
                            fontFamily: 'OpenSans-Regular',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          );
        });
  }

  _sendNotification() async {
    String title = "New Message Received";
    String body = "For the appointment #${chatUniqueId}";
    final notificationModel = NotificationModel(
        title: title,
        body: body,
        uId: uId,
        routeTo: "/UsersListForNotificationPage",
        sendBy: "patient",
        sendFrom: "Patient",
        doctId: doctorId,
        sendTo: "Dcotor"
    );

    final msgAdded = await NotificationService.addData(notificationModel);

    final res = await DrProfileService.getDataByDrId(doctorId); //get fcm id of specific user

         if (msgAdded == "success") {
      HandleFirebaseNotification.sendPushMessage(res[0].fdmId.toString(), title, body);
      await UpdateData.updateIsAnyNotification(
          "usersList", uId, true);
         }
  }*/
}

/*Widget _buildCard2(prescriptionDetails,details) {
  // _itemLength=notificationDetails.length;
  return ListView.builder(
    // controller: _scrollController,
      itemCount: prescriptionDetails.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //       builder: (context) => PrescriptionDetailsPage(
            //           title: prescriptionDetails[index].appointmentName,
            //           prescriptionDetails: prescriptionDetails[index])),
            // );

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LabDetail(
                      prescriptionDetails: prescriptionDetails[index],

                  )),
            );

          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                  title: Text(prescriptionDetails[index].labName,
                      style: TextStyle(
                        fontFamily: 'OpenSans-Bold',
                        fontSize: 14.0,
                      )),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: iconsColor,
                    size: 20,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${prescriptionDetails[index].date}",
                        style: TextStyle(
                          fontFamily: 'OpenSans-SemiBold',
                          fontSize: 14,
                        ),
                      ),
                      // Text(
                      //   "${prescriptionDetails[index].appointmentDate} ${prescriptionDetails[index].appointmentTime}",
                      //   style: TextStyle(
                      //     fontFamily: 'OpenSans-Regular',
                      //     fontSize: 10,
                      //   ),
                      // ),
                    ],
                  )),
            ),
          ),
        );
      });
}*/
void handlePaymentSuccessResponse(){
  print('a');
}
void handlePaymentErrorResponse(){
  print('b');
}
void handleExternalWalletSelected(){
  print('a');
}

Widget _prescriptionCard(prescriptionDetails) {
  // _itemLength=notificationDetails.length;
  return ListView.builder(
    // controller: _scrollController,
      itemCount: prescriptionDetails.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PrescriptionDetailsPage(
                      title: prescriptionDetails[index].appointmentName,
                      prescriptionDetails: prescriptionDetails[index])),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                  title: Text(prescriptionDetails[index].prescription.toString().limitChars(20),
                      style: TextStyle(
                        fontFamily: 'OpenSans-Bold',
                        fontSize: 14.0,
                      )),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: iconsColor,
                    size: 20,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescriptionDetails[index].appointmentDate.toString().toStandardDateTime(),
                        style: TextStyle(
                          fontFamily: 'OpenSans-Regular',
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        );
      });
}
Widget _labTestCard(prescriptionDetails,details) {
  // _itemLength=notificationDetails.length;
  return ListView.builder(
    // controller: _scrollController,
      itemCount: prescriptionDetails.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LabDetail(
                      prescriptionDetails: prescriptionDetails[index],)),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                  title: Text(prescriptionDetails[index].labName,
                      style: TextStyle(
                        fontFamily: 'OpenSans-Bold',
                        fontSize: 14.0,
                      )),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: iconsColor,
                    size: 20,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prescriptionDetails[index].date.toString().toStandardDate(),
                        style: TextStyle(
                          fontFamily: 'OpenSans-SemiBold',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        );
      });
}

class AppointmentChatModal {
  static prescriptionModal(context, appointmentId) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: Text('Prescriptions',
                    style:TextStyle(
                        fontSize:18,
                        fontWeight: FontWeight.bold
                    )),
              ),
              Container(
                height: 400,
                child: FutureBuilder(
                    future: PrescriptionService.getDataByApId(appointmentId: appointmentId),
                    //ReadData.fetchNotification(FirebaseAuth.instance.currentUser.uid),//fetch all times
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData)
                        return snapshot.data.length == 0
                            ? NoDataWidget()
                            : Padding(
                            padding: const EdgeInsets.only(
                                top: 0.0, left: 8, right: 8),
                            child: _prescriptionCard(
                              snapshot.data,
                            ));
                      else if (snapshot.hasError)
                        return IErrorWidget(); //if any error then you can also use any other widget here
                      else
                        return LoadingIndicatorWidget();
                    }),
              ),
            ],
          );
        });
  }
  static labModal(context, appointmentId,widget) {


    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text('Lab Tests',
                      style:TextStyle(
                          fontSize:18,
                          fontWeight: FontWeight.bold
                      )),
                ),
                Container(
                  height: 400,
                  child: FutureBuilder(
                      future: PrescriptionService.getLabTest(appointmentId: appointmentId),
                      //ReadData.fetchNotification(FirebaseAuth.instance.currentUser.uid),//fetch all times
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data.length == 0
                              ? NoDataWidget()
                              : Padding(
                              padding: const EdgeInsets.only(top: 0.0, left: 8, right: 8),
                              child: _labTestCard(snapshot.data,widget)
                          );
                        } else if (snapshot.hasError) {

                          return IErrorWidget(); //if any error then you can also use any other widget here
                        }else {
                          return LoadingIndicatorWidget();
                        }
                      }),
                ),
              ],
            ),
          );
        });
  }

}
