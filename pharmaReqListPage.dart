import 'package:demopatient/Screen/pharmacy/updatePharmaReq.dart';
import 'package:demopatient/Service/pharma_req_service.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/widget.dart';
import '../../widgets/paddingAdjustWidget.dart';

class PharmaReqListPage extends StatefulWidget {
  @override
  _PharmaReqListPageState createState() => _PharmaReqListPageState();
}

class _PharmaReqListPageState extends State<PharmaReqListPage> {
  final ScrollController _scrollController = new ScrollController();
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
      // BottomNavigationWidget(route: "/CityListPharmaPage", title: "New Request".tr),
      bookAnAppointment(context),
      body: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          CAppBarWidget(title: "All Request".tr),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: IBoxDecoration.upperBoxDecoration(),
              child: FutureBuilder(
                  future: PharmaReqService.getData(),
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
      child: ListView.builder(
          controller: _scrollController,
          itemCount: prescriptionDetails.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPharmaReqPage(
                          reportModel:prescriptionDetails[index] ),
                    )
                );
              },
              child: PaddingAdjustWidget(
                index: index,
                itemInRow: 2,
                length: prescriptionDetails.length,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Status: ".tr,  style: TextStyle(
                                  fontFamily: 'OpenSans-Bold',
                                  fontSize: 14.0,
                                )),
                                Text(prescriptionDetails[index].status=="0"?
                                    "Pending".tr:prescriptionDetails[index].status=="1"?"Confirmed".tr:
                        prescriptionDetails[index].status=="2"?"Delivered".tr: prescriptionDetails[index].status=="3"?"Canceled".tr:"Not Updated".tr,
                                    style: TextStyle(
                                      fontFamily: 'OpenSans-Bold',
                                      fontSize: 14.0,
                                    )
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.circle,size: 13,color: prescriptionDetails[index].status=="0"?
                                Colors.yellowAccent:prescriptionDetails[index].status=="1"?Colors.orange:
                                prescriptionDetails[index].status=="2"? Colors.green:prescriptionDetails[index].status=="3"?Colors.red:Colors.white,)
                              ],
                            ),
                            Text("Date: ".tr+prescriptionDetails[index].createdTimeStamp,
                                style: TextStyle(
                                  fontFamily: 'OpenSans-Bold',
                                  fontSize: 14.0,
                                )),
                          ],
                        ),
                      title: Text("Request Id: ".tr+prescriptionDetails[index].id,
                          style: TextStyle(
                            fontFamily: 'OpenSans-Bold',
                            fontSize: 14.0,
                          )),
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
    );
  }
}
