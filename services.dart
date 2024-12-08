import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:flutter/material.dart';
import 'package:demopatient/Service/serviceService.dart';
import 'package:demopatient/Screen/moreService.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:get/get.dart';

import '../utilities/color.dart';
import '../widgets/paddingAdjustWidget.dart';
import 'chooseDoctorsPage.dart';

class ServicesPage extends StatefulWidget {
  ServicesPage({Key? key}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15, top: 12.0, bottom: 12.0), // top bottom old value is 8 + left right old value is 20 + hassan005004
          child: Container(
            height: 45, // old value is 35 + hassan005004
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: InkWell(
              onTap:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChooseDoctorsPage(
                      cityName: 'city',
                      cityId: 1,
                      clinicLocationName: 'location',
                      clinicId: 1,
                      clinicName: 'clinic',
                      deptId: 1,
                      deptName: 'department',
                    ),
                  )
                );
              },
              child: Text("Book an appointment".tr),
            )
          ),
        ),

        // BottomNavigationWidget(
        //   title: "Book an appointment".tr,
        //   route: '/CityListPage',
        // ),
        body: _buildContent());
  }

  Widget _buildContent() {
    return Stack(
      //overflow: Overflow.visible,
      children: <Widget>[
        CAppBarWidget(title: 'Service'.tr),
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: IBoxDecoration.upperBoxDecoration(),
            child: Padding(
                padding: const EdgeInsets.only(
                  top: 0.0,
                  left: 10,
                  right: 10,
                ), // left and right old value is 20 + hassan005004
                child: FutureBuilder(
                    future: ServiceService.getData(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData)
                        return snapshot.data.length == 0
                            ? NoDataWidget()
                            : _buildGridView(snapshot.data);
                      else if (snapshot.hasError)
                        return IErrorWidget(); //if any error then you can also use any other widget here
                      else
                        return LoadingIndicatorWidget();
                    })),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(service) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GridView.count(
        childAspectRatio: .8, //you can change the size of items
        crossAxisCount: 2,
        shrinkWrap: true,
        children: List.generate(service.length, (index) {
          return _cardImg(service[index], service.length, index);
        }),
      ),
    );
  }

  Widget _cardImg(serviceDetails, length, index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoreServiceScreen(
                serviceDetails:
                    serviceDetails), //send to data to the next screen
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
                    bottom: 45,
                    child: serviceDetails.imageUrl == "" ||
                            serviceDetails.imageUrl == null
                        ? Icon(Icons.image)
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            child: ImageBoxFillWidget(imageUrl: serviceDetails.imageUrl))
                          ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 45,
                      child: Center(
                        child: Text(
                          serviceDetails.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontFamily: "OpenSans-SemiBold"),
                        ),
                      ),
                    )),
              ],
            )),
      ),
    );

  }
}
