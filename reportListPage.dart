import 'package:demopatient/Module/User/Provider/auth_provider.dart';
import 'package:demopatient/Provider/auth_provider.dart';
import 'package:demopatient/Screen/reports/updateReportPage.dart';
import 'package:demopatient/Service/reporstService.dart';
import 'package:demopatient/utilities/color.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/bottomNavigationBarWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart'as http;

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  ReportListPageeState createState() => ReportListPageeState();
}

class ReportListPageeState extends State<ReportListPage> {
  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<ReportProvider>(context, listen: false).getData();
    });
  }

  // void dispose() {
  //   // TODO: implement dispose
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar:
      //     BottomNavigationWidget(route: "/AddReportPage", title: "Add Report".tr),
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: appBarColor,
          elevation: 0.0,
          title: Text('Reports',
            style: TextStyle(
                color: Colors.white
            ),
          ),
        ),
        body:
        // Stack(
        //   clipBehavior: Clip.none,
        //   children: <Widget>[
        //     CAppBarWidget(title: "Reports".tr),
        //     Positioned(
        //       top: 80,
        //       left: 0,
        //       right: 0,
        //       bottom: 0,
        //       child: Container(
        //         height: MediaQuery.of(context).size.height,
        //         decoration: IBoxDecoration.upperBoxDecoration(),
        //         child:
        //         // FutureBuilder(
        //         //     future: ReportService.getData(),
        //         //     //ReadData.fetchNotification(FirebaseAuth.instance.currentUser.uid),//fetch all times
        //         //     builder: (context, AsyncSnapshot snapshot) {
        //         //       if (snapshot.hasData)
        //         //         return snapshot.data.length == 0
        //         //             ? NoDataWidget()
        //         //             : Padding(
        //         //             padding: const EdgeInsets.only(
        //         //                 top: 0.0, left: 8, right: 8),
        //         //             child: _buildCard(snapshot.data));
        //         //       else if (snapshot.hasError)
        //         //         return IErrorWidget(); //if any error then you can also use any other widget here
        //         //       else
        //         //         return LoadingIndicatorWidget();
        //         //     }
        //         //     ),
        //       ),
        //     ),
        //   ],
        // ),
        Consumer<ReportProvider>(
            builder: (context, provider, _) {
              if(provider.data != null)
                return Column(
                  children: [
                    for(int index = 0; index < provider.data!.length; ++index)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: (){
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
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
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text(provider.data![index].title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                      SizedBox(height: 5,),

                                      Text('Appointment# ${provider.data![index].appointmentId}',),

                                      SizedBox(height: 5,),

                                      if(provider.data![index].appointment != null)
                                        Text('${provider.data![index].appointment!.description}',),

                                      SizedBox(height: 5,),

                                    ],
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios_rounded,color: Colors.green,)
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );

              return SizedBox();
            }
        )
    );
  }

//   Widget _buildCard(prescriptionDetails) {
//     // _itemLength=notificationDetails.length;
//     return ListView.builder(
//         controller: _scrollController,
//         itemCount: prescriptionDetails.length,
//         itemBuilder: (context, index) {
//           return Text('nn');
//           // return GestureDetector(
//           //   onTap: () {
//           //     Navigator.push(
//           //       context,
//           //       MaterialPageRoute(
//           //           builder: (context) => UpdateReportPage(
//           //               reportModel:prescriptionDetails[index] ),
//           //       )
//           //     );
//           //   },
//           //   child: Card(
//           //     shape: RoundedRectangleBorder(
//           //       borderRadius: BorderRadius.circular(15.0),
//           //     ),
//           //     child: Padding(
//           //       padding: const EdgeInsets.all(8.0),
//           //       child: ListTile(
//           //           title: Text(prescriptionDetails[index].title,
//           //               style: TextStyle(
//           //                 fontFamily: 'OpenSans-Bold',
//           //                 fontSize: 14.0,
//           //               )),
//           //           trailing: Icon(
//           //             Icons.arrow_forward_ios,
//           //             color: iconsColor,
//           //             size: 20,
//           //           ),
//           //       ),
//           //     ),
//           //   ),
//           // );
//         }
//     );
//   }
// }
}
