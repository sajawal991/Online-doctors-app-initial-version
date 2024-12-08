import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:demopatient/Service/Noftification/handleLocalNotification.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/inputfields.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/datePicker.dart';
import 'package:demopatient/model/medicineReminderModel.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:time_range_picker/time_range_picker.dart';

import '../widgets/paddingAdjustWidget.dart';

class MedicineReminderPage extends StatefulWidget {

  const MedicineReminderPage({Key? key}) : super(key: key);

  @override
  _MedicineReminderPageState createState() => _MedicineReminderPageState();
}

class _MedicineReminderPageState extends State<MedicineReminderPage> {
  Timer? timer;
  int counter=0;
  List<MedicineRModel> medicineRModel=[];
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  var rng = new Random(1);
  @override
  void initState() {
    setData();

    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    if(timer!=null)
    timer!.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationStateWidget(
        title: "Add New".tr,
        onPressed: () {
          Navigator.pushNamed(context, "/AddMedicineReminderPage");
        },
        clickable: "true",
      ),
      // floatingActionButton: FloatingActionButton(
      //     elevation: 0.0,
      //     child: IconButton(
      //         icon: Icon(Icons.add),
      //         onPressed: ()  {
      //          // _buildAddDialogBox();
      //         }),
      //     backgroundColor: btnColor,
      //     onPressed: () {}),
      body: Stack(

        clipBehavior: Clip.none,
        children: <Widget>[
          CAppBarWidget(title: "Medicine Reminder".tr),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
                height: MediaQuery.of(context).size.height,
                // decoration: IBoxDecoration.upperBoxDecoration(),
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: _buildBody()
            ),
          ),
        ],
      ),
    );
  }

  Future <bool> getAndSetData(mName,date,time,id)async {
    bool success=true;
    // print(id);
    final getDate=date.toString().split("-");
    // print(getDate[0]);
    // print(getDate[1]);
    // print(getDate[2]);
    final getTime=time.toString().split(":");
    // print(getTime[0]);
    // print(getTime[1]);
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    final location=tz.setLocalLocation(tz.getLocation(currentTimeZone));
    try{
      var currentDateTime = tz.TZDateTime.from(DateTime(int.parse(getDate[0]),int.parse(getDate[1]),int.parse(getDate[2]),int.parse(getTime[0]),int.parse(getTime[1])), tz.local).add(new Duration(hours: 0));
     //var currentTime=currentDateTime.time;
      Time currentTime=Time(int.parse(getTime[0]),int.parse(getTime[1]));

      // await flutterLocalNotificationsPlugin.showDailyAtTime(id,
      //     'Medicine Reminder',
      //     'You have to take $mName',
      //     _getNextInstanceOfTime(currentTime.hour,currentTime.minute),
      //     const NotificationDetails(
      //   android: AndroidNotificationDetails(
      //   'your channel id', 'your channel name',
      // )));

      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Medicine Reminder',
          'You have to take $mName',
        _getNextInstanceOfTime(currentTime.hour,currentTime.minute),
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'your channel id', 'your channel name',
                  )),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          // matchDateTimeComponents: DateTimeComponents.time
      );
    }catch(e){
      success=false;
      // print(e);
    }
    return success;
  }
  _getNextInstanceOfTime(int hour, int min) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, min);
    if(scheduled.isBefore(now)) {
      scheduled = scheduled.add(Duration(days: 1));
    }
    return scheduled;
  }
  static List<MedicineRModel> dataFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<MedicineRModel>.from(
        data.map((item) => MedicineRModel.fromJson(item)));
  }
  setData()async{
    SharedPreferences prefs= await SharedPreferences.getInstance();

    if(prefs.getString("mr")!=null)
    {
      String objText = prefs.getString("mr")??"";

      setState(() {
        medicineRModel =  dataFromJson(objText);
      });
    }
  }

  _buildBody() {
    return medicineRModel.length == 0 ?
    Center(child: Text("No reminder found".tr)) :
    MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
          itemCount: medicineRModel.length,
          itemBuilder: (context,index){
            MedicineRModel data=medicineRModel[index];
            return
              PaddingAdjustWidget(
                index: index,
                itemInRow: 1,
                length: medicineRModel.length,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color
                    border: Border.all(
                      color: Color(0xFFE1E1E1), // Border color
                      width: 0.5, // Border width
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0), // Radius for all corners
                    ),
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    trailing: IconButton(
                      onPressed: ()async{
                        final ids=this.medicineRModel[index].id.toString().split(",");
                        for(var e in ids){
                          await  flutterLocalNotificationsPlugin.cancel(int.parse(e));
                          // print("deleted $e");
                        }

                        setState(() {
                          this.medicineRModel.removeAt(index);
                        });
                        List newData=[];
                        for(var e in  this.medicineRModel){
                          newData.add({"name":e.name,"time":e.time,"date":e.date,"id":e.id,"daily":e.daily});
                        }
                        String jsonTags = jsonEncode(newData);
                        SharedPreferences prefs= await SharedPreferences.getInstance();
                        prefs.setString("mr", jsonTags);
                        //
                        //

                      },
                      icon: const Icon(Icons.delete,color: Colors.red,),
                    ),
                    title: Text(data.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox( height:10),
                        data.daily?Container(): Text("Date: "+data.date),
                        data.daily?Container(): SizedBox( height:10),
                       getTime(data.time),
                        data.daily?const SizedBox( height:10):Container(),
                        data.daily?const Text("Daily Schedule"):Container(),
                      ],
                    ),
                  ),
                ),
              );
          }),
    );
  }
  _buildAddDialogBox(){
    String date="";
    String time="";
    TextEditingController mNameController=TextEditingController();
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const  Text("Add New"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InputFields.commonInputField(mNameController, "Medicine Name", (item){
                    return item.length>0?null:"Enter medicine name";
                  }, TextInputType.text, 1),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text("Date:   $date"),
                      IconButton(onPressed: ()async{
                        final res = await IDatePicker.datePicker(context);
                        setState((){
                          date=res;
                        });
                      }, icon: Icon(Icons.date_range))
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Text("Time:   $time"),
                      IconButton(onPressed: ()async{
                        final TimeOfDay? timeOfDay = await showTimePicker(
                          context: context,
                          initialTime:TimeOfDay(hour: 13, minute: 00),
                          initialEntryMode: TimePickerEntryMode.dial,
                        );
                        setState((){
                          time=(timeOfDay!.hour<10?"0"+timeOfDay.hour.toString():timeOfDay.hour.toString())+":"+ (timeOfDay.minute<10?"0"+timeOfDay.minute.toString():timeOfDay.minute.toString());
                        });


                      }, icon: Icon(Icons.watch_later_outlined),
                      )
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: new ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text("Add",style: TextStyle(
                          fontSize: 16
                      ),),
                    ),
                    onPressed: ()async{
                      if(_formKey.currentState!.validate()){
                        int id=rng.nextInt(100000000);
                        if(date!=""&&time!=""){
                          final res= await getAndSetData(mNameController.text,date,time,id);
                          if(res){
                            MedicineRModel medicineRModel =MedicineRModel(
                                date: date,
                                name: mNameController.text,
                                time: time,
                                id: id.toString()
                            );

                            setState((){
                              this.medicineRModel.add(medicineRModel);

                            });
                            List newData=[];
                            for(var e in  this.medicineRModel){
                              newData.add({"name":e.name,"time":e.time,"date":e.date,"id":e.id});
                            }
                            String jsonTags = jsonEncode(newData);
                            SharedPreferences prefs= await SharedPreferences.getInstance();
                            prefs.setString("mr", jsonTags);
                            Navigator.pop(context);
                          }else{ToastMsg.showToastMsg("Something went wrong");}

                        }else ToastMsg.showToastMsg("Please fill date and time");
                      }

                      //  Get.back();
                    }),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: new ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text("Cancel",style: TextStyle(
                          fontSize: 16
                      )),
                    ),
                    onPressed: (){
                      Navigator.pop(context);

                      //  Get.back();
                    }),
              ),

              // usually buttons at the bottom of the dialog
            ],
          );
        });
      },
    );
  }

  getTime(time) {
    String returnTime="";
    final mainTime=time.toString().split(",");
    for(int i=0;i<mainTime.length;i++){
      if(i==0) {
        returnTime=getFomraterTime(mainTime[i]);
      }else{
        returnTime="$returnTime   ${getFomraterTime(mainTime[i])}";
      }
    }
    return Text("Time: $returnTime");
  }

  String getFomraterTime(String mainTime) {
    final splitTime=mainTime.split(":");
    final min=int.parse(splitTime[0])>10?splitTime[0]:"0${splitTime[0]}";
    final sec=int.parse(splitTime[1])>10?splitTime[1]:"0${splitTime[1]}";
    // print("$min 88 $sec");
    return "$min:$sec";
  }


}
