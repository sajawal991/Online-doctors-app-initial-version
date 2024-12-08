import 'package:demopatient/model/drProfielModel.dart';
import 'package:flutter/material.dart';
import 'package:demopatient/Screen/appointment/appointment.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:get/get.dart';

import '../widgets/paddingAdjustWidget.dart';

class ChooseDoctorsPage extends StatefulWidget {
  final deptId;
  final deptName;
  final clinicId;
  final clinicName;
  final cityId;
  final cityName;
  final clinicLocationName;
  ChooseDoctorsPage(
      {this.deptId,
      this.deptName,
      this.clinicId,
      this.clinicName,
      this.clinicLocationName,
      this.cityName,
      this.cityId});
  @override
  _ChooseDoctorsPageState createState() => _ChooseDoctorsPageState();
}

class _ChooseDoctorsPageState extends State<ChooseDoctorsPage> {
  List <DrProfileModel> drList=[];
  bool _isLoading=false;

  @override
  void initState() {
    // TODO: implement initState
    getAndSet();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        // bottomNavigationBar: BottomNavigationStateWidget(
        //   title: "Next",
        //   onPressed: () {
        //
        //   },
        //   clickable: "true"//_serviceName,
        // ),
        body: Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        CAppBarWidget(title: "Select Doctor".tr), //common app bar
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: IBoxDecoration.upperBoxDecoration(),
            child: _isLoading ? LoadingIndicatorWidget() : drList.isEmpty ? NoDataWidget():
            _buildContent(drList)

            // FutureBuilder(
            //     future: DrProfileService.getDataById(
            //         widget.deptId,
            //         widget.clinicId,
            //         widget.cityId), //fetch images form database
            //     builder: (context, AsyncSnapshot snapshot) {
            //       if (snapshot.hasData)
            //         return snapshot.data.length == 0
            //             ? NoDataWidget()
            //             : _buildContent(snapshot.data);
            //       else if (snapshot.hasError)
            //         return IErrorWidget(); //if any error then you can also use any other widget here
            //       else
            //         return LoadingIndicatorWidget();
            //     }),
          ),
        )
      ],
    ));
  }

  _buildContent(listDetails) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0), // old value is 20 + hassan005004
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GridView.count(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          childAspectRatio: .6,
          crossAxisCount: 2,
          children: List.generate(listDetails.length, (index) {
            return _cardImg(listDetails[index], listDetails.length, index); //send type details and index with increment one
          }),
        ),
      ),
    );
  }

  _cardImg(DrProfileModel listDetails, length, index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentPage(
              doctId: listDetails.id,
              deptName: widget.deptName,
              hospitalName: listDetails.hName,
              doctName: "${listDetails.firstName} ${listDetails.lastName}" ,
              stopBooking: listDetails.stopBooking,
              fee: listDetails.fee,
              clinicId: widget.clinicId,
              cityId: widget.cityId,
              deptId: widget.deptId,
              cityName: widget.cityName,
              clinicName: widget.clinicName,
              payLaterActive: listDetails.payLater,
              payNowActive: listDetails.payNow,
              videoActive: listDetails.video_active,
              walkinActive: listDetails.walkin_active,
              vspd: listDetails.vspd,
              wspd: listDetails.wspdp
            ),
          ),
        );
      },
      child: PaddingAdjustWidget(
        index: index,
        itemInRow: 2,
        length: length,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 90,
                    child: listDetails.profileImageUrl == "" ||
                            listDetails.profileImageUrl == null
                        ? Icon(Icons.image)
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                              child: ImageBoxFillWidget(
                                    imageUrl: listDetails.profileImageUrl),
                            ),
                        )),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 90,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${listDetails.firstName} ${listDetails.lastName}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, fontFamily: "OpenSans-SemiBold"),
                            ),
                            Text(
                              listDetails.hName??"",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, fontFamily: "OpenSans-SemiBold"),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            )),
      ),
    );
  }

  void getAndSet() async{
    setState(() {
      _isLoading=true;
    });
    final res = await DrProfileService.getDataById(
        widget.deptId,
        widget.clinicId,
        widget.cityId);

    if(res.isNotEmpty){
      for(int i = 0; i < res.length; i++){
        if(res[i].active == "1"){
          setState(() {
            drList.add(res[i]);
          });
        }
      }
    }

    setState(() {
      _isLoading=false;
    });
  }
}
