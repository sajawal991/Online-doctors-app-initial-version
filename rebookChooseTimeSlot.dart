import 'package:demopatient/Service/appointmentService.dart';
import 'package:demopatient/Service/closingDateService.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/SetData/screenArg.dart';
import 'package:demopatient/model/doctTimeSlotModel.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

class RebookChooseTimeSlotPage extends StatefulWidget {
  final serviceName;
  final serviceTimeMin;

  final deptName;
  final doctName;
  final hospitalName;
  final doctId;

  final clinicId;
  final cityId;
  final deptId;
  final cityName;
  final clinicName;

  const RebookChooseTimeSlotPage(
      {Key? key,
      this.serviceName,
      this.serviceTimeMin,
      this.deptName,
      this.hospitalName,
      this.doctName,
      this.doctId,
      this.cityId,
      this.clinicId,
      this.deptId,
      this.cityName,
      this.clinicName})
      : super(key: key);

  @override
  _RebookChooseTimeSlotPageState createState() =>
      _RebookChooseTimeSlotPageState();
}

class _RebookChooseTimeSlotPageState extends State<RebookChooseTimeSlotPage> {
  bool _isLoading = false;
  var _selectedDate;
  var _selectedDay = DateTime.now().weekday;
  List _closingDate = [];
  Map closingTime = Map();
  List _dayCode = [];
  String fee = "";
  String opt = "";
  String clt = "";
  String lopt = "";
  String lclt = "";
  String closingDay = "";
  String payNowActive="true";
  String payLaterActive="true";
  String wspdp="0";
  String vspd="0";
  int filledSlot=0;
  ScrollController scrollController=ScrollController();
  List<DoctorTimeSlotModel> drTimeSlots=[];
  @override
  void initState() {
    super.initState();
    _getAndSetAllInitialData();
  }

  _getAndSetAllInitialData() async {
    setState(() {
      _isLoading = true;
    });

    _selectedDate = await _initializeDate(); //Initialize start time

    await _setClosingDate();
    //await _getAndSetbookedTimeSlots();
    //await _getAndSetOpeningClosingTime();
    //_getAndsetTimeSlots(
      //  _openingTimeHour, _openingTimeMin, _closingTimeHour, _closingTimeMin);

    setState(() {
      _isLoading = false;
    });
  }


  Future<String> _initializeDate() async {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.month}-${dateParse.day}-${dateParse.year}";

