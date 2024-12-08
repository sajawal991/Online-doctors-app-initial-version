import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/utilities/dialogBox.dart';
import 'package:demopatient/utilities/toastMsg.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/buttonsWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
final  channleId="my_foreground808";
final notifiaionId=808;

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  Timer? _timerx;
  bool playSoundN=false;
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();


  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");
  final enableSound=  preferences.getBool('enableSound')??true;
  // print("kkkkkkkkkkkkkkkkkkkkkkkkk $enableSound");

  final int selectedMinValue=preferences.getString('selectedMinValue')==null?19:int.parse(preferences.getString('selectedMinValue')!)-1;
  // print("stttttttttttttttiiiiimmmmmmmm $selectedMinValue");


  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final initTimeF=DateTime.now();

  var newDifference;
  int storedMin=preferences.getInt("storedMin")??0;
  int  storedSec=preferences.getInt("storedSec")??0;
  var newAuction;
  bool isTakeLookTimer=preferences.getBool("isTakeLookTimer")??false;
  if(isTakeLookTimer) {
    newAuction = initTimeF!.add(Duration(seconds:(20-storedSec).abs() ));
  } else {
    newAuction = initTimeF!.add(Duration(minutes:(selectedMinValue-storedMin).abs(),seconds:(60-storedSec).abs() ));

  }

  final startTimer=   preferences.getBool("startTimer")??false;
  final pauseTimer= preferences.getBool('pauseTimer')??false;


  if(startTimer) {
    if(!pauseTimer) {
      _timerx = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (newAuction != null) {
          newDifference = newAuction!.difference(DateTime.now());
        }
        final difMin = newDifference?.inMinutes.remainder(60) ?? 0;
        final min = (selectedMinValue - difMin).abs();

        await preferences.setInt("storedMin", min.toInt());
        final difSec = newDifference?.inSeconds.remainder(60) ?? 0;
        if (isTakeLookTimer) {
          final sec = (20 - difSec).abs();
          await preferences.setInt("storedSec", sec.toInt());
        } else {
          final sec = (60 - difSec).abs();

          await preferences.setInt("storedSec", sec.toInt());
        }
        if (newAuction!.isBefore(DateTime.now())) {
          // print("Need to clanlexxxxxxxxxxxxxxxxxxxxxxx");
          if (isTakeLookTimer) {
            isTakeLookTimer = false;
            preferences.setBool("isTakeLookTimer", false);
            await preferences.setInt("storedMin", 0);
            await preferences.setInt("storedSec", 0);
            final initTimex = DateTime.now();
            newAuction = initTimex!
                .add(Duration(minutes: (selectedMinValue).abs(), seconds: (60).abs()));

          } else {
            isTakeLookTimer = true;
            preferences.setBool("isTakeLookTimer", true) ?? false;
            await preferences.setInt("storedMin", 0);
            await preferences.setInt("storedSec", 0);
            final initTimex = DateTime.now();
            newAuction = initTimex!.add(Duration(seconds: (20).abs()));
            playSoundN = true;
          }
        }
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            /// OPTIONAL for use custom notification
            /// the notification id must be equals with AndroidConfiguration when you call configure() method.

            flutterLocalNotificationsPlugin.show(
              // payload: "eyeReminder",
                notifiaionId,
                isTakeLookTimer
                    ? 'Screen Time Break Reminder'
                    : "Back To Work",
                // "$dateTime",
                isTakeLookTimer?  formatedTimeStringForSec(
            "${newDifference?.inMinutes.remainder(60) ?? "20"}",
        "${newDifference?.inSeconds.remainder(60) ?? "0"}"): formatedTimeString(
                    "${newDifference?.inMinutes.remainder(60) ?? "20"}",
                    "${newDifference?.inSeconds.remainder(60) ?? "0"}"),
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channleId,
                    'MY FOREGROUND SERVICE',
                    icon: 'app_icon',
                    ongoing: true,
                    importance: Importance.max,
                    priority: Priority.high,
                    ticker: 'ticker',
                    autoCancel: false,
                    // playSound: false,
                    //actions: <AndroidNotificationAction>[
                    // AndroidNotificationAction('id_1', 'Stop'),
                    // AndroidNotificationAction('id_3', 'Action 3'),
                    // ],
                  ),
                ),
                payload: "eyeReminder");
            if (playSoundN&&enableSound) {
              // print("play sound");
              playSoundN = false;
              AudioPlayer().play(AssetSource('tunes/alarm202020.mp3'));
            }

            // if you don't using custom notification, uncomment this
            // service.setForegroundNotificationInfo(
            //   title: "My App Service",
            //   content: "Updated at ${DateTime.now()}",
            // );
          }
        }

        /// you can see this log in logcat
        // print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');


        // test using external plugin
        // final deviceInfo = DeviceInfoPlugin();
        // String? device;
        // if (Platform.isAndroid) {
        //   final androidInfo = await deviceInfo.androidInfo;
        //   device = androidInfo.model;
        // }

        // if (Platform.isIOS) {
        //   final iosInfo = await deviceInfo.iosInfo;
        //   device = iosInfo.model;
        // }

        service.invoke(
          'update',
          {
            "min": newDifference?.inMinutes.remainder(60) ?? "20",
            "sec": newDifference?.inSeconds.remainder(60) ?? "0",
            "type":isTakeLookTimer
          },
        );
      });
    }
  }
  // bring to foreground

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
    service.on('pauseTimer').listen((event) {
      if(_timerx!=null) {
        _timerx.cancel();
        // print("cancel timer");
      }
    });
    service.on('playTimer').listen((event) {
      if(_timerx!=null) {
        _timerx.cancel();
        onStart(service);
        // print("play timer");
      }
    });
    service.on('onUpdateTime').listen((event) {
      var newDifferencex;
      final initTimeY=DateTime.now();
      int storedMin=preferences.getInt("storedMin")??0;
      int  storedSec=preferences.getInt("storedSec")??0;
      var newAuctionx;
      bool isTakeLookTimer=preferences.getBool("isTakeLookTimer")??false;
      if(isTakeLookTimer) {
        newAuctionx = initTimeY!.add(Duration(seconds:(20-storedSec).abs() ));
      } else {
        newAuctionx = initTimeY!.add(Duration(minutes:(selectedMinValue-storedMin).abs(),seconds:(60-storedSec).abs() ));
      }
      newDifferencex = newAuctionx!.difference(DateTime.now());
      service.invoke(
        'update',
        {
          "min": newDifferencex?.inMinutes.remainder(60) ?? "20",
          "sec": newDifferencex?.inSeconds.remainder(60) ?? "0",
          "type":isTakeLookTimer
        },
      );
    });
  }

  service.on('stopService').listen((event) async{
    await preferences.setBool("isTakeLookTimer", false);
    await preferences.setInt("storedMin", 0);
    await preferences.setInt("storedSec", 0);
    service.invoke(
      'update',
      {
        "min": selectedMinValue+1,
        "sec": "0",
        "type":false
      },
    );
    service.stopSelf();
  });




}

