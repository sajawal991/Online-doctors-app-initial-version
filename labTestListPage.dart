
import 'package:flutter/material.dart';
import 'package:demopatient/Screen/labTest/registerLabTestUserPage.dart';
import 'package:demopatient/Service/lab_test_service.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';

import '../../widgets/paddingAdjustWidget.dart';

class LabTestListPage extends StatefulWidget {
  final clinicId;
  final clinicName;
  final locationName;
  LabTestListPage({this.clinicId, this.clinicName,this.locationName});
  @override
  _LabTestListPageState createState() => _LabTestListPageState();
}

class _LabTestListPageState extends State<LabTestListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CAppBarWidget(title: widget.clinicName), //common app bar
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: IBoxDecoration.upperBoxDecoration(),
                child:FutureBuilder(
                    future:
                    LabTestService.getData(widget.clinicId), //fetch images form database
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData)
                        return snapshot.data.length == 0
                            ? NoDataWidget()
                            : _buildContent(snapshot.data);
                      else if (snapshot.hasError)
                        return IErrorWidget(); //if any error then you can also use any other widget here
                      else
                        return LoadingIndicatorWidget();
                    }),
              ),
            )
          ],
        )
      // appBar: IAppBars.commonAppBar(context, widget.cityName),

    );
  }

  _buildContent(listDetails) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            itemCount: listDetails.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _cardImg(listDetails[index], listDetails.length, index);
            }),
      ),
    );
  }

  _cardImg(listDetails, length, index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPatientLabTest(
              cliniId: widget.clinicId,
             price: listDetails.price,
              testId: listDetails.id,
              testName: listDetails.title,
              clinicName: widget.clinicName,
              locationName: widget.locationName,
            ),
          ),
        );
      },
      child: PaddingAdjustWidget(
        index: index,
        itemInRow: 1,
        length: length,
        child: Card(
          elevation: .5,
          child: Padding(
              padding: const EdgeInsets.all(0.0),
              child:ListTile(
                isThreeLine: true,
                leading:
                Container(
                    width: 80,
                    child:
                    listDetails.imageUrl == "" || listDetails.imageUrl == null
                        ? Icon(Icons.image)
                        : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ImageBoxFillWidget(
                            imageUrl: listDetails.imageUrl)
                    )
                ),
                title:    Text(
                  listDetails.title,
                  style: TextStyle(
                      fontSize: 14, fontFamily: "OpenSans-SemiBold"),
                ),subtitle:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listDetails.subTitle,
                    style: TextStyle(
                        fontSize: 14, fontFamily: "OpenSans-SemiBold"),
                  ),
                  Text(
                    "${listDetails.price}\u{20B9}",
                    style: TextStyle(
                        fontSize: 14, fontFamily: "OpenSans-SemiBold"),
                  ),
                ],
              ),
              )
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //
            //     SizedBox(width: 10),
            //     Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Text(
            //           listDetails.title,
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //               fontSize: 14, fontFamily: "OpenSans-SemiBold"),
            //         ),
            //         Text(
            //           listDetails.locationName,
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //               fontSize: 14, fontFamily: "OpenSans-SemiBold"),
            //         ),
            //       ],
            //     )
            //   ],
            // ),
          ),
        ),
      ),
      // child: Card(
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(10.0),
      //     ),
      //     child: Stack(
      //       children: [
      //         Positioned(
      //             top: 0,
      //             left: 0,
      //             right: 0,
      //             bottom: 45,
      //             child: ImageBoxFillWidget(imageUrl: listDetails.imageUrl)),
      //         Positioned(
      //             bottom: 0,
      //             left: 0,
      //             right: 0,
      //             child: Container(
      //               height: 45,
      //               child: Center(
      //                 child: Text(
      //                   listDetails.title,
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(
      //                       fontSize: 14, fontFamily: "OpenSans-SemiBold"),
      //                 ),
      //               ),
      //             )),
      //       ],
      //     )),
    );
  }
}