    return formattedDate;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // bottomNavigationBar: BottomNavigationStateWidget(
        //   title: "Next",
        //   onPressed: () {
        //     Navigator.pushNamed(context, "/RegisterPatientPage",
        //         arguments: ChooseTimeScrArg(
        //             widget.serviceName,
        //             widget.serviceTimeMin,
        //             _setTime,
        //             _selectedDate,
        //             widget.doctName,
        //             widget.deptName,
        //             widget.hospitalName,
        //             widget.doctId,
        //             fee,
        //             widget.deptId,
        //             widget.cityId,
        //             widget.clinicId,
        //             widget.clinicName,
        //             widget.cityName,
        //         "",
        //         "",
        //         "",
        //         ""));
        //   },
        //   clickable: _setTime,
        // ),
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CAppBarWidget(title: "Book an appointment"),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 20.0, left: 10, right: 10),
                          child: SingleChildScrollView(
                            // controller: _scrollController,
                            child: Column(
                              children: <Widget>[
                                _buildCalendar(),
                                Divider(),
                                _isLoading
                                    ? LoadingIndicatorWidget()
                                    : _closingDate.contains(_selectedDate) ||
                                            _dayCode.contains(_selectedDay)
                                        ? Center(
                                            child: Text(
                                            "Sorry! we can't take appointments in this day",
                                            style: TextStyle(
                                              fontFamily: 'OpenSans-SemiBold',
                                              fontSize: 14,
                                            ),
                                          ))
                                        :
                                !checkSlotExists()?
                                Text(
                                  "Sorry! no any slots available in this date",
                                  style: TextStyle(
                                    fontFamily: 'OpenSans-SemiBold',
                                    fontSize: 14,
                                  ),
                                ):
                                Column(
                                  children: [
                                    Text( widget.serviceName=="Offline"?"Walk-in Appointment ${filledSlot}/${wspdp} Slots":"Video Consultant ${filledSlot}/${vspd} Slots",  style: TextStyle(
                                      fontFamily: 'OpenSans-SemiBold',
                                      fontSize: 14,
                                    )),
                                    ListView.builder(
                                        controller: scrollController,
                                        shrinkWrap: true,
                                        itemCount: drTimeSlots.length,
                                        itemBuilder: (context, index) {
                                          final slotType=widget.serviceName=="Online"?"1":"0";
                                          return  drTimeSlots[index].dayCode==_selectedDay.toString()&&drTimeSlots[index].slotType==slotType?
                                          Card(
                                            color: Colors.grey.shade100,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            elevation: 1,
                                            child: ListTile(
                                              title: Text(drTimeSlots[index].timeSlot,
                                                style: TextStyle(
                                                  fontFamily: 'OpenSans-SemiBold',
                                                  fontSize: 16,
                                                ),),
                                              trailing:ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    shape:
                                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                                                  ),
                                                  onPressed: (){
                                                    //*****
                                                        Navigator.pushNamed(context, "/RegisterPatientPage",
                                                            arguments: ChooseTimeScrArg(
                                                                widget.serviceName,
                                                                widget.serviceTimeMin,
                                                                drTimeSlots[index].timeSlot,
                                                                _selectedDate,
                                                                widget.doctName,
                                                                widget.deptName,
                                                                widget.hospitalName,
                                                                widget.doctId,
                                                                fee,
                                                                widget.deptId,
                                                                widget.cityId,
                                                                widget.clinicId,
                                                                widget.clinicName,
                                                                widget.cityName,
                                                                payNowActive,
                                                                payLaterActive,
                                                                wspdp,
                                                                vspd
                                                            ));

                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(10,0,10,0),
                                                    child: Text( "Book", style: TextStyle(fontSize: 14)),
                                                  )),
                                            ),
                                          ):Container();

                                        }),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildCalendar() {
    return DatePicker(
      DateTime.now(),
      initialSelectedDate: DateTime.now(),
      selectionColor: appBarColor,
      selectedTextColor: Colors.white,
      daysCount: 7,
      onDateChange: (date) {
        // New date selected
        setState(() {
          final dateParse = DateTime.parse(date.toString());

          _selectedDate =
              "${dateParse.month}-${dateParse.day}-${dateParse.year}";
          _selectedDay = date.weekday;
          checkFilledSlot(_selectedDate);

        });
      },
    );
  }
  void checkFilledSlot(selectedDate) async{
    setState(() {
      _isLoading=true;
    });
    final checkRes = await AppointmentService.getCheckPD(
        widget.doctId,
        selectedDate,
        widget.serviceName=="Online"?"true":"false");
    setState(() {
      filledSlot=checkRes.length;
    });

    setState(() {
      _isLoading=false;
    });
  }


  _setClosingDate() async {
    setState(() {
      _isLoading = true;
    });
    final res = await ClosingDateService.getData(
        widget.doctId); // ReadData.fetchSettings();
    if (res.isNotEmpty) {
      for (var e in res) {
        if (e.allDay == "1") {
          print(";;;;;;;;;llllllllllllllll${e.date}");
          setState(() {
            _closingDate.add(e.date);
            //res["closingDate"];
          });
        } else if (e.allDay == "0") {
          setState(() {
            closingTime[e.date] = [];
            closingTime[e.date].addAll(e.blockTime);
            print("LCccccccccccc${closingTime}");
          });
        }
      }
    }
    final getDoct = await DrProfileService.getDataByDrId(widget.doctId);
    if (getDoct[0].closingDate != "" && getDoct[0].closingDate != null) {
      final coledDatArr = (getDoct[0].closingDate)!.split(',');
      for (var element in coledDatArr) {
        _closingDate.add(int.parse(element));
      }
    }

    opt = getDoct[0].opt!;
    clt = getDoct[0].clt!;
    lopt = getDoct[0].lunchOpeningTime!;
    lclt = getDoct[0].lunchClosingTime!;
    closingDay = getDoct[0].dayCode!;
    payLaterActive=getDoct[0].payLater;
    payNowActive=getDoct[0].payNow;
    wspdp=getDoct[0].wspdp;
    vspd=getDoct[0].vspd;
    fee = getDoct[0].fee!;

    final getDrSlots=await DrProfileService.getDoctTimeSlot(widget.doctId);
    if(getDrSlots.isNotEmpty)
      setState(() {
        drTimeSlots=getDrSlots;
      });
    setState(() {
      _isLoading = false;
    });
  }
  bool checkSlotExists() {
    final slotType=widget.serviceName=="Online"?"1":"0";
    bool exists=false;
    for(int i=0;i<drTimeSlots.length;i++){
      if(drTimeSlots[i].dayCode==_selectedDay.toString()&&drTimeSlots[i].slotType==slotType)
      {
        exists=true;
        break;
      }
    }

    return exists;
  }
}