class EyeSafeReminderPage extends StatefulWidget {
  EyeSafeReminderPage({Key? key}) : super(key: key);

  @override
  _EyeSafeReminderPageState createState() => _EyeSafeReminderPageState();
}

class _EyeSafeReminderPageState extends State<EyeSafeReminderPage> {
  bool enableSound=true;

  bool startTimer=false;
  bool pauseTimer=false;
  bool isTakeLookTimer=false;
  String _selectedMinValue="20";

   @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    setInitData();
    initDataTime();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return
      Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CAppBarWidget(title: "Screen Break Time".tr),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: IBoxDecoration.upperBoxDecoration(),
                child:_buildBody(),
              ),
            ),
          ],
        ),
      );

  }

  _buildBody() {
    return Column(
      children: [
        const SizedBox(height: 15),
           StreamBuilder(
               stream: FlutterBackgroundService().on('update'),
             builder: (context, snapshot) {
                 print(snapshot.data);
               if (!snapshot.hasData) {
                 return  SizedBox(
                   height: 190,
                   child: Stack(
                     children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(150.0),
                        child: Image.asset("assets/icon/dr.png",
                           height: 150,
                           width: 150,
                          fit: BoxFit.fill,
                         ),
                      ),
                       SizedBox(
                         width: 150,
                         height: 150,
                         child: CircularProgressIndicator(
                           strokeWidth: 10,
                           color: bgColor,
                           backgroundColor: Colors.red,
                           value: 1,
                           valueColor:AlwaysStoppedAnimation<Color>(Colors.green) ,
                           semanticsValue: "10",
                           semanticsLabel: "",
                         ),
                       ),
                       Positioned(
                         bottom:0,
                           right:0,
                           left:0,
                           child:
                           Center(child:formatedTime("$_selectedMinValue","0")))
                     ],
                   ),
                 );
               }
               else {
                 final data = snapshot.data!;
                 return SizedBox(
                height: 190,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(150.0),
                      child: Image.asset("assets/icon/dr.png",
                        height: 150,
                        width: 150,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        strokeWidth: 10,
                        color: bgColor,
                        backgroundColor: Colors.grey,
                        value:data['type']??false?getTimeStamp(data['min'].toString(),data['sec'].toString())/int.parse(_selectedMinValue):getTimeStamp(data['min'].toString(),data['sec'].toString())/(int.parse(_selectedMinValue)*60),
                        valueColor:AlwaysStoppedAnimation<Color>(Colors.green) ,
                        semanticsValue: "10",
                        semanticsLabel: "",
                      ),
                    ),
                      Positioned(
                          bottom:0,
                          left:0,
                          right:0,
                          child:
                    data['type']??false?
                    Center(child:formatedTimeSecOnly(data['min'].toString(),data['sec'].toString())):
                   Center(child: formatedTime(data['min'].toString(),data['sec'].toString()))

                    ),
                  ],
                ),
          );
               }
             }
           ),
    //Error svg


        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
          Text(isTakeLookTimer?
          "Time to rest, you have to take look 20m away for 20 sec"
          :"Time to work Every $_selectedMinValue minutes, rest your eyes for 20 seconds to prevent eye strain",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500
          ),),
        ),
        // _timer==null?
        Flexible(child:
        DeleteButtonWidget(onPressed:startTimer?null:()async{
          bool? isBatteryOptimizationDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled;
          if(isBatteryOptimizationDisabled!){
            final service = FlutterBackgroundService();
            FlutterBackgroundService().invoke("setAsBackground");
              service.startService();
            SharedPreferences pref=await SharedPreferences.getInstance();
            await pref.setBool("startTimer", true);
            startTimer=true;
            setState(() {

            });
          }else{
            DialogBoxes.openSettingBox(context, "Settings Change Need!", '''Please change your battery optimization setting to "No Restriction" for Pratyush as it eventually stops eyecare from the functioning in background''', (){
           openSetting();
            });
          }
        },title: "Start")
        ),
        Flexible(
          child: Row(
            children: [
              Flexible(child: DeleteButtonWidget(onPressed: !startTimer?null: ()async{
                pauseTimer?playBgService():  pauseBgService();
                setState(() {
                });

              },title: pauseTimer?"Play":"Pause")),
              Flexible(
                  child: DeleteButtonWidget(onPressed: !startTimer?null:()async{
                  stopBgService();

              },
                title: "Stop",))
            ],
          ),
        ),
        const SizedBox(height: 10),
        Image.asset("assets/icon/eye20r.jpeg"),
        const SizedBox(height: 10),
        const Text("20-20-20",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16
          ),),
        const SizedBox(height: 10),
        const Text("Screen Break Time",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16
        ),),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(25,8.0,25,8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Break Time Interval",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16
              ),),
              _genderDropDown(),

            ],
          ),
        ),


        SwitchListTile(
          contentPadding: EdgeInsets.fromLTRB(20,0,20,10),
          title: const Text('Enable Sound'),
          value: enableSound,
          activeTrackColor: btnColor,
          onChanged: (bool value)async {
            if(startTimer){
              ToastMsg.showToastMsg("Please Stop Timer, then you can able to change the setting");
            }else{
              SharedPreferences prefs=await SharedPreferences.getInstance();
              prefs.setBool('enableSound', value);
              setState(() {
                enableSound = value;
              });
            }

          },
          secondary: const Icon(Icons.record_voice_over),
        ),




      ],
    );
  }
  void stopBgService()async {
    SharedPreferences pref=await SharedPreferences.getInstance();
    await pref.setBool("startTimer", false);
    await pref.setBool("pauseTimer", false);
    startTimer=false;
    pauseTimer=false;
    setState(() {

    });
    final service = FlutterBackgroundService();
    service.invoke("stopService");
    Future.delayed(const Duration(seconds: 2), () {
      print("--------------Go BAck And In");

      Navigator.pop(context);
      Navigator.pushNamed(context, "/EyeSafeReminderPage");

    });


  }
  void pauseBgService() async{
    final service = FlutterBackgroundService();
    service.invoke("pauseTimer");
    SharedPreferences preferences=await SharedPreferences.getInstance();
    await preferences.setBool('pauseTimer', true);

    setState(() {
      pauseTimer=true;
    });


  }
  void playBgService() async{
    final service = FlutterBackgroundService();
    service.invoke("playTimer");
    SharedPreferences preferences=await SharedPreferences.getInstance();
    await preferences.setBool('pauseTimer', false);
    setState(() {
      pauseTimer=false;
    });

  }



  void initDataTime()async {
      // await initializeService();
    final service=FlutterBackgroundService();
     SharedPreferences pref=await SharedPreferences.getInstance();
     startTimer=   pref.getBool("startTimer")??false;
     pauseTimer= pref.getBool('pauseTimer')??false;
     if(pauseTimer) {
      service.invoke("onUpdateTime");
    }
    setState(() {

    });
  }

  formatedTime(min,sec) {
     if(min==null||sec==null){
       return Text("20:00");
     }
     String takeMin=min;
     String takeSec=sec;
     if(int.parse(takeMin)<10){
       takeMin="0$takeMin";
     }
     if(int.parse(takeSec)<10){
       takeSec="0$takeSec";
     }

   return Text( "$takeMin:$takeSec",
      style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 20
      ),
    );
  }
  formatedTimeSecOnly(min,sec) {
    if(min==null||sec==null){
      return Text("20:00");
    }
    String takeMin=min;
    String takeSec=sec;
    if(int.parse(takeMin)<10){
      takeMin="0$takeMin";
    }
    if(int.parse(takeSec)<10){
      takeSec="0$takeSec";
    }

    return Text( "$takeSec",
      style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 20
      ),
    );
  }

  Future <String> getCounter()async {
      SharedPreferences preferences=await SharedPreferences.getInstance();
   final counter= preferences.getInt("counter");
    return counter.toString();
  }

  Future getLastTime() async{
     SharedPreferences preferences=await SharedPreferences.getInstance();
     int storedMin=preferences.getInt("storedMin")??0;
     int  storedSec=preferences.getInt("storedSec")??0;
     print("lllllllllllllllll $storedMin $storedSec");
     return {
       "min":storedMin.toString(),
       "sec":storedSec.toString()

     };

  }

  getTimeStamp(String min, String sec) {
    int takeMin=int.parse(min);
    int takeSec=int.parse(sec);
    return  (takeMin*60)+takeSec;
    //print("$min $sec $takeMin $takeSec $timeMinSec");

  }

  void openSetting() async{
      final getRes=await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  }

  void setInitData() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    enableSound=  prefs.getBool('enableSound')??true;
    _selectedMinValue= prefs.getString('selectedMinValue')??"20";
    setState(() {

    });
  }
  _genderDropDown() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 0, right: 0),
      child: DropdownButton<String>(
        focusColor: Colors.white,
        value: _selectedMinValue,
        //elevation: 5,
        style: TextStyle(color: Colors.white),
        iconEnabledColor: btnColor,
        items: <String>[
          "5",
          "10",
          "15",
          "20",
          "25",
          "30",
          "35",
          "40",
          "45",
          "50",
          "55",
          "60"
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              "$value Minute",
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
        hint: const Text(
          "Break Time Interval",
        ),
        onChanged: (String? value) async{
          if(startTimer){
            ToastMsg.showToastMsg("Please Stop Timer, then you can able to change the time interval");
          }
          else{      SharedPreferences preferences =await SharedPreferences.getInstance();
          preferences.setString('selectedMinValue', value??"20");
          setState(() {
            print(value);
            _selectedMinValue = value!;
          });}
    
        },
      ),
    );
  }
}

formatedTimeString(min,sec) {
  String takeMin=min;
  String takeSec=sec;
  if(int.parse(takeMin)<10){
    takeMin="0$takeMin";
  }
  if(int.parse(takeSec)<10){
    takeSec="0$takeSec";
  }

  return "$takeMin:$takeSec";
}

formatedTimeStringForSec(min,sec) {
  String takeMin=min;
  String takeSec=sec;
  if(int.parse(takeMin)<10){
    takeMin="0$takeMin";
  }
  if(int.parse(takeSec)<10){
    takeSec="0$takeSec";
  }

  return "$takeSec";
}