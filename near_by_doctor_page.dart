// import 'dart:async';
// import 'package:demopatient/Screen/aboutus.dart';
// import 'package:demopatient/model/drProfielModel.dart';
// import 'package:demopatient/utilities/color.dart';
// import 'package:demopatient/utilities/toastMsg.dart';
// import 'package:flutter/material.dart';
// import 'package:demopatient/Service/drProfileService.dart';
// import 'package:demopatient/utilities/decoration.dart';
// import 'package:demopatient/widgets/appbarsWidget.dart';
// import 'package:demopatient/widgets/errorWidget.dart';
// import 'package:demopatient/widgets/imageWidget.dart';
// import 'package:demopatient/widgets/loadingIndicator.dart';
// import 'package:location/location.dart';
// import 'package:permission_handler/permission_handler.dart' as per;
// import 'package:geolocator/geolocator.dart';
// class NearByDoctorsListPage extends StatefulWidget {
//
//   @override
//   _NearByDoctorsListPageState createState() => _NearByDoctorsListPageState();
// }
//
// class _NearByDoctorsListPageState extends State<NearByDoctorsListPage> {
//   bool _isLoading=false;
//   bool locationEnabled=false;
//   double long=0.0;
//   double lat=0.0;
//   Timer? _timer;
//   List <DrProfileModelLocation> drList=[];
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _timer!.cancel();
//     super.dispose();
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     _getLocation();
//
//     super.initState();
//   }
//
//   _getLocation() async {
//     setState(() {
//       _isLoading=true;
//     });
//     Location location = new Location();
//     PermissionStatus   _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted == PermissionStatus.granted) {
//         setState(() {
//           locationEnabled=true;
//         });
//         setLocation( location);
//         _timer= new Timer.periodic(const Duration(seconds: 2), (Timer t){
//           print("enabled timer");
//           setState(() {
//           });
//
//         });
//       }
//       else if(_permissionGranted==PermissionStatus.deniedForever){
//         ToastMsg.showToastMsg("Please give us location permission from app settings");
//         try{
//           print("try to open app setting");
//           await per.openAppSettings();
//         }catch(e){
//           print(e);
//         }
//         setState(() {
//           _isLoading=false;
//         });
//       }
//     }
//     else if(_permissionGranted==PermissionStatus.deniedForever){
//       ToastMsg.showToastMsg("Please give us location permission from app settings");
//       try{
//         print("try to open app setiing");
//         await per.openAppSettings();
//       }catch(e){
//         print(e);
//       }
//       setState(() {
//         _isLoading=false;
//       });
//
//     }else if (_permissionGranted == PermissionStatus.granted) {
//       setState(() {
//         locationEnabled=true;
//       });
//       setLocation( location);
//       _timer= new Timer.periodic(const Duration(seconds: 2), (Timer t){
//         print("enabled timer");
//        // setLocation( location);
//       });
//     }
//
//
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // bottomNavigationBar: BottomNavigationStateWidget(
//       //   title: "Next",
//       //   onPressed: () {
//       //
//       //   },
//       //   clickable: "true"//_serviceName,
//       // ),
//         body: Stack(
//           clipBehavior: Clip.none,
//           children: <Widget>[
//             CAppBarWidget(title: "Doctors"), //common app bar
//             Positioned(
//               top: 80,
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: Container(
//                 height: MediaQuery.of(context).size.height,
//                 decoration: IBoxDecoration.upperBoxDecoration(),
//                 child: _isLoading?LoadingIndicatorWidget():!locationEnabled?Container():FutureBuilder(
//                     future: fetchUserData(), //fetch images form database
//                     builder: (context, AsyncSnapshot snapshot) {
//                       if (snapshot.hasData)
//                         return snapshot.data.length == 0
//                             ? LoadingIndicatorWidget()
//                             : _buildContent(snapshot.data);
//                       else if (snapshot.hasError)
//                         return IErrorWidget(); //if any error then you can also use any other widget here
//                       else
//                         return LoadingIndicatorWidget();
//                     }),
//               ),
//             )
//           ],
//         ));
//   }
//
//   _buildContent(listDetails) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10.0, right: 10.0), // old value is 20 + hassan005004
//       child: GridView.count(
//         physics: ScrollPhysics(),
//         shrinkWrap: true,
//         childAspectRatio: .6,
//         crossAxisCount: 2,
//         children: List.generate(listDetails.length, (index) {
//           return _cardImg(listDetails[
//           index]); //send type details and index with increment one
//         }),
//       ),
//     );
//   }
//
//   _cardImg(listDetails) {
//     final distance =calculateDistanceToShow(lat, long, double.parse(listDetails.lat.toString()), double.parse(listDetails.log.toString())).toStringAsFixed(2);
//     return GestureDetector(
//       onTap: () {
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AboutUs(
//               doctId: listDetails.id,
//               cityId: listDetails.cityId,
//               cityName: listDetails.cityName,
//               clinicId: listDetails.clinicId,
//             ),
//           ),
//         );
//       },
//       child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   bottom: 90,
//                   child: listDetails.profileImageUrl == "" ||
//                       listDetails.profileImageUrl == null
//                       ? Icon(Icons.image)
//                       : ImageBoxFillWidget(
//                       imageUrl: listDetails.profileImageUrl)),
//               Positioned(
//
//                   right: 0,
//                   bottom: 90,
//                   child: Card(
//                     color: appBarColor,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Icon(Icons.near_me),
//                           Text(double.parse(distance)>=1?distance+"KM":distance+"M",style: TextStyle(
//                             color: Colors.white
//                           ),),
//                         ],
//                       ),
//                     ),
//                   )),
//               Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     height: 90,
//                     child: Center(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Dr. " +
//                                 listDetails.firstName +
//                                 " " +
//                                 listDetails.lastName,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 fontSize: 14, fontFamily: "OpenSans-SemiBold"),
//                           ),
//                           Text(
//                             listDetails.hName,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 fontSize: 14, fontFamily: "OpenSans-SemiBold"),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )),
//             ],
//           )),
//     );
//   }
//
//   setLocation( Location location)async{
//     LocationData? _locationData;
//     _locationData = await location.getLocation();
//     print(_locationData.latitude);
//     print(_locationData.longitude);
//     setState(() {
//       lat=_locationData!.latitude??0.0;
//           long=_locationData.longitude??0.0;
//     });
//     setState(() {
//       _isLoading=false;
//     });
//   }
//
//   double calculateDistance(startLatitude,startLongitude,endLatitude,endLongitude) {
//     final des=GeolocatorPlatform.instance.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
//    // print("Distance $des");
//     return des;
//   }
//   double calculateDistanceToShow(startLatitude,startLongitude,endLatitude,endLongitude) {
//     final des=GeolocatorPlatform.instance.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
//     // print("Distance $des");
//     final distance= des/1000;
//
//     return distance;
//   }
//
//
//
//  Future <List<DrProfileModelLocation>>fetchUserData()async {
//     List <DrProfileModelLocation>newList=[];
//     if(lat!=0.0&&long!=0.0){
//       final res=await DrProfileService.getAllDrData();
//       if(res.isNotEmpty)
//         {
//           for(int i=0;i<res.length;i++){
//             if(res[i].active=="1")
//             setState(() {
//               newList.add(res[i]);
//             });
//           }
//           setState(() {
//             drList=newList;
//           });
//         }
//
//       //print(drList[0].firstName);
//       // List<String> numbers = ['one', 'two', 'three', 'four'];
//       drList.sort((a, b) {
//         final firstDis=calculateDistance(lat, long, double.parse(a.lat.toString()),double.parse(a.log.toString()));
//         final secDis=calculateDistance(lat, long,double.parse(b.lat.toString()), double.parse(b.log.toString()));
//        // print("************");
//      //   print(firstDis.compareTo(secDis));
//         return firstDis.compareTo(secDis);
//       //  print("************");
//       });
//       return drList;
//     }else return[];
//     }
//
// }
