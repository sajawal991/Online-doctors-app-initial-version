import 'dart:convert';
import 'dart:math';
import 'package:demopatient/Service/Noftification/handleFirebaseNotification.dart';
import 'package:demopatient/Service/Noftification/handleLocalNotification.dart';
import 'package:demopatient/model/medicineReminderModel.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/inputfields.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/datePicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class AddMedicineReminderPage extends StatefulWidget {
  const AddMedicineReminderPage({Key? key}) : super(key: key);

  @override
  State<AddMedicineReminderPage> createState() => _AddMedicineReminderPageState();
}

class _AddMedicineReminderPageState extends State<AddMedicineReminderPage> {
  String date="";
  bool dailyCheck=false;
  String? _selectedValue;
  List times=[];

  TextEditingController mNameController=TextEditingController();
  List<MedicineRModel> medicineRModel=[];
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationStateWidget(
        title: "Add",
        onPressed: () {
          //

          // final dd=DateTime.now() ;
          // print(dd.millisecondsSinceEpoch.toString());
         handleadd();
        },
        clickable: "true",
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          CAppBarWidget(title: "Add Medicine Reminder"),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: IBoxDecoration.upperBoxDecoration(),
                child: _buildBody()
            ),
          ),
        ],
      ),
    );
  }

  _buildBody() {
    return  Form(
      key: _formKey,
      child: ListView(
        children: [
          InputFields.commonInputField(mNameController, "Medicine Name", (item){
            return item.length>0?null:"Enter medicine name";
          }, TextInputType.text, 1),
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 20),
              const Text("Daily"),
              SizedBox(width: 10),
              Checkbox(
                  value:dailyCheck, onChanged: (e){
                setState(() {
                  dailyCheck=!dailyCheck;
                  final currentDate=DateTime.now();
                   date="${currentDate.year}-${currentDate.month}-${currentDate.day}";
                });
              }),
               const Text("Date"),
              Flexible(
                child: Checkbox(
                    value:!dailyCheck, onChanged: (e){
                  setState(() {
                    dailyCheck=!dailyCheck;
                    date="";

                  });
                }),
              ),
            ],
          ),
          Divider(),
         dailyCheck?Container():    Row(
            children: [
              SizedBox(width: 20),
              Text("Date:   $date",
              style: TextStyle(fontSize: 16),),
              IconButton(onPressed: ()async{
                final res = await IDatePicker.datePicker(context);
                setState((){
                  date=res;
                });
              }, icon: Icon(Icons.date_range))
            ],
          ),
          dailyCheck?Container():  Divider(),
          Padding(padding: EdgeInsets.only(left: 25,top: 25),child:Text("How Many Times",     style: TextStyle(fontSize: 16),) ),
          _dropDown(),
          ListView.builder(
            shrinkWrap: true,
              itemCount:times.length,
              itemBuilder: (context,index){
              return
            Row(
              children: [
                SizedBox(width: 20),
                Text("Time:   ${times[index]}"),
                IconButton(onPressed: ()async{
                  final TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime:TimeOfDay(hour: 13, minute: 00),
                    initialEntryMode: TimePickerEntryMode.dial,
                  );
                  setState((){
                    times[index]=(timeOfDay!.hour<10?"0"+timeOfDay.hour.toString():timeOfDay.hour.toString())+":"+ (timeOfDay.minute<10?"0"+timeOfDay.minute.toString():timeOfDay.minute.toString());
                  });
                }, icon: Icon(Icons.watch_later_outlined),
                )
              ],
            );
          })


        ],
      ),
    );
  }
  _dropDown() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 25, right: 25),
      child: DropdownButton<String>(
        focusColor: Colors.white,
        value: _selectedValue,
        //elevation: 5,
        style: TextStyle(color: Colors.white),
        iconEnabledColor: btnColor,
        items: <String>[
          '1',
          '2',
          '3',
          '4',
          '5',
          '6',
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        hint: Text(
          "How Many Times",
        ),
        onChanged: (String? value) {
          setState(() {
            // print(value);
            _selectedValue = value!;
            times.clear();
            for(int i=0;i<int.parse( value!);i++){
              times.add("--:--");
            }
          });
        },
      ),
    );
  }
  handleadd()async{
      if(_formKey.currentState!.validate()){

        if(date==""){
          ToastMsg.showToastMsg("Please fill date");
        }
        else if(times.isEmpty){
          ToastMsg.showToastMsg("Please select how many times");
        }
        else {
          bool isAddedAllData=true;
          for(int q=0;q<times.length;q++){
            if(times[q]=="--:--") {
            isAddedAllData = false;
            break;
          }
        }
          if(isAddedAllData){
             final res= await getAndSetData(mNameController.text,date);
             // print("data $res");

            if(res['status']){
              MedicineRModel medicineRModel =MedicineRModel(
                  date: date,
                  name: mNameController.text,
                  time: res['time'],
                  id: res['id'],
                daily: res['daily']
              );
              setState((){
                this.medicineRModel.add(medicineRModel);
              });
              List newData=[];
              for(var e in  this.medicineRModel){
                newData.add({"name":e.name,"time":e.time,"date":e.date,"id":e.id,"daily":e.daily});
              }
              String jsonTags = jsonEncode(newData);
              SharedPreferences prefs= await SharedPreferences.getInstance();
              prefs.setString("mr", jsonTags);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushNamed(context,"/MedicineReminderPage");
            }else{ToastMsg.showToastMsg("Something went wrong");}
          }else{
            ToastMsg.showToastMsg("Select All Time");
          }

        }
      }
  }
  Future  getAndSetData(mName,date)async {
    Map returnData=Map();
    String returnId="";
    String returnTime="";
    bool success=true;
    final getDate=date.toString().split("-");
    for(int i=0;i<times.length;i++){
      Random rng = new Random();
      int id=rng.nextInt(100000000);
      // print("******************************$id");
      final getTime=times[i].toString().split(":");
      final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.initializeTimeZones();
      final location=tz.setLocalLocation(tz.getLocation(currentTimeZone));
      try{
        var currentDateTime = tz.TZDateTime.from(DateTime(int.parse(getDate[0]),int.parse(getDate[1]),int.parse(getDate[2]),int.parse(getTime[0]),int.parse(getTime[1])), tz.local).add(new Duration(hours: 0));
        Time currentTime=Time(int.parse(getTime[0]),int.parse(getTime[1]));

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Medicine Reminder',
          'You have to take $mName',
            dailyCheck? _getNextInstanceOfTime(currentTime.hour,currentTime.minute):currentDateTime,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                'xxx79700', 'xxx34200',
                sound: RawResourceAndroidNotificationSound('alarm1'),
                importance: Importance.max,
                priority: Priority.high,
                  playSound: true,
              )),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'medicineReminder',
            matchDateTimeComponents: DateTimeComponents.time
        );
        // print("success ${times[i]} $id");
        if(returnTime=="") {
          returnTime ="${currentTime.hour}:${currentTime.minute}";
        } else {
          returnTime="$returnTime,${currentTime.hour}:${currentTime.minute}";
        }
        if(returnId=="") {
          returnId ="$id";
        } else {
          returnId="$returnId,$id";
        }
      }catch(e){
        // print("error ${times[i]} $id");
        // print(e);
        ToastMsg.showToastMsg("Please enter valid date and time");
        success=false;
        break;
      }
    }
    returnData['status']=success;
    returnData['id']=returnId;
    returnData['time']=returnTime;
    returnData['daily']=dailyCheck;
    return returnData;
  }
  _getNextInstanceOfTime(int hour, int min) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, min);
    final mySheduledDate=scheduledDate.subtract(Duration(days: 1));
    if (mySheduledDate.isBefore(now)) {
      // print("---------------Daily");
      scheduledDate = mySheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;

   //  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
   //  tz.TZDateTime scheduled = tz.TZDateTime(tz.local, year, month, day, hour, min);
   //  //if(scheduled.isBefore(now)) {
   //    print("Daily-----------------------");
   //    scheduled = scheduled.add(const Duration(days: 1));
   // // }
   //  return scheduled;
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
}
