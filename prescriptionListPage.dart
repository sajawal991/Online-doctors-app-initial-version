import 'package:demopatient/Screen/prescription/prescriptionDetails.dart';
import 'package:demopatient/Service/prescriptionService.dart';
import 'package:demopatient/helper/extensions/date_time.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/widget.dart';
import '../../widgets/paddingAdjustWidget.dart';

class PrescriptionListPage extends StatefulWidget {
  @override
  _PrescriptionListPageState createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> {
  final ScrollController _scrollController = new ScrollController();
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar:
      //     BottomNavigationWidget(route: "/ContactUsPage", title: "Contact us"),
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          CAppBarWidget(title: "Prescriptions".tr),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: IBoxDecoration.upperBoxDecoration(),
              child: FutureBuilder(
                  future: PrescriptionService.getData(),
                  //ReadData.fetchNotification(FirebaseAuth.instance.currentUser.uid),//fetch all times
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData)
                      return snapshot.data.length == 0
                          ? NoDataWidget()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  top: 0.0, left: 8, right: 8),
                              child: _buildCard(snapshot.data));
                    else if (snapshot.hasError)
                      return IErrorWidget(); //if any error then you can also use any other widget here
                    else
                      return LoadingIndicatorWidget();
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(prescriptionDetails) {
    // _itemLength=notificationDetails.length;
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListView.builder(
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
                child: PaddingAdjustWidget(
                  index: index,
                  itemInRow: 1,
                  length: prescriptionDetails.length,
                  child: Container(
                    margin: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Color(0xFFE1E1E1),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0), // Radius for all corners
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                          title: Row(
                            children: [
                              appointmentDate(prescriptionDetails[index].appointmentDate),
                              SizedBox(width: 20,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prescriptionDetails[index].appointmentName,
                                      style: TextStyle(
                                        fontFamily: 'OpenSans-Bold',
                                        fontSize: 14.0,
                                      )),
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
                                    //${prescriptionDetails[index].appointmentTime}
                                    prescriptionDetails[index].appointmentDate.toString().toStandardDateTime24Hour(),
                                    style: TextStyle(
                                      fontFamily: 'OpenSans-Regular',
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: iconsColor,
                            size: 20,
                          ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
